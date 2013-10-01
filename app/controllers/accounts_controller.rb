class AccountsController < ApplicationController
  before_filter :require_authentication

  def show
    @open_id = current_account.open_id
    @userinfo = @open_id.userinfo! if @open_id.userinfo_available?
  end
end
