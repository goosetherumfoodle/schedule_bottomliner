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
end
