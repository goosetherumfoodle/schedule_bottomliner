require_relative '../../../app/models/gap/next_shift'

RSpec.describe Gap::NextShift do
  describe '::call' do
    it 'does shit' do
      # todo: extract knowledge of store schedule (from Shift)
      # todo: allow shifts to overlap on the hour minute (like: [12-2, 2-5])
      current_time = "5-10-2018 18:00 -0500".to_datetime

      gap_shift_1 = Shift.new(start_time: '6-10-2018 12:00 -0500'.to_datetime,
                              end_time: '6-10-2018 16:00 -0500'.to_datetime)
      gap_shift_2 = Shift.new(start_time: '6-10-2018 18:00 -0500'.to_datetime,
                              end_time: '6-10-2018 21:30 -0500'.to_datetime)

      # gap_finder = double(:gap_finder, call: [gap_shift_1, gap_shift_2])
      # gap_finder_class = double(:gap_finder_class, new: gap_finder)

      next_day_shift = Shift.full_next_day(current_time)

      shift = double(:shift, next_full_day: next_day_shift)

      cal_open_shift = Shift.new(start_time: '6-10-2018 10:30 -0500'.to_datetime,
                                 end_time: '6-10-2018 12:00 -0500'.to_datetime)
      cal_close_shift = Shift.new(start_time: '6-10-2018 16:00 -0500'.to_datetime,
                                  end_time: '6-10-2018 18:00 -0500'.to_datetime)

      cal_api = double(:cal_api, shifts_for_period: [cal_open_shift,
                                                     cal_close_shift])

      results = Gap::NextShift.new(shift_class: shift,
                                   calendar_api: cal_api).call

      expect(results).to eq([gap_shift_1, gap_shift_2])
    end
  end
end
