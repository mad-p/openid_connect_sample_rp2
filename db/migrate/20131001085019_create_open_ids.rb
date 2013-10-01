class CreateOpenIds < ActiveRecord::Migration
  def change
    create_table :open_ids do |t|
      t.belongs_to :account, :provider
      t.string :identifier, null: false
      t.string :access_token
      t.string :id_token, limit: 2048
      t.timestamps
    end
  end
end
