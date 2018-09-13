require 'rails_helper'

RSpec.describe Gap::Finder do
  describe '#join_small_gaps' do
    context 'with two small shifts next to eachother' do
      it 'collapses them' do
        base_time = '01-01-2018 12:00 -0400'.to_datetime
        first_shift = Shift.new(start_time: base_time, end_time: base_time.advance(hours: 3))
        small_shift_1 = Shift.new(start_time: base_time.advance(hours: 3), end_time: base_time.advance(hours: 3, minutes: 30))
        small_shift_2 = Shift.new(start_time: base_time.advance(hours: 3, minutes: 30), end_time: base_time.advance(hours: 4))
        last_shift = Shift.new(start_time: base_time.advance(hours: 4), end_time: base_time.advance(hours: 6))

        expected_middle = Shift.new(start_time: base_time.advance(hours: 3), end_time: base_time.advance(hours: 4))
        expected = [first_shift, expected_middle, last_shift]

        schedule = Schedule.build(hash: {}, current_time: base_time)
        finder = Gap::Finder.new(current_time: base_time, schedule: schedule)
        result = finder.join_small_gaps([first_shift, small_shift_1, small_shift_2, last_shift])

        expect(result).to eq(expected)
      end
    end

    context 'with a small shift next to a larger shift' do
      it 'leaves them be' do
        base_time = '01-01-2018 12:00 -0400'.to_datetime
        first_shift = Shift.new(start_time: base_time, end_time: base_time.advance(hours: 3))
        small_shift = Shift.new(start_time: base_time.advance(hours: 3), end_time: base_time.advance(hours: 3, minutes: 30))
        last_shift = Shift.new(start_time: base_time.advance(hours: 4), end_time: base_time.advance(hours: 6))

        expected = [first_shift, small_shift, last_shift]

        schedule = Schedule.build(hash: {}, current_time: base_time)
        finder = Gap::Finder.new(current_time: base_time, schedule: schedule)
        result = finder.join_small_gaps([first_shift, small_shift, last_shift])

        expect(result).to match_array(expected)
      end
    end
  end

  describe '#gaps_within_period' do
    it 'finds opening gap' do
      current_time = "01-01-2018 18:00 -0400".to_datetime
      schedule = Schedule.build(hash: {}, current_time: current_time)

      period_start = current_time.advance(days: 1)
      period_end = period_start.advance(hours: 5)

      period = Shift.new(start_time: period_start, end_time: period_end)

      shift = Shift.new(start_time: period_start.advance(hours: 1),
                        end_time: period_end)

      finder = Gap::Finder.new(current_time: current_time, schedule: schedule)


      expected_gaps = [Shift.new(start_time: period_start,
                                 end_time: period_start.advance(hours:1))]

      results = finder.gaps_within_period(period, [shift])

      expect(results).to eq(expected_gaps)
    end

    it 'finds closing gap' do
      current_time = "01-01-2018 18:00 -0400".to_datetime
      schedule = Schedule.build(hash: {}, current_time: current_time)

      period_start = current_time.advance(days: 1)
      period_end = period_start.advance(hours: 5)

      period = Shift.new(start_time: period_start, end_time: period_end)

      shift = Shift.new(start_time: period_start,
                        end_time: period_end.advance(hours: -1))

      finder = Gap::Finder.new(current_time: current_time, schedule: schedule)


      expected_gaps = [Shift.new(start_time: period_end.advance(hours: -1),
                                 end_time: period_end)]

      results = finder.gaps_within_period(period, [shift])

      expect(results).to eq(expected_gaps)
    end

    it 'finds opening *AND* closing gap' do
      current_time = "01-01-2018 12:00 -0400".to_datetime
      schedule = Schedule.build(hash: {}, current_time: current_time)

      period_start = current_time.advance(days: 1)
      period_end = period_start.advance(hours: 6)

      period = Shift.new(start_time: period_start, end_time: period_end)

      shift_1 = Shift.new(start_time: period_start.advance(hours: 1),
                          end_time: period_start.advance(hours: 3))
      shift_2 = Shift.new(start_time: period_start.advance(hours: 3),
                          end_time: period_end.advance(hours: -1))

      finder = Gap::Finder.new(current_time: current_time, schedule: schedule)


      expected_gaps = [Shift.new(start_time: period_start,
                                 end_time: period_start.advance(hours: 1)),
                       Shift.new(start_time: period_start.advance(hours: 5),
                                 end_time: period_end)]

      results = finder.gaps_within_period(period, [shift_1, shift_2])

      expect(results).to eq(expected_gaps)
    end

    it 'finds middle gaps' do
      current_time = "01-01-2018 12:00 -0400".to_datetime
      schedule = Schedule.build(hash: {}, current_time: current_time)

      period_start = current_time.advance(days: 1)
      period_end = period_start.advance(hours: 8)

      period = Shift.new(start_time: period_start, end_time: period_end)

      shift_1 = Shift.new(start_time: period_start,
                          end_time: period_start.advance(hours: 3))
      shift_2 = Shift.new(start_time: period_start.advance(hours: 4),
                          end_time: period_start.advance(hours: 5))
      shift_3 = Shift.new(start_time: period_start.advance(hours: 6),
                          end_time: period_end)

      finder = Gap::Finder.new(current_time: current_time, schedule: schedule)


      expected_gaps = [Shift.new(start_time: period_start.advance(hours: 3),
                                 end_time: period_start.advance(hours: 4)),
                       Shift.new(start_time: period_start.advance(hours: 5),
                                 end_time: period_start.advance(hours: 6))]

      results = finder.gaps_within_period(period, [shift_1, shift_2, shift_3])

      expect(results).to eq(expected_gaps)
    end

    it 'finds open, middle and close gaps' do
      current_time = "01-01-2018 12:00 -0400".to_datetime
      schedule = Schedule.build(hash: {}, current_time: current_time)

      period_start = current_time.advance(days: 1)
      period_end = period_start.advance(hours: 8)

      period = Shift.new(start_time: period_start, end_time: period_end)

      shift_1 = Shift.new(start_time: period_start.advance(hours: 1),
                          end_time: period_start.advance(hours: 4))
      shift_2 = Shift.new(start_time: period_start.advance(hours: 5),
                          end_time: period_start.advance(hours: 6))
      shift_3 = Shift.new(start_time: period_start.advance(hours: 7),
                          end_time: period_end.advance(minutes: -55))

      finder = Gap::Finder.new(current_time: current_time, schedule: schedule)

      expected_gaps = [Shift.new(start_time: period_start,
                                 end_time: period_start.advance(hours: 1)),
                       Shift.new(start_time: period_start.advance(hours: 4),
                                 end_time: period_start.advance(hours: 5)),
                       Shift.new(start_time: period_start.advance(hours: 6),
                                 end_time: period_start.advance(hours: 7)),
                       Shift.new(start_time: period_start.advance(hours: 7, minutes: 5),
                                 end_time: period_end)]

      results = finder.gaps_within_period(period, [shift_1, shift_2, shift_3])

      expect(results).to eq(expected_gaps)
    end

    context 'with shifts that exactly fit the period' do
      it 'returns empty collection' do
        current_time = "01-01-2018 18:00 -0400".to_datetime
        schedule = Schedule.build(hash: {}, current_time: current_time)

        period_start = current_time.advance(days: 1)
        period_end = period_start.advance(hours: 5)

        period = Shift.new(start_time: period_start, end_time: period_end)

        shift_1 = Shift.new(start_time: period_start,
                            end_time: period_start.advance(hours: 2))
        shift_2 = Shift.new(start_time: period_start.advance(hours: 2),
                            end_time: period_end)

        finder = Gap::Finder.new(current_time: current_time, schedule: schedule)


        expected_gaps = [Shift.new(start_time: period_start,
                                   end_time: period_start.advance(hours:1))]

        results = finder.gaps_within_period(period, [shift_1, shift_2])

        expect(results).to eq([])
      end
    end

    context 'with a shift that contains the period' do
      it 'returns empty collection' do
        current_time = "01-01-2018 18:00 -0400".to_datetime
        schedule = Schedule.build(hash: {}, current_time: current_time)

        period_start = current_time.advance(days: 1)
        period_end = period_start.advance(hours: 5)

        period = Shift.new(start_time: period_start, end_time: period_end)

        shift = Shift.new(start_time: period_start.advance(minutes: -30),
                          end_time: period_end.advance(minutes: 30))


        finder = Gap::Finder.new(current_time: current_time, schedule: schedule)


        expected_gaps = [Shift.new(start_time: period_start,
                                   end_time: period_start.advance(hours:1))]

        results = finder.gaps_within_period(period, [shift])

        expect(results).to eq([])
      end
    end
  end

  describe 'finding a week\'s shifts' do
    it 'reports each shift from the schedule not covered' do
      current_time = "01-01-2018 18:00 -0400".to_datetime
      two_days_ahead = current_time.advance(days: 2, hours: 6)
      next_two_days = Shift.new(start_time: current_time,
                                end_time: two_days_ahead)

      tomorrows_shifts = [Shift.new(start_time: "02-01-2018 10:30 -0400".to_datetime,
                                    end_time: "02-01-2018 13:00 -0400".to_datetime),
                          Shift.new(start_time: "02-01-2018 13:00 -0400".to_datetime,
                                    end_time: "02-01-2018 15:00 -0400".to_datetime)]

      #TODO: stub out actual schedule
      File.open('./schedule.yml') do |schedule_file|
        schedule_hash = YAML.load(schedule_file.read)
        schedule = Schedule.build(hash: schedule_hash, current_time: current_time)
        openings = Gap::Finder.new(current_time: current_time, schedule: schedule).
                     call(look_in: next_two_days, calendar_shifts: tomorrows_shifts)

        expected_openings = [
          Shift.new(start_time: '01-01-2018 18:00 -0400'.to_datetime,
                    end_time: '01-01-2018 21:00 -0400'.to_datetime),

          # TODO: create some filtering to merge small shifts together,
          #       like the two below.

          Shift.new(start_time: '02-01-2018 15:00 -0400'.to_datetime,
                    end_time: '02-01-2018 16:00 -0400'.to_datetime),

          Shift.new(start_time: '02-01-2018 16:00 -0400'.to_datetime,
                    end_time: '02-01-2018 17:00 -0400'.to_datetime),

          Shift.new(start_time: '03-01-2018 10:30 -0400'.to_datetime,
                    end_time: '03-01-2018 16:00 -0400'.to_datetime),

          Shift.new(start_time: '03-01-2018 16:00 -0400'.to_datetime,
                    end_time: '03-01-2018 21:00 -0400'.to_datetime)
        ]

        expect(openings).to eq(expected_openings)
      end
    end
  end

  describe 'with a full-day gap' do
    xit 'reports the expected schedule slots as gaps' do
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
    xit 'reports the closing shift gap' do
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
