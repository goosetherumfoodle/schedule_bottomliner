module Gap
  class NextShift
    def initialize(opts = {})
      @gap_finder_class = opts[:gap_finder] || Gap::Finder
      @shift_class = opts[:shift_class] || Shift
      @current_time = opts[:current_time] || Time.now
    end

    def call
      gap_finder.call(next_shift)
    end

    private
    attr_reader :current_time, :shift_class

    def gap_finder
      @gap_finder_class.new(current_time: current_time)
    end

    def next_shift
      shift_class.next_full_day(current_time: current_time)
    end
  end
end
