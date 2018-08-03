require 'rails_helper'

RSpec.describe Gap::Finder do
  it  do
    current_time = "1-1-2018 13:00".to_datetime
    cal_open_shift = Shift.new(start_time: '6-10-2018 10:30 -0500'.to_datetime,
                               end_time: '6-10-2018 12:00 -0500'.to_datetime)
    cal_close_shift = Shift.new(start_time: '6-10-2018 16:00 -0500'.to_datetime,
                                end_time: '6-10-2018 18:00 -0500'.to_datetime)
#    calendar_api = double(:calendar_api, taken_shifts_during: [cal_open_shift, cal_close_shift])
    full_next_day = Shift.full_next_day(current_time)
    expected_gap_shift_1 = Shift.new(start_time: '6-10-2018 12:00 -0500'.to_datetime,
                                     end_time: '6-10-2018 16:00 -0500'.to_datetime)
    expected_gap_shift_2 = Shift.new(start_time: '6-10-2018 18:00 -0500'.to_datetime,
                                     end_time: '6-10-2018 21:30 -0500'.to_datetime)

    result = Gap::Finder.new(current_time: current_time).call(look_in: full_next_day,
                                                              calendar_shifts: [cal_open_shift, cal_close_shift])

    expect(result).to eq([expected_gap_shift_1, expected_gap_shift_2])
  end
end
