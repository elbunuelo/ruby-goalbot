class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :slug
      t.string :short_name
      t.string :ss_id

      t.timestamps
    end
  end
end
