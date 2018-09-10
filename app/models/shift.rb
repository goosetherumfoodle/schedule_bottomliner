require 'active_support/core_ext/integer/inflections'

class Shift
  attr_reader :start_time, :end_time

  def initialize(start_time:, end_time:)
    @start_time = start_time
    @end_time = end_time
  end

  def ==(other_shift)
    start_time == other_shift.start_time &&
      end_time == other_shift.end_time
  end

  def to_s
    "#{start_time.strftime('%a')} #{start_time.day.ordinalize}, #{start_time.strftime('%I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
  end

  def contains?(time, exclusive_buffer_mins: nil)
    if exclusive_buffer_mins
      time >= start_time.advance(minutes: exclusive_buffer_mins) &&
        time <= end_time.advance(minutes: -exclusive_buffer_mins)
    else
      time >= start_time && time <= end_time
    end
  end

  def split(time)
    return [self] if !self.contains?(time)

    first_shift = self.class.new(start_time: start_time,
                                 end_time: time)
    second_shift = self.class.new(start_time: time,
                                  end_time: end_time)

    [first_shift, second_shift]
  end
end
