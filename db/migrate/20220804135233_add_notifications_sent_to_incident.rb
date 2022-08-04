class AddNotificationsSentToIncident < ActiveRecord::Migration[7.0]
  def change
    add_column :incidents, :notifications_sent, :boolean
  end
end
