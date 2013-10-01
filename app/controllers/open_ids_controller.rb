class OpenIdsController < ApplicationController
  before_filter :require_anonymous_access

  def show
    if params[:code]
      provider = Provider.find params[:provider_id]
      authenticate provider.authenticate(
        provider_open_id_url(provider),
        params[:code],
        stored_nonce
      )
      redirect_to account_url
    end
  end

  def create
    provider = Provider.find params[:provider_id]
    redirect_to provider.authorization_uri(
      provider_open_id_url(provider),
      new_nonce
    )
  end

  private

  def code_flow_callback

  end
end
