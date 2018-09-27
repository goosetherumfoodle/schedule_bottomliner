class Contact < ActiveRecord::Base
  default_scope { where('suspended_until IS NULL OR suspended_until < ?', AppTime.new.asUTC) }

  scope :testers, -> { where(tester: true) }

  def suspend_this_week!
    # suspend until the last day of the week
    self.suspended_until = AppTime.new.current_week.end_time.change(days: -1)
    self.save!
  end
end
