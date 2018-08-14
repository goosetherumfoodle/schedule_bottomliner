require_relative '../../app/models/gap/next_shift'
require_relative '../../app/models/schedule'
require_relative '../../app/models/twilio_api'

namespace :gaps do
  desc "Check and alert if next-day gaps are found"
  task :next_shift do
    Rails.logger.info 'gaps:next_shift task started'
    File.open('./schedule.yml') do |schedule_file|
      schedule_hash = YAML.load(schedule_file.read)
      time = DateTime.now
      schedule = Schedule.build(hash: schedule_hash, current_time: time)
      gap_shifts = Gap::NextShift.new(schedule: schedule).call.map(&:to_s)
      Rails.logger.info "shift gaps found: #{gap_shifts}"
      if gap_shifts.any?
        TwilioAPI.new([ENV['CELL']]).text_all("Upcoming bookstore shift #{'gap'.pluralize(gap_shifts.count)}:\n#{gap_shifts.join("\n")}")
      end
    end
  end
end
