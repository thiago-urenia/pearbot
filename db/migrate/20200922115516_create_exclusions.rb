class CreateExclusions < ActiveRecord::Migration[6.0]
  def change
    create_table :exclusions do |t|
      t.references :excluder
      t.references :excluded_participant
      t.timestamps
    end

    add_foreign_key :exclusions, :participants, column: :excluder_id, primary_key: :id
    add_foreign_key :exclusions, :participants, column: :excluded_participant_id, primary_key: :id
  end
end
