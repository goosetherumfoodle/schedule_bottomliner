require 'rails_helper'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.describe CalApi do
  describe '#shifts_for_period' do
    it do
      VCR.use_cassette("synopsis") do
        current = "1-7-2018 18:00".to_datetime
        shift_1 = Shift.new(start_time: "2-7-2018 10:30 -0400".to_datetime, end_time: "2-7-2018 17:30 -0400".to_datetime)
        shift_2 = Shift.new(start_time: "2-7-2018 17:30 -0400".to_datetime, end_time: "2-7-2018 21:30 -0400".to_datetime)

        results = CalApi.new(current).shifts_for_period(Shift.next_full_day(current))

        expect(results).to eq([
          shift_1,
          shift_2
        ])
      end
    end
  end
end
