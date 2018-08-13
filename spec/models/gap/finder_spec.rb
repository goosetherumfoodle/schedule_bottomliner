require 'rails_helper'

RSpec.describe Gap::Finder do
  it  do
    current_time = "5-10-2018 13:00".to_datetime # todo: why doesn't this matter?

    cal_open_shift = Shift.new(start_time: '6-10-2018 10:30 -0500'.to_datetime,
                               end_time: '6-10-2018 12:00 -0500'.to_datetime)
    cal_close_shift = Shift.new(start_time: '6-10-2018 16:00 -0500'.to_datetime,
                                end_time: '6-10-2018 18:00 -0500'.to_datetime)

    full_next_day = Shift.next_full_day(current_time)
    expected_gap_shift_1 = Shift.new(start_time: '6-10-2018 12:00 -0500'.to_datetime,
                                     end_time: '6-10-2018 16:00 -0500'.to_datetime)
    expected_gap_shift_2 = Shift.new(start_time: '6-10-2018 18:00 -0500'.to_datetime,
                                     end_time: '6-10-2018 21:30 -0500'.to_datetime)

    result = Gap::Finder.new(current_time: current_time).call(look_in: full_next_day,
                                                              calendar_shifts: [cal_open_shift, cal_close_shift])

    expect(result).to eq([expected_gap_shift_1, expected_gap_shift_2])
  end

  context 'with no shifts scheduled for the next day' do
    it  do
      # todo: return both open and close shifts
      current_time = "5-10-2018 13:00".to_datetime

      full_next_day = Shift.next_full_day(current_time)
      expected_gap_shift_1 = Shift.new(start_time: '6-10-2018 10:30 -0400'.to_datetime,
                                       end_time: '6-10-2018 21:30 -0400'.to_datetime)

      result = Gap::Finder.new(current_time: current_time).call(look_in: full_next_day,
                                                                calendar_shifts: [])

      expect(result).to eq([expected_gap_shift_1])
    end
  end

  context 'with overlapping and off-hours shifts' do
    it 'creates correct gap shifts, ignoring off-hours shift' do
      # todo: return both open and close shifts
      # todo: remove dep in tests on `Shift::next_full_day`
      current = "12-8-2018 18:00".to_datetime # todo: remove `current`
      next_full_day = Shift.next_full_day(current)

      early_shift = Shift.new(start_time: "13-8-2018 10:00 -0400".to_datetime, end_time: "13-8-2018 12:00 -0400".to_datetime)
      late_shift = Shift.new(start_time: "13-8-2018 17:00 -0400".to_datetime, end_time: "13-8-2018 22:00 -0400".to_datetime)
      off_hours_early_shift = Shift.new(start_time: "13-8-2018 02:00 -0400".to_datetime, end_time: "13-8-2018 05:00 -0400".to_datetime)
      off_hours_late_shift = Shift.new(start_time: "13-8-2018 23:00 -0400".to_datetime, end_time: "13-8-2018 23:59 -0400".to_datetime)

      expected_gap = Shift.new(start_time: "13-8-2018 12:00 -0400".to_datetime, end_time: "13-8-2018 17:00 -0400".to_datetime)

      result = Gap::Finder.new(current_time: current).call(look_in: next_full_day,
                                                           calendar_shifts: [
                                                             early_shift,
                                                             late_shift,
                                                             off_hours_early_shift,
                                                             off_hours_late_shift
                                                           ])

      expect(result).to eq([expected_gap])
    end
  end
end
