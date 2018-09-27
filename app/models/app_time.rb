class AppTime
  def initialize(now = DateTime.now)
    @now = now
  end

  # TODO: change to represent time internally as UTC

  def self.fromUTC(time)
    new(time.new_offset('-0400'))
  end

  def self.current
    now
  end

  def asUTC
    now.new_offset(0)
  end

  def is_tuesday?
    now.tuesday?
  end

  def current_week
    if is_tuesday?
      start_time = now.beginning_of_day
      end_time = now.advance(days: 7).end_of_day
    else
      start_time = last_tuesday.beginning_of_day
      end_time = next_tuesday.end_of_day
    end

    Shift.new(start_time: start_time, end_time: end_time)
  end

  def now
    @offset_now ||= @now.new_offset('-0400')
  end

  private

  def last_tuesday
    tue_wday = 2
    if now.wday >= tue_wday
      tue_diff = tue_wday - now.wday
      now.advance(days: tue_diff)
    else
      week = 7
      last_tue_diff = (tue_wday - week) - now.wday
      now.advance(days: last_tue_diff)
    end
  end

  def next_tuesday
    last_tuesday.advance(days: 7)
  end
end
