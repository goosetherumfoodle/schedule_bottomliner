require 'rails_helper'

RSpec.describe Gap::NextShift do
  describe '::call' do
    it 'does shit' do
      # todo: extract knowledge of store schedule (from Shift)
      # todo: allow shifts to overlap on the hour minute (like: [12-2, 2-5])

      schedule_hash = {"monday"=>[["10:30", "16:00"],
                                  ["16:00", "21:00"]],
                       "tuesday"=>[["10:30", "16:00"],
                                   ["16:00", "17:00"]],
                       "wednesday"=>[["10:30", "16:00"],
                                     ["16:00", "21:00"]],
                       "thursday"=>[["10:30", "16:00"],
                                    ["16:00", "21:00"]],
                       "friday"=>[["10:30", "16:00"],
                                  ["16:00", "21:00"]],
                       "saturday"=>[["10:30", "16:00"],
                                    ["16:00", "19:00"]],
                       "sunday"=>[["10:30", "16:00"],
                                  ["16:00", "19:00"]],
                       "timezone" => 'Eastern Time (US & Canada)'}

      current_time = '5-10-2018 18:00 -0400'.to_datetime

      schedule = Schedule.build(hash: schedule_hash,
                                current_time: current_time)

      gap_shift_1 = Shift.new(start_time: '6-10-2018 12:00 -0400'.to_datetime,
                              end_time: '6-10-2018 16:00 -0400'.to_datetime)
      gap_shift_2 = Shift.new(start_time: '6-10-2018 18:00 -0400'.to_datetime,
                              end_time: '6-10-2018 19:00 -0400'.to_datetime)

      cal_open_shift = Shift.new(start_time: '6-10-2018 10:30 -0400'.to_datetime,
                                 end_time: '6-10-2018 12:00 -0400'.to_datetime)
      cal_close_shift = Shift.new(start_time: '6-10-2018 16:00 -0400'.to_datetime,
                                  end_time: '6-10-2018 18:00 -0400'.to_datetime)

      cal_api = double(:cal_api, shifts_for_period: [cal_open_shift,
                                                     cal_close_shift])
      cal_api_class = double(:cal_api_class, new: cal_api)

      results = Gap::NextShift.new(shift_class: Shift,
                                   calendar_api: cal_api_class,
                                   current_time: current_time,
                                   schedule: schedule).call

      expect(results).to eq([gap_shift_1, gap_shift_2])
    end
  end
end
