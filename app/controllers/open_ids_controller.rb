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
    if params[:id_token]
      authenticate @provider.authenticate(
        id_token: params[:id_token],
        nonce:    stored_nonce
      )
      redirect_to account_url
    else
      redirect_to @provider.authorization_uri(
        provider_open_id_url(@provider),
        new_nonce
      )
    end
  end

  private

  def require_provider_context
    @provider ||= Provider.find params[:provider_id]
  end

  def code_flow_callback
    authenticate @provider.authenticate(
      redirect_uri: provider_open_id_url(provider),
      code:         params[:code],
      nonce:        stored_nonce
    )
    redirect_to account_url
  end

  def implicit_flow_callback
    # in JS
  end
end
