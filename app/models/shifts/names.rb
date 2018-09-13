module Shifts
  class Names
    def initialize(schedule)
      @schedule = schedule
    end

    def call(shift)
      found_name = schedule.shifts_and_names_for_day(shift.start_time).find do |schedule_shift|
        shift.eq(schedule_shift[:shift], fudge_mins: 15)
      end&.fetch(:name, nil)

      if found_name
        Shift.new(start_time: shift.start_time, end_time: shift.end_time, name: found_name)
      else
        shift
      end
    end

    private
    attr_reader :schedule
  end
end
