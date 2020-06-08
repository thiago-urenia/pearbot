class DropPairingsParticipants < ActiveRecord::Migration[6.0]
  def change
    drop_join_table :pairings, :participants do |t|
      t.index :participant_id
      t.index :pairing_id
      t.timestamps
    end
  end
end
