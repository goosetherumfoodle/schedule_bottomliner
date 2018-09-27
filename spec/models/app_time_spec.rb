require 'rails_helper'

RSpec.describe AppTime do
  describe '#current_week' do
    context 'on a tuesday' do
      it 'gets tue-tue range through next week\'s tuesday' do
        tuesday_noon = '14-08-2018 12:00 -0400'.to_datetime

        result = AppTime.new(tuesday_noon).current_week

        expected = Shift.new(start_time: tuesday_noon.beginning_of_day,
                             end_time: tuesday_noon.advance(days: 7).end_of_day)

        expect(result).to eq(expected)
      end
    end

    context 'on a Monday' do
      it 'gets range of last Tuesday to this tuesday' do
        monday_noon = '13-08-2018 12:00 -0400'.to_datetime

        result = AppTime.new(monday_noon).current_week

        expected = Shift.new(start_time: monday_noon.advance(days: -6).beginning_of_day,
                             end_time: monday_noon.advance(days: 1).end_of_day)

        expect(result).to eq(expected)
      end
    end
  end
end
