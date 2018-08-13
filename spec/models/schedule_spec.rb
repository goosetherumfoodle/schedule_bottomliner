require 'rails_helper'

RSpec.describe Schedule do
  describe '#full_day_for' do
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
                         ["16:00", "19:00"]]}
      tuesday = '14-08-2018 05:00 -0500'.to_datetime

      schedule = Schedule.build(hash: hash,
                                current_time: tuesday)

      expect(schedule.next_full_day).to eq(Shift.new(start_time: "14-08-2018 10:30 -0500".to_datetime,
                                                     end_time: "14-08-2018 17:00 -0500".to_datetime))
    end
  end

  describe '#next_full_day' do
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
                           ["16:00", "19:00"]]}
        today_monday = '13-08-2018 05:00 -0500'.to_datetime

        schedule = Schedule.build(hash: hash,
                                  current_time: today_monday)

        expect(schedule.next_full_day).to eq(Shift.new(start_time: "13-08-2018 10:30 -0500".to_datetime,
                                                       end_time: "13-08-2018 21:00 -0500".to_datetime))
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
                           ["16:00", "19:00"]]}
        current_time = '17-08-2018 11:00 -0500'.to_datetime

        schedule = Schedule.build(hash: hash,
                                  current_time: current_time)

        expect(schedule.next_full_day).to eq(Shift.new(start_time: "18-08-2018 10:30 -0500".to_datetime,
                                                       end_time: "18-08-2018 19:00 -0500".to_datetime))
      end
    end
  end
end
