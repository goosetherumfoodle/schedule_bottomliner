module Gap
  class Finder
    ACCEPTABLE_GAP_MINUTES = 40

    def initialize(current_time:, schedule:)
      # todo: remove current_time?
      @schedule = schedule
      # TODO: remove splitter, extract other logic
      @splitter = Splitter.new
    end

    def call(look_in:, calendar_shifts:)
      schedule_shifts = schedule.shifts_in_period(look_in)
      raw_gaps = gaps_within_period(look_in, calendar_shifts).
                   flat_map { |raw_gap| raw_gap.intersect_each(schedule_shifts) }.
                   compact.
                   select { |shift| shift.total_minutes > 10 }

      join_small_gaps(raw_gaps)
    end

    def join_small_gaps(raw_gaps)
      init = {gaps: [], small_gap: nil}

      reduced = raw_gaps.reduce(init) do |hash, gap|
        if hash[:small_gap]
          if gap.total_minutes <= 90
            # previous gap was small, and the current gap is small
            joined_gap = hash[:small_gap].join(gap)
            {gaps: hash[:gaps].append(joined_gap),
             small_gap: nil}
          else # previous gap was small, but the current isn't
            {gaps: hash[:gaps].append(hash[:small_gap]).append(gap),
             small_gap: nil}
          end
        else
          if gap.total_minutes <= 90
            # previous gap wasn't small, but current gap is
            {gaps: hash[:gaps],
             small_gap: gap}
          else # neither current nor previous gap are small
            {gaps: hash[:gaps].append(gap),
             small_gap: nil}
          end
        end
      end

      if reduced[:small_gap]
        reduced[:gaps].append[:small_gap]
      else
        reduced[:gaps]
      end
    end

    def gaps_within_period(period, shifts)
      relevent_shifts = shifts.select { |shift| shift.within_inclusive?(period) }
      opening = opening_gap(period, relevent_shifts)
      middle = middle_gaps(period, relevent_shifts)
      closing = closing_gap(period, relevent_shifts)

      opening.concat(middle.concat(closing))
    end

    def middle_gaps(period, shifts)
      return [] if shifts.empty?

      first_shift = shifts.first
      rest_shifts = shifts[1..-1]
      init = {gaps: [], prev_shift: first_shift}
      rest_shifts.reduce(init) do |hash, shift|
        prev_shift = hash[:prev_shift]
        diff_seconds = shift.start_time.to_i - prev_shift.end_time.to_i
        pos_diff_seconds = [0, diff_seconds].max
        diff_minutes = seconds_to_minutes(pos_diff_seconds)

        if diff_minutes > ACCEPTABLE_GAP_MINUTES
          gap_shift = Shift.new(start_time: prev_shift.end_time, end_time: shift.start_time)
          {gaps: hash[:gaps].append(gap_shift),
           prev_shift: shift}
        else
          hash.merge({prev_shift: shift})
        end
      end[:gaps]
    end

    def closing_gap(period, shifts)
      return [] if shifts.empty?

      last_shift = shifts.last
      diff_seconds = period.end_time.to_i - last_shift.end_time.to_i
      pos_diff_seconds = [0, diff_seconds].max
      diff_minutes = seconds_to_minutes(pos_diff_seconds)

      if diff_minutes > ACCEPTABLE_GAP_MINUTES
        [Shift.new(start_time: period.end_time.advance(minutes: -diff_minutes),
                   end_time: period.end_time)]
      else
        []
      end
    end

    def opening_gap(period, shifts)
      return [] if shifts.empty?

      first_shift = shifts.first
      diff_seconds = first_shift.start_time.to_i - period.start_time.to_i
      pos_diff_seconds = [0, diff_seconds].max
      diff_minutes = seconds_to_minutes(pos_diff_seconds)

      if diff_minutes > ACCEPTABLE_GAP_MINUTES
        [Shift.new(start_time: period.start_time,
                   end_time: period.start_time.advance(minutes: diff_minutes))]
      else
        []
      end
    end

    private
    attr_reader :calendar_api, :schedule, :splitter

    def seconds_to_minutes(seconds)
      (seconds / 60).floor
    end

    # def raw_gaps(look_in:, calendar_shifts:)
    #   schedule_shifts = schedule.shifts_in_period(look_in)
    #   schedule_shifts.flat_map do |sched_shift|
    #     sched_day = sched_shift.start_time.to_date
    #     cal_shifts_on_day = calendar_shifts.select { |cal_shift| cal_shift.start_time.to_date == sched_day }
    #     gaps_within_period(sched_shift, cal_shifts_on_day)
    #   end
    # end

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
      # TODO: either use or remove this. Should be unix?
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

    #     def schedule_for_day(day)
    #   @next_day_shifts ||= schedule.shifts_in_period(day)
    # end

    # def full_day_for(day)
    #   Shift.new(start_time: schedule_for_day(day).first.start_time,
    #             end_time: schedule_for_day(day).last.end_time)
    # end
  end
end
