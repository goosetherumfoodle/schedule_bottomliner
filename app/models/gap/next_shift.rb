require_relative './finder'
require_relative '../shift'
require_relative '../cal_api'

module Gap
  class NextShift
    def initialize(opts = {})
      @gap_finder_class = opts[:gap_finder] || Gap::Finder
      @shift_class = opts[:shift_class] || Shift
      @current_time = opts[:current_time] || Time.now
      @calendar_api = opts[:calendar_api] || CalApi
      @schedule = opts[:schedule] || raise(ArgumentError, 'GAP::NextShift must be initailized with a schedule')
    end

    def call
      gap_finder.call(look_in: next_shift,
                      calendar_shifts: calendar_shifts)
    end

    private
    attr_reader :current_time, :shift_class, :calendar_api, :schedule

    def calendar_shifts
      calendar_api.new.shifts_for_period(next_shift)
    end

    def gap_finder
      @gap_finder_class.new(current_time: current_time,
                           schedule: schedule)
    end

    def next_shift
      @next_shift ||= schedule.next_full_day
    end
  end
end
