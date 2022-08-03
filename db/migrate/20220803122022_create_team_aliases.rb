class CreateTeamAliases < ActiveRecord::Migration[7.0]
  def change
    create_table :team_aliases do |t|
      t.references :team, null: false, foreign_key: true
      t.string :alias

      t.timestamps
    end
  end
end
