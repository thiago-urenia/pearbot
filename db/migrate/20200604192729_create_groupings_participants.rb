class CreateGroupingsParticipants < ActiveRecord::Migration[6.0]
  def change
    create_join_table :groupings, :participants do |t|
      t.index :grouping_id
      t.index :participant_id
      t.timestamps
    end
  end
end
