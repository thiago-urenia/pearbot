class CreatePools < ActiveRecord::Migration[6.0]
  def change
    create_table :pools do |t|
      t.string :slack_channel
      t.timestamps
    end
  end
end
