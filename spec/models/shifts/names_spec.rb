require 'rails_helper'

RSpec.describe Shifts::Names do
  describe '#call' do
    it 'gives each shift a name if it corresponds to one' do
      # TODO: make an integration test, or mock boundaries
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

      monday_time = '13-08-2018 10:32 -0400'.to_datetime
      monday_shift = Shift.new(start_time: monday_time, end_time: monday_time.advance(hours: 5, minutes: 30))

      wednesday_time = monday_time.advance(days: 2, hours: 10)
      wednesday_shift = Shift.new(start_time: wednesday_time, end_time: wednesday_time.advance(hours: 5))

      schedule = Schedule.build(hash: hash,
                                current_time: monday_time)

      monday_named = Shifts::Names.new(schedule).call(monday_shift)
      wednesday_named = Shifts::Names.new(schedule).call(wednesday_shift)

      expect(monday_named).to eq(monday_shift)
      expect(monday_named.name).to eq('name1')
      expect(wednesday_named).to eq(wednesday_shift)
      expect(wednesday_named.name).to be_falsey
    end
  end
end
