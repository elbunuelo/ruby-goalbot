class AddHomeTeamAndAwayTeamToEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :events, :home_team, null: false, foreign_key: { to_table: :teams }
    add_reference :events, :away_team, null: false, foreign_key: { to_table: :teams }
  end
end
