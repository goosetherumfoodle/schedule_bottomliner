class Splitter
  def call(gaps:, schedule_shifts:)
    out_gaps = []
    gaps.flat_map do |gap|
      split_shift = schedule_shifts.find { |shift| gap.contains?(shift.end_time, exclusive_buffer_mins: 5) }
      split_time = split_shift&.end_time

      if split_time
        gap.split(split_time)
      else
        gap
      end
    end
  end
end
