require 'rails_helper'

RSpec.describe Gap::Finder do
  describe 'with a full-day gap' do
    it 'reports the expected schedule slots as gaps' do
      # TODO: remove dependence on `full_day` and just use the schedule
      # TODO: consider allowing for gaps in shift schedules (this assumes they're abutting)
      reference_shifts = [Shift.new(start_time: '12-8-2018 10:30 -0400'.to_datetime,
                                    end_time: '12-08-2018 15:00 -0400'.to_datetime),
                          Shift.new(start_time: '12-08-2018 15:00 -0400'.to_datetime,
                                    end_time: '12-08-2018 21:30 -0400'.to_datetime)]
      schedule = double(:schedule, next_shifts: reference_shifts)

      current_time = "5-10-2018 13:00 -0400".to_datetime # todo: why doesn't this matter?

      full_next_day = Shift.new(start_time: '12-08-2018 10:30 -0400'.to_datetime,
                                end_time: '12-08-2018 21:30 -0400'.to_datetime)

      result = Gap::Finder.new(current_time: current_time,
                               schedule: schedule).call(look_in: full_next_day,
                                                        calendar_shifts: [])

      expect(result).to eq(reference_shifts)
    end
  end

  describe 'with only a closing-shift gap' do
    it 'reports the closing shift gap' do
      # todo: refactor to just use schedule shifts instead of full_next_day
      reference_shifts = [Shift.new(start_time: '12-08-2018 10:30 -0400'.to_datetime,
                                    end_time: '12-08-2018 15:00 -0400'.to_datetime),
                          Shift.new(start_time: '12-08-2018 15:00 -0400'.to_datetime,
                                    end_time: '12-08-2018 21:30 -0400'.to_datetime)]
      schedule = double(:schedule, next_shifts: reference_shifts)

      current_time = "5-10-2018 13:00".to_datetime # todo: why doesn't this matter?

      full_next_day = Shift.new(start_time: '12-08-2018 10:30 -0400'.to_datetime,
                                end_time: '12-08-2018 21:30 -0400'.to_datetime)

      calendar_shifts = [reference_shifts.first]

      result = Gap::Finder.new(current_time: current_time,
                               schedule: schedule).call(look_in: full_next_day,
                                                        calendar_shifts: calendar_shifts)

      expect(result).to eq([reference_shifts.second])
    end
  end

  # TODO: update for shift-split gaps
  xit 'finding two gaps' do
    # todo: why are the reference shift dates so different from the cal dates?!
    reference_shift = Shift.new(start_time: '12-8-2018 10:30 -0400'.to_datetime,
                                end_time: '12-08-2018 21:30 -0400'.to_datetime)
    schedule = double(:schedule, full_day_shift_for: reference_shift)


    current_time = "5-10-2018 13:00".to_datetime # todo: why doesn't this matter?

    cal_open_shift = Shift.new(start_time: '6-10-2018 10:30 -0500'.to_datetime,
                               end_time: '6-10-2018 12:00 -0500'.to_datetime)
    cal_close_shift = Shift.new(start_time: '6-10-2018 16:00 -0500'.to_datetime,
                                end_time: '6-10-2018 18:00 -0500'.to_datetime)

    full_next_day = Shift.new(start_time: '6-10-2018 10:30 -0400'.to_datetime,
                              end_time: '6-10-2018 21:30 -0400'.to_datetime)


    expected_gap_shift_1 = Shift.new(start_time: '6-10-2018 12:00 -0500'.to_datetime,
                                     end_time: '6-10-2018 16:00 -0500'.to_datetime)
    expected_gap_shift_2 = Shift.new(start_time: '6-10-2018 18:00 -0500'.to_datetime,
                                     end_time: '6-10-2018 21:30 -0500'.to_datetime)

    result = Gap::Finder.new(current_time: current_time,
                             schedule: schedule).call(look_in: full_next_day,
                                                      calendar_shifts: [cal_open_shift, cal_close_shift])

    expect(result).to eq([expected_gap_shift_1, expected_gap_shift_2])
  end

  context 'with no shifts scheduled for the next day' do
    # TODO: update for shift-split gaps
    xit  do
      # todo: return both open and close shifts
      reference_shift = Shift.new(start_time: '12-8-2018 10:30 -0400'.to_datetime,
                                  end_time: '12-08-2018 21:30 -0400'.to_datetime)
      schedule = double(:schedule, full_day_shift_for: reference_shift)


      current_time = "5-10-2018 13:00".to_datetime

      full_next_day = Shift.new(start_time: '6-10-2018 10:30 -0400'.to_datetime,
                                end_time: '6-10-2018 21:30 -0400'.to_datetime)

      expected_gap_shift_1 = Shift.new(start_time: '6-10-2018 10:30 -0400'.to_datetime,
                                       end_time: '6-10-2018 21:30 -0400'.to_datetime)

      result = Gap::Finder.new(current_time: current_time,
                               schedule: schedule).call(look_in: full_next_day,
                                                        calendar_shifts: [])

      expect(result).to eq([expected_gap_shift_1])
    end
  end

  context 'with overlapping and off-hours shifts' do
    # TODO: update for shift-split gaps
    xit 'creates correct gap shifts, ignoring off-hours shift' do
      # todo: return both open and close shifts
      reference_shift = Shift.new(start_time: '12-8-2018 10:30 -0400'.to_datetime,
                                  end_time: '12-08-2018 21:30 -0400'.to_datetime)
      schedule = double(:schedule, full_day_shift_for: reference_shift)

      current = "12-8-2018 18:00".to_datetime # todo: remove `current`
      next_full_day = Shift.new(start_time: '13-8-2018 10:30 -0400'.to_datetime,
                                end_time: '13-08-2018 21:30 -0400'.to_datetime)

      early_shift = Shift.new(start_time: "13-8-2018 10:00 -0400".to_datetime, end_time: "13-8-2018 12:00 -0400".to_datetime)
      late_shift = Shift.new(start_time: "13-8-2018 17:00 -0400".to_datetime, end_time: "13-8-2018 22:00 -0400".to_datetime)
      off_hours_early_shift = Shift.new(start_time: "13-8-2018 02:00 -0400".to_datetime, end_time: "13-8-2018 05:00 -0400".to_datetime)
      off_hours_late_shift = Shift.new(start_time: "13-8-2018 23:00 -0400".to_datetime, end_time: "13-8-2018 23:59 -0400".to_datetime)

      expected_gap = Shift.new(start_time: "13-8-2018 12:00 -0400".to_datetime, end_time: "13-8-2018 17:00 -0400".to_datetime)

      result = Gap::Finder.new(current_time: current,
                               schedule: schedule).call(look_in: next_full_day,
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
