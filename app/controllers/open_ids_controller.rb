class OpenIdsController < ApplicationController
  before_filter :require_anonymous_access, :require_provider_context

  def show
    if params[:code]
      code_flow_callback
    else
      implicit_flow_callback
    end
  end

  def create
    redirect_to @provider.authorization_uri(
      provider_open_id_url(@provider),
      new_nonce
    )
  end

  private

  def require_provider_context
    @provider ||= Provider.find params[:provider_id]
  end

  def code_flow_callback
    authenticate @provider.authenticate(
      provider_open_id_url(provider),
      params[:code],
      stored_nonce
    )
    redirect_to account_url
  end

  def implicit_flow_callback
    # in JS
  end
end
