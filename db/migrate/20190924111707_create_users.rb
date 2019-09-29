class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :slack_user_id, null: false
      t.timestamps

      # t.index :slack_user_id, unique: true, name: "idx_users_slack_user_id"
    end
  end
end
