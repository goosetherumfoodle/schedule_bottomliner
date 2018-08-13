require_relative '../../app/models/gap/next_shift'
require_relative '../../app/models/schedule'

namespace :gaps do
  desc "Check and alert if next-day gaps are found"
  task :next_shift do
    File.open('./schedule.yml') do |f|
      schedule_hash = YAML.load(f.read)
      time = DateTime.now
      schedule = Schedule.build(hash: schedule_hash, current_time: time)
      puts Gap::NextShift.new(schedule: schedule).call.map(&:to_s)
    end
  end
end
