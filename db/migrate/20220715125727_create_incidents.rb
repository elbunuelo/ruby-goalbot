class CreateIncidents < ActiveRecord::Migration[7.0]
  def change
    create_table :incidents do |t|
      t.references :event, null: false, foreign_key: true
      t.string :player_name, null: true
      t.string :reason, null: true
      t.string :incident_class
      t.string :incident_type
      t.integer :time
      t.integer :ss_id, null: true
      t.boolean :is_home, null: true
      t.string :text, null: true
      t.integer :home_score, null: true
      t.integer :away_score, null: true
      t.integer :added_time, null: true
      t.string :player_in, null: true
      t.string :player_out, null: true
      t.integer :length, null: true
      t.string :description, null: true

      t.timestamps
    end
  end
end
