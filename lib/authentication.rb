module Authentication
  extend ActiveSupport::Concern

  class AuthenticationRequired < StandardError; end
  class AnonymousAccessRequired < StandardError; end

  included do
    include Authentication::Helper
    before_filter :optional_authentication
    rescue_from AuthenticationRequired,  with: :authentication_required!
    rescue_from AnonymousAccessRequired, with: :anonymous_access_required!
  end

  module Helper
    def current_account
      @current_account
    end

    def authenticated?
      !current_account.blank?
    end
  end

  def authentication_required!(e)
    redirect_to root_url, flash: {
      error: e.message || 'Authentication Required'
    }
  end

  def anonymous_access_required!(e)
    redirect_to account_url
  end

  def optional_authentication
    if session[:current_account]
      authenticate Account.find_by_id(session[:current_account])
    end
  rescue ActiveRecord::RecordNotFound
    unauthenticate!
  end

  def require_authentication
    raise AuthenticationRequired.new unless authenticated?
  end

  def require_anonymous_access
    raise AnonymousAccessRequired.new if authenticated?
  end

  def authenticate(account)
    if account
      @current_account = account
      session[:current_account] = account.id
    end
  end

  def unauthenticate!
    @current_account = session[:current_account] = nil
  end
end