class CreateLeagues < ActiveRecord::Migration[7.0]
  def change
    create_table :leagues do |t|
      t.string :name
      t.integer :ss_id

      t.timestamps
    end
  end
end
