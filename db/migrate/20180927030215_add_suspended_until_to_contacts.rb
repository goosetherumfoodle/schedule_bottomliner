class AddSuspendedUntilToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :suspended_until, :datetime
  end
end
