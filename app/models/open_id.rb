class OpenId < ActiveRecord::Base
  belongs_to :account
  belongs_to :provider

  validates :identifier, uniqueness: {scope: :provider_id}

  def userinfo_available?
    access_token.present? &&
    provider.userinfo_available?
  end

  def userinfo!
    OpenIDConnect::AccessToken.new(
      access_token: access_token,
      client: provider.client
    ).userinfo!
  end

  def check_id!
    provider.decode_id id_token
  end
end
