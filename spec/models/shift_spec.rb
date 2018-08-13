require 'rails_helper'

RSpec.describe Shift do
  describe 'equality' do
    context 'with different start and end times' do
      it 'is unequal' do
        start_1 = "3-1-2018 10:30 -0500".to_datetime
        end_1 = "3-1-2018 10:30 -0500".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)

        start_2 = "5-5-3333 00:00 -0500".to_datetime
        end_2 = "10-10-5555 01:00 -0500".to_datetime
        shift_2 = Shift.new(start_time: start_2,
                            end_time: end_2)

        expect(shift_1 == shift_2).to be_falsey
      end
    end

    context 'with the same start and end times' do
      it 'is equal' do
        start_1 = "3-1-2018 10:30 -0500".to_datetime
        end_1 = "3-1-2018 10:30 -0500".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)

        start_2 = "3-1-2018 10:30 -0500".to_datetime
        end_2 = "3-1-2018 10:30 -0500".to_datetime
        shift_2 = Shift.new(start_time: start_2,
                            end_time: end_2)

        expect(shift_1 == shift_2).to be_truthy
      end
    end
  end

  describe 'string format' do
    it 'formats as human-readable start and end times' do
      start_1 = "3-1-2018 10:30 -0500".to_datetime
      end_1 = "3-1-2018 15:00 -0500".to_datetime
      shift_1 = Shift.new(start_time: start_1,
                          end_time: end_1)
      expected = 'Wed 3rd, 10:30 - 03:00'

      expect(shift_1.to_s).to eq(expected)
    end
  end
end
