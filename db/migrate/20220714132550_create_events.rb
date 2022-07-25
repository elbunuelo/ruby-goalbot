class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :start_timestamp
      t.integer :previous_leg_ss_id
      t.integer :ss_id
      t.string :slug

      t.timestamps
    end
  end
end
