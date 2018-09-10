class Schedule
  # todo: report sub-day expect shifts, instead of just the full day

  def initialize(mondays:,
                 tuesdays:,
                 wednesdays:,
                 thursdays:,
                 fridays:,
                 saturdays:,
                 sundays:,
                 timezone:,
                 current_time:
                )
    @current_time = current_time
    @monday_times = mondays
    @tuesday_times = tuesdays
    @wednesday_times = wednesdays
    @thursday_times = thursdays
    @friday_times = fridays
    @saturday_times = saturdays
    @sunday_times = sundays
    @timezone = timezone
  end

  def self.build(hash:, current_time:)
    new(mondays: hash['monday'],
        tuesdays: hash['tuesday'],
        wednesdays: hash['wednesday'],
        thursdays: hash['thursday'],
        fridays: hash['friday'],
        saturdays: hash['saturday'],
        sundays: hash['sunday'],
        timezone: hash['timezone'],
        current_time: current_time
       )
  end

  def next_shifts
    if already_started?
      tomorrow_shifts
    else
      current_day_shifts
    end
  end

  def next_full_day
    if already_started?
      tomorrow_full_day
    else
      current_full_day
    end
  end

  def full_day_shift_for(day)
    Shift.new(start_time: day.change(hour: hours(start_time(first_shift(times_for(day)))),
                                     min: minutes(start_time(first_shift(times_for(day)))),
                                     offset: offset),
              end_time: day.change(hour: hours(end_time(last_shift(times_for(day)))),
                                   min: minutes(end_time(last_shift(times_for(day)))),
                                   offset: offset))
  end

  private
  attr_reader :current_time,
              :monday_times,
              :tuesday_times,
              :wednesday_times,
              :thursday_times,
              :friday_times,
              :saturday_times,
              :sunday_times,
              :timezone

  def offset
    current_time.in_time_zone(timezone).formatted_offset
  end

  def tomorrow
    current_time.advance(days: 1)
  end

  def already_started?
    current_time.hour >= hours(start_time(first_shift(todays_times)))
  end

  def tomorrow_full_day
    full_day_shift_for(tomorrow)
  end

  def tomorrow_shifts
    shifts_for(tomorrow)
  end

  def current_day_shifts
    shifts_for(current_time)
  end

  def current_full_day
    full_day_shift_for(current_time)
  end

  def todays_times
    times_for(current_time)
  end

  def tomorrows_times
    times_for(tomorrow)
  end

  def first_shift(times)
    times.first
  end

  def last_shift(times)
    times.last
  end

  def start_time(shift)
    shift.first
  end

  def end_time(shift)
    shift.last
  end

  def times_for(day)
    day_key = day.strftime('%^a')
    day_map[day_key]
  end

  def day_map
    {'MON' => monday_times,
     'TUE' => tuesday_times,
     'WED' => wednesday_times,
     'THU' => thursday_times,
     'FRI' => friday_times,
     'SAT' => saturday_times,
     'SUN' => sunday_times}
  end

  def hours(string)
    string.match(/\A(\d{2}):\d{2}\z/)[1].to_i
  end

  def minutes(string)
    string.match(/\A\d{2}:(\d{2})\z/)[1].to_i
  end

  def shifts_for(day)
    times_for(day).map do |start_end|
      Shift.new(start_time: day.change(hour: hours(start_time(start_end)),
                                       min: minutes(start_time(start_end)),
                                       offset: offset), # TODO: if this is giving me the current day offset, it should mess up the next day's time (on the day before DST)
                end_time: day.change(hour: hours(end_time(start_end)),
                                     min: minutes(end_time(start_end)),
                                     offset: offset))
    end
  end
end
