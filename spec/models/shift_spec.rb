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
      expected = 'Wed 3rd, 10:30 AM - 03:00 PM'

      expect(shift_1.to_s).to eq(expected)
    end
  end

  describe '#contains?' do
    context 'with a shift within a exclusive buffer' do
      it 'is falsey' do
        exclusive_minutes = 10
        start_1 = "3-1-2018 10:30 -0500".to_datetime
        end_1 = "3-1-2018 15:00 -0500".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)
        query_time = "3-1-2018 14:55 -0500".to_datetime

        results = shift_1.contains?(query_time,
                                    exclusive_buffer_mins: exclusive_minutes)

        expect(results).to be_falsey
      end
    end

    context 'with a time it contains' do
      it 'is truthy' do
        start_1 = "3-1-2018 10:30 -0500".to_datetime
        end_1 = "3-1-2018 15:00 -0500".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)
        query_time = "3-1-2018 12:00 -0500".to_datetime

        expect(shift_1.contains?(query_time)).to be_truthy
      end
    end

    context 'with a time it does not contain' do
      it 'is falsey' do
        start_1 = "3-1-2018 10:30 -0500".to_datetime
        end_1 = "3-1-2018 15:00 -0500".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)
        query_time = "3-1-2018 18:00 -0500".to_datetime

        expect(shift_1.contains?(query_time)).to be_falsey
      end
    end
  end

  describe '#split?' do
    context 'with a time it contains' do
      it 'returns two shifts split by the new time' do
        orig_start = "3-1-2018 10:30 -0500".to_datetime
        orig_end = "3-1-2018 15:00 -0500".to_datetime
        orig_shift = Shift.new(start_time: orig_start,
                               end_time: orig_end)
        split_time = "3-1-2018 12:00 -0500".to_datetime

        new_1 = Shift.new(start_time: orig_start,
                          end_time: split_time)
        new_2 = Shift.new(start_time: split_time,
                          end_time: orig_end)

        results = orig_shift.split(split_time)

        expect(results).to eq([new_1, new_2])
      end
    end

    context 'with a time it does not contain' do
      it 'returns an array of itself' do
        orig_start = "3-1-2018 10:30 -0500".to_datetime
        orig_end = "3-1-2018 15:00 -0500".to_datetime
        orig_shift = Shift.new(start_time: orig_start,
                               end_time: orig_end)
        split_time = "3-1-2018 18:00 -0500".to_datetime

        new_1 = Shift.new(start_time: orig_start,
                          end_time: split_time)
        new_2 = Shift.new(start_time: split_time,
                          end_time: orig_end)

        results = orig_shift.split(split_time)

        expect(results).to eq([orig_shift])
      end
    end
  end
end
