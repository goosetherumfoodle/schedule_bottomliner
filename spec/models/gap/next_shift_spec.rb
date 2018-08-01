require_relative '../../../app/models/gap/next_shift'

RSpec.describe Gap::NextShift do
  describe '::call' do
    it 'does shit' do
      gap_shift_1 = double(:shift_1)
      gap_shift_2 = double(:shift_2)
      gap_finder = double(:gap_finder, call: [gap_shift_1, gap_shift_2])
      gap_finder_class = double(:gap_finder_class, new: gap_finder)
      next_day_shift = double(:next_day_shift)
      shift = double(:shift, next_full_day: next_day_shift)

      results = Gap::NextShift.new(gap_finder: gap_finder_class,
                                  shift_class: shift).call

      expect(results).to eq([gap_shift_1, gap_shift_2])
    end
  end
end
