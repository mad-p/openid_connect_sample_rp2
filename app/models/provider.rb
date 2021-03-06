class Provider < ActiveRecord::Base
  serialize :scopes_supported, JSON
  serialize :response_types_supported, JSON

  has_many :open_ids
  belongs_to :account

  validates :issuer,                 presence: true, uniqueness: {allow_nil: true}
  validates :name,                   presence: true
  validates :identifier,             presence: {if: :registered?}
  validates :authorization_endpoint, presence: {if: :registered?}
  validates :token_endpoint,         presence: {if: :registered?}

  scope :dynamic, lambda { where(dynamic: true) }
  scope :static,  lambda { where(dynamic: false) }
  scope :valid, lambda {
    where {
      (expires_at == nil) |
      (expires_at >= Time.now.utc)
    }
  }

  def expired?
    expires_at.try(:past?)
  end

  def registered?
    identifier.present? && !expired?
  end

  def userinfo_available?
    userinfo_endpoint.present?
  end

  def config
    @config ||= OpenIDConnect::Discovery::Provider::Config.discover! issuer
  end

  def register!(redirect_uri)
    client = OpenIDConnect::Client::Registrar.new(
      config.registration_endpoint,
      client_name: 'NOV RP',
      application_type: 'web',
      redirect_uris: [redirect_uri],
      subject_type: 'pairwise'
    ).register!
    self.attributes = {
      identifier:               client.identifier,
      secret:                   client.secret,
      scopes_supported:         config.scopes_supported,
      response_types_supported: config.response_types_supported,
      authorization_endpoint:   config.authorization_endpoint,
      token_endpoint:           config.token_endpoint,
      userinfo_endpoint:        config.userinfo_endpoint,
      jwks_uri:                 config.jwks_uri,
      expires_at:               client.expires_in.try(:from_now)
    }
    save!
  end

  def as_json(options = {})
    [
      :identifier, :secret, :scopes_supported, :jwks_uri,
      :authorization_endpoint, :token_endpoint, :userinfo_endpoint
    ].inject({}) do |hash, key|
      hash.merge!(
        key => self.send(key)
      )
    end
  end

  def client
    @client ||= OpenIDConnect::Client.new as_json
  end

  def authorization_uri(redirect_uri, nonce)
    client.redirect_uri = redirect_uri
    response_type = Array(response_types_supported).detect do |_response_type_|
      _response_type_.include?('code') ||
      _response_type_.include?('id_token')
    end or raise OpenIDConnect::Exception.new('No supported response_type available for this OP')
    client.authorization_uri(
      response_type: response_type,
      nonce: nonce,
      state: nonce,
      scope: scopes_supported
    )
  end

  def decode_id(id_token)
    public_key = if jwks_uri
      JSON::JWK.decode JSON.parse(
        OpenIDConnect.http_client.get_content(jwks_uri)
      )['keys'].first
    else
      config.public_keys.first
    end
    OpenIDConnect::ResponseObject::IdToken.decode id_token, public_key
  end

  def authenticate(code: nil, id_token: nil, access_token: nil, redirect_uri: nil, nonce: nil)
    if code.present?
      client.redirect_uri = redirect_uri
      client.authorization_code = code
      access_token = client.access_token!
      id_token ||= access_token.id_token
    end
    unless id_token.present?
      raise Authentication::AuthenticationRequired.new('No valid ID Token given')
    end
    _id_token_ = decode_id id_token
    _id_token_.verify!(
      issuer:    issuer,
      client_id: identifier,
      nonce:     nonce
    )
    open_id = self.open_ids.find_or_initialize_by identifier: _id_token_.subject
    if access_token.present?
      open_id.access_token = access_token.access_token
    end
    open_id.id_token = id_token
    open_id.save!
    open_id.account || Account.create!(open_id: open_id)
  end

  class << self
    def discover!(host)
      issuer = OpenIDConnect::Discovery::Provider.discover!(host).issuer
      if provider = find_by_issuer(issuer)
        provider
      else
        dynamic.create(
          issuer: issuer,
          name: host
        )
      end
    end
  end
end
