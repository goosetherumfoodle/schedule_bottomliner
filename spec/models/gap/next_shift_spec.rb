require 'rails_helper'

RSpec.describe Gap::NextShift do
  describe '::call' do
    it 'does shit' do
      # todo: extract knowledge of store schedule (from Shift)
      # todo: allow shifts to overlap on the hour minute (like: [12-2, 2-5])
      current_time = '5-10-2018 18:00 -0500'.to_datetime

      gap_shift_1 = Shift.new(start_time: '6-10-2018 12:00 -0500'.to_datetime,
                              end_time: '6-10-2018 16:00 -0500'.to_datetime)
      gap_shift_2 = Shift.new(start_time: '6-10-2018 18:00 -0500'.to_datetime,
                              end_time: '6-10-2018 21:30 -0500'.to_datetime)

      cal_open_shift = Shift.new(start_time: '6-10-2018 10:30 -0500'.to_datetime,
                                 end_time: '6-10-2018 12:00 -0500'.to_datetime)
      cal_close_shift = Shift.new(start_time: '6-10-2018 16:00 -0500'.to_datetime,
                                  end_time: '6-10-2018 18:00 -0500'.to_datetime)

      cal_api = double(:cal_api, shifts_for_period: [cal_open_shift,
                                                     cal_close_shift])
      cal_api_class = double(:cal_api_class, new: cal_api)

      results = Gap::NextShift.new(shift_class: Shift,
                                   calendar_api: cal_api_class,
                                   current_time: current_time).call

      expect(results).to eq([gap_shift_1, gap_shift_2])
    end
  end
end
