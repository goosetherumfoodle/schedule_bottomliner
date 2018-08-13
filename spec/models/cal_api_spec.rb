require 'rails_helper'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.describe CalApi do
  describe '#shifts_for_period' do
    it do
      VCR.use_cassette('basic') do
        current = "1-7-2018 18:00".to_datetime # todo: remove `current`
        shift_1 = Shift.new(start_time: "2-7-2018 10:30 -0400".to_datetime, end_time: "2-7-2018 17:30 -0400".to_datetime)
        shift_2 = Shift.new(start_time: "2-7-2018 17:30 -0400".to_datetime, end_time: "2-7-2018 21:30 -0400".to_datetime)

        results = CalApi.new(current).shifts_for_period(Shift.next_full_day(current))

        expect(results).to eq([
          shift_1,
          shift_2
        ])
      end
    end

    context 'with a shift overlapping the period start-time' do
      it 'captures the overlapping shifts, and ignores non-overlapping shift' do
        VCR.use_cassette('overlapping_shifts') do
          current = "12-8-2018 18:00".to_datetime # todo: remove `current`
          early_shift = Shift.new(start_time: "13-8-2018 10:00 -0400".to_datetime, end_time: "13-8-2018 12:00 -0400".to_datetime)
          late_shift = Shift.new(start_time: "13-8-2018 17:00 -0400".to_datetime, end_time: "13-8-2018 22:00 -0400".to_datetime)
          off_hours_shift = Shift.new(start_time: "13-8-2018 02:00 -0400".to_datetime, end_time: "13-8-2018 05:00 -0400".to_datetime)

          results = CalApi.new(current).shifts_for_period(Shift.next_full_day(current))

          expect(results).to eq([early_shift, late_shift])
        end
      end
    end
  end
end
