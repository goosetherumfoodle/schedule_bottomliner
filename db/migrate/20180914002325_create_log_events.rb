class CreateLogEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :log_events do |t|
      t.string :description
      t.json :data
    end
  end
end
