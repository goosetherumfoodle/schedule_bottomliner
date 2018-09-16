class AddTimestamps < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :contacts
    add_timestamps :log_events
  end
end
