module Gap
  class Finder
    ACCEPTABLE_GAP_MINUTES = 40

    def initialize(current_time:, schedule:)
      # todo: remove this?
      @schedule = schedule
      @splitter = Splitter.new
    end

    def call(look_in:, calendar_shifts:)
      gaps = raw_gaps(look_in: look_in, calendar_shifts: calendar_shifts)
      splitter.call(schedule_shifts: schedule_for_next_day,
                    gaps: gaps)
    end

    private
    attr_reader :calendar_api, :schedule, :splitter

    def raw_gaps(look_in:, calendar_shifts:)
      calendar_shifts = shifts_within_period(look_in, calendar_shifts)
      return [look_in] if calendar_shifts.empty?

      init = {prev_shift: open_bookend_shift(calendar_shifts.first),
              gaps: []}
      append_close_bookend(calendar_shifts).reduce(init) do |accum, taken_shift|
        if minute_diff(accum[:prev_shift].end_time, taken_shift.start_time) > ACCEPTABLE_GAP_MINUTES
          gap = gap_shift(accum[:prev_shift].end_time, taken_shift.start_time)
          accum[:prev_shift] = taken_shift
          accum[:gaps] = accum[:gaps].append(gap)
          accum
        else
          accum[:prev_shift] = taken_shift
          accum
        end
      end[:gaps]
    end

    def shifts_within_period(period, shifts)
      shifts.select do |shift|
        shift.end_time >= period.start_time &&
          shift.start_time <= period.end_time
      end
    end


    def gap_shift(first_end, second_start)
      Shift.new(start_time: first_end, end_time: second_start)
    end

    def minute_diff(first_end, second_start)
      minutes_since_midnight(second_start) - minutes_since_midnight(first_end)
    end

    def minutes_since_midnight(time)
      time.seconds_since_midnight / 60
    end

    def append_close_bookend(shifts)
      shifts.append(close_bookend_shift(shifts.last))
    end

    def close_bookend_shift(last_taken_shift)
      # todo: extract this dep, isolate schedule knowlege
      end_hour = full_day_for(last_taken_shift).end_time.hour
      end_minute = full_day_for(last_taken_shift).end_time.minute
      bookend_start = last_taken_shift.
                        end_time.
                        change(hour: end_hour,
                               min: end_minute)
      bookend_end = bookend_start.
                      advance(hours: 1)

      Shift.new(start_time: bookend_start,
                end_time: bookend_end)

    end

    def open_bookend_shift(first_taken_shift)
      # todo: extract this dep, isolate schedule knowlege
      start_hour = full_day_for(first_taken_shift).start_time.hour
      start_minute = full_day_for(first_taken_shift).start_time.minute
      bookend_end = first_taken_shift.
                      start_time.
                      change(hour: start_hour,
                             min: start_minute).
                      advance(minutes: -1)
      bookend_start = bookend_end.
                        advance(hours: -1)

      Shift.new(start_time: bookend_start,
                end_time: bookend_end)
    end

    def schedule_for_next_day
      @next_day_shifts ||= schedule.next_shifts
    end

    def full_day_for(day)
      Shift.new(start_time: schedule_for_next_day.first.start_time,
                end_time: schedule_for_next_day.last.end_time)
    end
  end
end
