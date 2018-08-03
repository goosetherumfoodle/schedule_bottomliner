module Gap
  class Finder
    ACCEPTABLE_GAP_MINUTES = 40

    def initialize(current_time:)
      @current_time = current_time
    end

    def call(look_in:, calendar_shifts:)
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

    private
    attr_reader :calendar_api

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
      end_hour = Shift.shift_end[:hour]
      end_minute = Shift.shift_end[:minute]
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
      start_hour = Shift.shift_start[:hour]
      start_minute = Shift.shift_start[:minute]
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
  end
end
