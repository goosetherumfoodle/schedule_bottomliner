require 'active_support/core_ext/integer/inflections'

class Shift
  attr_reader :start_time, :end_time, :name

  def initialize(name: nil, start_time:, end_time:)
    @start_time = start_time
    @end_time = end_time
    @name = name
  end

  def join(other_shift)
    return self unless other_shift

    self.class.new(start_time: start_time, end_time: other_shift.end_time)
  end

  def total_minutes
    @total_minutes ||= ((end_time.to_i - start_time.to_i) / 60).floor
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

  def eq(other_shift, fudge_mins: nil)
    return self == other_shift unless fudge_mins

    start_diff_mins = (start_time.to_i - other_shift.start_time.to_i).abs / 60
    end_diff_mins = (end_time.to_i - other_shift.end_time.to_i).abs / 60

    start_diff_mins <= fudge_mins && end_diff_mins <= fudge_mins
  end

  def to_s
    return named_to_s if name

    start_minute_display = start_time.minute == 0 ? '' : start_time.strftime(':%M')
    end_minute_display = end_time.minute == 0 ? '' : end_time.strftime(':%M')
    day = start_time.today? ? 'Today' : start_time.strftime('%a')

    "#{day} #{start_time.strftime('%l')}#{start_minute_display} to #{end_time.strftime('%l')}#{end_minute_display}"
  end

  def full_name
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

  private

  def named_to_s
    day = start_time.today? ? 'Today' : start_time.strftime('%a')

    "#{day} #{name}"
  end
end
