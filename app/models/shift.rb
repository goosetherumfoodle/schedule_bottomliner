require 'active_support/core_ext/integer/inflections'

class Shift
  attr_reader :start_time, :end_time

  def initialize(start_time:, end_time:)
    @start_time = start_time
    @end_time = end_time
  end

  def total_minutes
    ((end_time.to_i - start_time.to_i) / 60).floor
  end

  def intersect_each(others)
    others.map { |other| intersect(other) }
  end

  def intersect(other)
    return nil if !within_inclusive?(other)
    return self if self.within?(other)
    return other if other.within?(self)

    new_start_time = [start_time, other.start_time].max
    new_end_time = [end_time, other.end_time].min
    self.class.new(start_time: new_start_time, end_time: new_end_time)
  end

  def within_inclusive?(other)
    within?(other) ||
      contains?(other.start_time) ||
      contains?(other.end_time)
  end

  def within?(outer)
    start_time >= outer.start_time &&
      end_time <= outer.end_time
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
