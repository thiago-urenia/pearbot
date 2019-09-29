class CreatePairingsUsers < ActiveRecord::Migration[6.0]
  def change
    create_join_table :pairings, :users do |t|
      t.index :user_id
      t.index :pairing_id
      t.timestamps
    end
  end
end
