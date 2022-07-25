class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :event, null: false, foreign_key: true
      t.string :service
      t.string :conversation_id

      t.timestamps
    end
  end
end
