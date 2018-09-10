RSpec.describe Splitter do
  describe '#call' do
    it 'splits gaps by schedule shifts' do
      gaps = [Shift.new(start_time: '6-10-2018 12:00 -0500'.to_datetime,
                        end_time: '6-10-2018 18:00 -0500'.to_datetime)]
      schedule = [Shift.new(start_time: '6-10-2018 10:00 -0500'.to_datetime,
                            end_time: '6-10-2018 15:00 -0500'.to_datetime),
                 Shift.new(start_time: '6-10-2018 15:00 -0500'.to_datetime,
                            end_time: '6-10-2018 19:00 -0500'.to_datetime)]

      expected = [Shift.new(start_time: '6-10-2018 12:00 -0500'.to_datetime,
                            end_time: '6-10-2018 15:00 -0500'.to_datetime),
                 Shift.new(start_time: '6-10-2018 15:00 -0500'.to_datetime,
                            end_time: '6-10-2018 18:00 -0500'.to_datetime)]

      results = Splitter.new.call(gaps: gaps, schedule_shifts: schedule)

      expect(results).to match_array(expected)
    end
  end
end
