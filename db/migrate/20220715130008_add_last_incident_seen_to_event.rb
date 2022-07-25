class AddLastIncidentSeenToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :last_incident_seen, :integer
  end
end
