class CreateRounds < ActiveRecord::Migration[6.0]
  def change
    create_table :rounds do |t|
      t.references :pool
      t.timestamps
    end
  end
end
