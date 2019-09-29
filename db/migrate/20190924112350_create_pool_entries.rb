class CreatePoolEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :pool_entries do |t|
      t.references :pool
      t.references :participant
      t.string :status, default: 'available'
    end
  end
end
