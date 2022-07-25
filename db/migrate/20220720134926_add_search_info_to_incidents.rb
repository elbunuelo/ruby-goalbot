class AddSearchInfoToIncidents < ActiveRecord::Migration[7.0]
  def change
    add_column :incidents, :searching_since, :datetime, null: true
    add_column :incidents, :video_url, :string, null: true
    add_column :incidents, :search_suspended, :boolean, default: false
  end
end
