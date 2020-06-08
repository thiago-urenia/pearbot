class ChangePairingsToGroupings < ActiveRecord::Migration[6.0]
  def change
    rename_table :pairings, :groupings
  end
end
