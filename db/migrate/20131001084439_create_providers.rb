class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.belongs_to :account
      t.string :identifier, :secret, :issuer, :name, :jwks_uri
      t.string :authorization_endpoint, :token_endpoint, :scopes_supported, :response_types_supported, :userinfo_endpoint
      t.boolean :dynamic, default: false
      t.datetime :expires_at
      t.timestamps
    end
  end
end
