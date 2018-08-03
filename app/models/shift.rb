class Shift
  # todo: take different day shift times into account
  # todo: extract building logic
  SHIFT_START = {hour: 10, minute: 30}
  SHIFT_END = {hour: 21, minute: 30}

  attr_reader :start_time, :end_time

  def initialize(start_time:, end_time:)
    @start_time = start_time
    @end_time = end_time
  end

  def self.shift_start
    SHIFT_START
  end

  def self.shift_end
    SHIFT_END
  end

  def self.full_next_day(current_time = DateTime.now)
    if current_days_shifts_started?(current_time)
      build_next_days_full_shifts(current_time)
    else
      build_todays_full_shifts(current_time)
    end
  end

  def self.current_days_shifts_started?(current_time)
    current_time.hour > SHIFT_START[:hour] ||
      (current_time.hour == SHIFT_START[:hour] &&
       current_time.minute > SHIFT_START[:minute])
  end

  def self.build_todays_full_shifts(current_time)
    start = DateTime.civil_from_format(:local,
                                       current_time.year,
                                       current_time.month,
                                       current_time.day,
                                       SHIFT_START[:hour],
                                       SHIFT_START[:minute],
                                      0)

    end_time = DateTime.civil_from_format(:local,
                                          current_time.year,
                                          current_time.month,
                                          current_time.day,
                                          SHIFT_END[:hour],
                                          SHIFT_END[:minute],
                                         0)

    new(start_time: start, end_time: end_time)
  end

  def self.build_next_days_full_shifts(current_time)
    start = DateTime.civil_from_format(:local,
                                       current_time.year,
                                       current_time.month,
                                       current_time.day,
                                       SHIFT_START[:hour],
                                       SHIFT_START[:minute],
                                      0).advance(days: 1)

    end_time = DateTime.civil_from_format(:local,
                                          current_time.year,
                                          current_time.month,
                                          current_time.day,
                                          SHIFT_END[:hour],
                                          SHIFT_END[:minute],
                                         0).advance(days: 1)

    new(start_time: start, end_time: end_time)
  end

  def ==(other_shift)
    start_time == other_shift.start_time &&
      end_time == other_shift.end_time
  end
end
