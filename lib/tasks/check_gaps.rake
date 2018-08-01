require_relative '../../app/models/gap/next_shift'

namespace :gaps do
  desc "Check and alert if next-day gaps are found"
  task :next_shift do
    Gap::NextShift.new.call
  end
end
