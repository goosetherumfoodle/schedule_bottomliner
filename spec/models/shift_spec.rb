require 'rails_helper'

RSpec.describe Shift do
  describe '#join' do
    context 'with nil' do
      it 'returns itself' do
        base_time = "3-1-2018 10:30 -0400".to_datetime
        start_time = base_time
        end_time = base_time.advance(hours: 5)
        expected_shift = Shift.new(start_time: start_time,
                                   end_time: end_time)

        result = expected_shift.join(nil)

        expect(result).to eq(expected_shift)
      end
    end

    context 'with another shift' do
      it 'returns a new shift that encompases both shift times' do
        base_time = "3-1-2018 10:30 -0400".to_datetime
        start_1 = base_time
        end_1 = base_time.advance(hours: 1)
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)

        start_2 = base_time.advance(hours: 1)
        end_2 = base_time.advance(hours: 5)
        shift_2 = Shift.new(start_time: start_2,
                            end_time: end_2)

        start_3 = base_time
        end_3 = base_time.advance(hours: 5)
        expected_shift = Shift.new(start_time: start_3,
                                   end_time: end_3)

        result = shift_1.join(shift_2)

        expect(result).to eq(expected_shift)
      end
    end
  end

  describe '#intersect' do
    context 'with subset shifts' do
      it 'returns the intersection of the shifts' do
        base_time = "3-1-2018 10:30 -0400".to_datetime
        larger = Shift.new(start_time: base_time,
                           end_time: base_time.advance(hours: 5))
        smaller = Shift.new(start_time: base_time.advance(hours: 1),
                            end_time: base_time.advance(hours: 3))

        expect(larger.intersect(smaller)).to eq(smaller)
        expect(smaller.intersect(larger)).to eq(smaller)
      end

      it 'a set intersecting itself' do
        base_time = "3-1-2018 10:30 -0400".to_datetime
        first = Shift.new(start_time: base_time,
                          end_time: base_time.advance(hours: 5))
        same = Shift.new(start_time: base_time,
                         end_time: base_time.advance(hours: 5))


        expect(first.intersect(same)).to eq(first)
        expect(same.intersect(first)).to eq(same)
      end
    end

    context 'with overlapping shifts' do
      it 'returns the intersection shift' do
        base_time = "3-1-2018 10:30 -0400".to_datetime
        first = Shift.new(start_time: base_time,
                          end_time: base_time.advance(hours: 5))
        second = Shift.new(start_time: base_time.advance(hours: 4, minutes: 20),
                           end_time: base_time.advance(hours: 8))

        expected_intersection = Shift.new(start_time: base_time.advance(hours: 4, minutes: 20),
                                          end_time: base_time.advance(hours: 5))

        expect(first.intersect(second)).to eq(expected_intersection)
        expect(second.intersect(first)).to eq(expected_intersection)
      end
    end

    context 'with adjacent shifts' do
      it 'returns nil' do
        base_time = "3-1-2018 10:30 -0400".to_datetime
        first = Shift.new(start_time: base_time,
                          end_time: base_time.advance(hours: 5))
        second = Shift.new(start_time: base_time.advance(hours: 6),
                           end_time: base_time.advance(hours: 8))

        expect(first.intersect(second)).to be_falsey
        expect(second.intersect(first)).to be_falsey
      end
    end
  end

  describe '#intersect_each' do
    it 'intersects a collection of shifts, returning a collection' do
      base_time = "3-1-2018 10:30 -0400".to_datetime
      first = Shift.new(start_time: base_time,
                        end_time: base_time.advance(hours: 5))

      second = Shift.new(start_time: base_time.advance(hours: -1),
                         end_time: base_time.advance(hours: 2))

      third = Shift.new(start_time: base_time.advance(hours: 3),
                        end_time: base_time.advance(hours: 7))

      expected_intersection = [Shift.new(start_time: base_time,
                                         end_time: base_time.advance(hours: 2)),
                               Shift.new(start_time: base_time.advance(hours: 3),
                                         end_time: base_time.advance(hours: 5))]

      expect(first.intersect_each([second, third])).to eq(expected_intersection)
    end
  end

  describe 'equality' do
    context 'with different start and end times' do
      it 'is unequal' do
        start_1 = "3-1-2018 10:30 -0400".to_datetime
        end_1 = "3-1-2018 10:30 -0400".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)

        start_2 = "5-5-3333 00:00 -0400".to_datetime
        end_2 = "10-10-5555 01:00 -0400".to_datetime
        shift_2 = Shift.new(start_time: start_2,
                            end_time: end_2)

        expect(shift_1 == shift_2).to be_falsey
      end
    end

    context 'with the same start and end times' do
      it 'is equal' do
        start_1 = "3-1-2018 10:30 -0400".to_datetime
        end_1 = "3-1-2018 10:30 -0400".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)

        start_2 = "3-1-2018 10:30 -0400".to_datetime
        end_2 = "3-1-2018 10:30 -0400".to_datetime
        shift_2 = Shift.new(start_time: start_2,
                            end_time: end_2)

        expect(shift_1 == shift_2).to be_truthy
      end
    end

    describe 'fudging the minutes' do
      context 'two shifts with start times within the fudge range' do
        it 'are equal' do
          start_1 = "3-1-2018 10:35 -0400".to_datetime
          end_1 = "3-1-2018 10:30 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)

          start_2 = "3-1-2018 10:30 -0400".to_datetime
          end_2 = "3-1-2018 10:30 -0400".to_datetime
          shift_2 = Shift.new(start_time: start_2,
                              end_time: end_2)

          expect(shift_1.eq(shift_2, fudge_mins: 5)).to be_truthy
        end
      end

      context 'two shifts with end times within the fudge range' do
        it 'are equal' do
          start_1 = "3-1-2018 10:30 -0400".to_datetime
          end_1 = "3-1-2018 10:35 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)

          start_2 = "3-1-2018 10:30 -0400".to_datetime
          end_2 = "3-1-2018 10:30 -0400".to_datetime
          shift_2 = Shift.new(start_time: start_2,
                              end_time: end_2)

          expect(shift_1.eq(shift_2, fudge_mins: 5)).to be_truthy
        end
      end

      context 'two shifts with greater start_time differance than the fudge range' do
        it 'are NOT equal' do
          start_1 = "3-1-2018 10:40 -0400".to_datetime
          end_1 = "3-1-2018 10:30 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)

          start_2 = "3-1-2018 10:30 -0400".to_datetime
          end_2 = "3-1-2018 10:30 -0400".to_datetime
          shift_2 = Shift.new(start_time: start_2,
                              end_time: end_2)

          expect(shift_1.eq(shift_2, fudge_mins: 5)).to be_falsey
        end
      end
    end

    describe 'string format' do
      describe 'default' do
        context 'without a name' do
          it 'formats as human-readable start and end times' do
            start_1 = "3-1-2018 10:30 -0400".to_datetime
            end_1 = "3-1-2018 15:00 -0400".to_datetime
            shift_1 = Shift.new(start_time: start_1,
                                end_time: end_1)
            expected = 'Wed 10:30 to  3'

            expect(shift_1.to_s).to eq(expected)
          end
        end

        context 'wit a name' do
          it 'displays day and name' do
            start_1 = "3-1-2018 10:30 -0400".to_datetime
            end_1 = "3-1-2018 15:00 -0400".to_datetime
            name = 'Open'
            shift_1 = Shift.new(start_time: start_1,
                                end_time: end_1,
                                name: name)
            expected = 'Wed Open'

            expect(shift_1.to_s).to eq(expected)
          end
        end
      end

      describe 'full name' do
        it 'formats as human-readable start and end times' do
          start_1 = "3-1-2018 10:30 -0400".to_datetime
          end_1 = "3-1-2018 15:00 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)
          expected = 'Wed 3rd, 10:30 AM - 03:00 PM'

          expect(shift_1.full_name).to eq(expected)
        end
      end
    end

    describe '#contains?' do
      context 'with a shift within a exclusive buffer' do
        it 'is falsey' do
          exclusive_minutes = 10
          start_1 = "3-1-2018 10:30 -0400".to_datetime
          end_1 = "3-1-2018 15:00 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)
          query_time = "3-1-2018 14:55 -0400".to_datetime

          results = shift_1.contains?(query_time,
                                      exclusive_buffer_mins: exclusive_minutes)

          expect(results).to be_falsey
        end
      end

      context 'with a time it contains' do
        it 'is truthy' do
          start_1 = "3-1-2018 10:30 -0400".to_datetime
          end_1 = "3-1-2018 15:00 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)
          query_time = "3-1-2018 12:00 -0400".to_datetime

          expect(shift_1.contains?(query_time)).to be_truthy
        end
      end

      context 'with a time it does not contain' do
        it 'is falsey' do
          start_1 = "3-1-2018 10:30 -0400".to_datetime
          end_1 = "3-1-2018 15:00 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)
          query_time = "3-1-2018 18:00 -0400".to_datetime

          expect(shift_1.contains?(query_time)).to be_falsey
        end
      end
    end

    describe '#within?' do
      context 'with another shift that it is within' do
        it 'is truthy' do
          time = "03-01-2018 10:30 -0400".to_datetime
          outer = Shift.new(start_time: time,
                            end_time: time.advance(hours: 10))
          inner = Shift.new(start_time: time.advance(hours: 3),
                            end_time: time.advance(hours: 7))

          expect(inner.within?(outer)).to be_truthy
        end
      end

      context 'with another shift that it is equal to' do
        it 'is falsey' do
          time = "03-01-2018 10:30 -0400".to_datetime
          shift = Shift.new(start_time: time,
                            end_time: time.advance(hours: 3))
          same = Shift.new(start_time: time,
                           end_time: time.advance(hours: 3))

          expect(shift.within?(same)).to be_truthy
        end
      end

      context 'with another shift that is within it' do
        it 'is falsey' do
          time = "03-01-2018 10:30 -0400".to_datetime
          shift = Shift.new(start_time: time,
                            end_time: time.advance(hours: 10))
          smaller = Shift.new(start_time: time.advance(hours: 3),
                              end_time: time.advance(hours: 6))

          expect(shift.within?(smaller)).to be_falsey
          expect(smaller.within?(shift)).to be_truthy
        end
      end

      context 'with another shift that it is adjacent to' do
        it 'is falsey' do
          time = "03-01-2018 10:30 -0400".to_datetime
          adjacent = Shift.new(start_time: time,
                               end_time: time.advance(hours: 3))
          inner = Shift.new(start_time: time.advance(hours: 5),
                            end_time: time.advance(hours: 7))

          expect(inner.within?(adjacent)).to be_falsey
        end
      end

      context 'with another shift that it is within but has the same start time' do
        it 'is falsey' do
          time = "03-01-2018 10:30 -0400".to_datetime
          outer = Shift.new(start_time: time,
                            end_time: time.advance(hours: 5))
          inner = Shift.new(start_time: time,
                            end_time: time.advance(hours: 4))

          expect(inner.within?(outer)).to be_truthy
        end
      end
    end

    describe '#total_minutes' do
      context 'a 1-hour shift' do
        it 'returns the total minutes between the start and end times' do
          time = "03-01-2018 10:30 -0400".to_datetime
          shift = Shift.new(start_time: time,
                            end_time: time.advance(hours: 2))

          expect(shift.total_minutes).to eq(120)
        end
      end

      context 'a 24-hour shift' do
        it 'returns total minutes' do
          time = "03-01-2018 10:30 -0400".to_datetime
          shift = Shift.new(start_time: time,
                            end_time: time.advance(days: 1))

          expect(shift.total_minutes).to eq(1440)
        end
      end
    end

    describe '#within_inclusive' do
      context 'with another shift that has overlapping times' do
        it 'is truthy' do
          time = "03-01-2018 10:30 -0400".to_datetime
          outer = Shift.new(start_time: time,
                            end_time: time.advance(hours: 5))
          inner = Shift.new(start_time: time.advance(hours: 4),
                            end_time: time.advance(hours: 7))

          expect(inner.within_inclusive?(outer)).to be_truthy
        end
      end
    end

    describe '#split?' do
      context 'with a time it contains' do
        it 'returns two shifts split by the new time' do
          orig_start = "3-1-2018 10:30 -0400".to_datetime
          orig_end = "3-1-2018 15:00 -0400".to_datetime
          orig_shift = Shift.new(start_time: orig_start,
                                 end_time: orig_end)
          split_time = "3-1-2018 12:00 -0400".to_datetime

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
          orig_start = "3-1-2018 10:30 -0400".to_datetime
          orig_end = "3-1-2018 15:00 -0400".to_datetime
          orig_shift = Shift.new(start_time: orig_start,
                                 end_time: orig_end)
          split_time = "3-1-2018 18:00 -0400".to_datetime

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
end
