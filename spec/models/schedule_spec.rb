require 'rails_helper'

RSpec.describe Schedule do
  describe '#shifts_in_period' do
    it "returns the shifts in a given period (inclusive, all shifts for each day in period)" do
      hash = {"monday"=>[["10:30", "16:00", "name1"],
                         ["16:00", "21:00", "name2"]],
              "tuesday"=>[["10:30", "16:00", "name3"],
                          ["16:00", "17:00", "name4"]],
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

      tuesday_noon = '14-08-2018 12:00 -0400'.to_datetime
      friday_evening = tuesday_noon.advance(days: 3, hours: 10)
      three_days = Shift.new(start_time: tuesday_noon, end_time: friday_evening)

      schedule = Schedule.build(hash: hash,
                                current_time: tuesday_noon)

      expect(schedule.shifts_in_period(three_days)).to match_array([Shift.new(start_time: "14-08-2018 10:30 -0400".to_datetime,
                                                                              end_time: "14-08-2018 16:00 -0400".to_datetime),
                                                                    Shift.new(start_time: "14-08-2018 16:00 -0400".to_datetime,
                                                                              end_time: "14-08-2018 17:00 -0400".to_datetime),
                                                                    Shift.new(start_time: "15-08-2018 10:30 -0400".to_datetime,
                                                                              end_time: "15-08-2018 16:00 -0400".to_datetime),
                                                                    Shift.new(start_time: "15-08-2018 16:00 -0400".to_datetime,
                                                                              end_time: "15-08-2018 21:00 -0400".to_datetime),
                                                                    Shift.new(start_time: "16-08-2018 10:30 -0400".to_datetime,
                                                                              end_time: "16-08-2018 16:00 -0400".to_datetime),
                                                                    Shift.new(start_time: "16-08-2018 16:00 -0400".to_datetime,
                                                                              end_time: "16-08-2018 21:00 -0400".to_datetime),
                                                                    Shift.new(start_time: "17-08-2018 10:30 -0400".to_datetime,
                                                                              end_time: "17-08-2018 16:00 -0400".to_datetime),
                                                                    Shift.new(start_time: "17-08-2018 16:00 -0400".to_datetime,
                                                                              end_time: "17-08-2018 21:00 -0400".to_datetime)])
    end
  end

  describe '#next_shifts' do
    context 'on tuesday morning' do
      it 'returns the shifts for tuesday' do
        hash = {"monday"=>[["10:30", "16:00"],
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
        tuesday_morning = '14-08-2018 05:00'.to_datetime

        schedule = Schedule.build(hash: hash,
                                  current_time: tuesday_morning)

        expect(schedule.next_shifts).to match_array([Shift.new(start_time: "14-08-2018 10:30 -0400".to_datetime,
                                                               end_time: "14-08-2018 16:00 -0400".to_datetime),
                                                     Shift.new(start_time: "14-08-2018 16:00 -0400".to_datetime,
                                                               end_time: "14-08-2018 17:00 -0400".to_datetime)])
      end
    end

    context 'on sunday afternoon' do
      it 'returns the shifts for monday' do
        hash = {"monday"=>[["10:30", "16:00"],
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
        sunday_afternoon = '19-08-2018 15:00'.to_datetime

        schedule = Schedule.build(hash: hash,
                                  current_time: sunday_afternoon)

        expect(schedule.next_shifts).to match_array([Shift.new(start_time: "20-08-2018 10:30 -0400".to_datetime,
                                                               end_time: "20-08-2018 16:00 -0400".to_datetime),
                                                     Shift.new(start_time: "20-08-2018 16:00 -0400".to_datetime,
                                                               end_time: "20-08-2018 21:00 -0400".to_datetime)])
      end
    end
  end

  describe '#next_full_day' do
    it 'returns full-day shift for any day' do
      hash = {"monday"=>[["10:30", "16:00"],
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
      tuesday = '14-08-2018 05:00'.to_datetime

      schedule = Schedule.build(hash: hash,
                                current_time: tuesday)

      expect(schedule.next_full_day).to eq(Shift.new(start_time: "14-08-2018 10:30 -0400".to_datetime,
                                                     end_time: "14-08-2018 17:00 -0400".to_datetime))
    end

    context 'on a monday, before first shift start' do
      it 'creates one shift representing today\'s (unstarted) full day of shifts' do
        hash = {"monday"=>[["10:30", "16:00"],
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
        today_monday = '13-08-2018 05:00'.to_datetime

        schedule = Schedule.build(hash: hash,
                                  current_time: today_monday)

        expect(schedule.next_full_day).to eq(Shift.new(start_time: "13-08-2018 10:30 -0400".to_datetime,
                                                       end_time: "13-08-2018 21:00 -0400".to_datetime))
      end

      context 'during daylight savings time' do
        it 'created shift has correct offset for timezone' do
          timezone = 'Eastern Time (US & Canada)'
          hash = {"monday"=>[["10:30", "16:00"],
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
                  "timezone" => timezone}
          current_time_dst = '13-08-2018 05:00'.to_datetime
          expected_offset = '-04:00'


          schedule = Schedule.build(hash: hash,
                                    current_time: current_time_dst)

          expect(schedule.next_full_day.start_time.formatted_offset).to eq(expected_offset)
        end
      end

      context 'NOT during daylight savings time' do
        # TODO: need to extract timezone logic into AppTime object
        xit 'created shift has correct offset for timezone' do
          timezone = 'Eastern Time (US & Canada)'
          hash = {"monday"=>[["10:30", "16:00"],
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
                  "timezone" => timezone}
          current_time_no_dst = '01-01-2018 05:00'.to_datetime
          expected_offset = '-05:00'


          schedule = Schedule.build(hash: hash,
                                    current_time: current_time_no_dst)

          expect(schedule.next_full_day.start_time.formatted_offset).to eq(expected_offset)
        end
      end
    end

    context 'on a Friday, after shifts have already started' do
      it 'creates one shift representing the next day\'s (Saturday) full shifts' do
        # todo: cover test of empty shifts
        hash = {"monday"=>[["10:30", "16:00"],
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
        current_time = '17-08-2018 11:00'.to_datetime

        schedule = Schedule.build(hash: hash,
                                  current_time: current_time)

        expect(schedule.next_full_day).to eq(Shift.new(start_time: "18-08-2018 10:30 -0400".to_datetime,
                                                       end_time: "18-08-2018 19:00 -0400".to_datetime))
      end
    end
  end
end
