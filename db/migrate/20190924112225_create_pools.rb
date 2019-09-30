class CreatePools < ActiveRecord::Migration[6.0]
  def change
    create_table :pools do |t|
      t.string :slack_channel_id, null: false
      t.timestamps

      # t.index :slack_channel_id, unique: true, name: "idx_pools_slack_channel_id"
    end
  end
end
