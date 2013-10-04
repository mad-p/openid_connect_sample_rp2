class ApplicationController < ActionController::Base
  include Authentication
  include Concerns::Notification
  include Concerns::NonceManagement

  protect_from_forgery with: :exception

  rescue_from(
    Rack::OAuth2::Client::Error,
    OpenIDConnect::Exception,
    MultiJson::LoadError,
    OpenSSL::SSL::SSLError
  ) do |e|
    flash[:error] = if e.message.length > 2000
      'Unknown Error'
    else
      e.message
    end
    unauthenticate!
    redirect_to root_url
  end
end
