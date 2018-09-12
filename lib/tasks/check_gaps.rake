namespace :gaps do
  desc "Notify whole list of currently open shifts for the week"
  task weekly_notify: :environment do
    Rails.logger.info 'gaps:weekly_notify task started'
    File.open('./schedule.yml') do |schedule_file|
      now = DateTime.now
      week_from_now = now.advance(weeks: 1)
      this_week = Shift.new(start_time: now,
                            end_time: week_from_now)

      schedule_hash = YAML.load(schedule_file.read)
      schedule = Schedule.build(hash: schedule_hash, current_time: now)

      taken_shifts = CalApi.new.shifts_for_period(this_week)

      gap_shifts = Gap::Finder.new(current_time: now, schedule: schedule).
                   call(look_in: this_week, calendar_shifts: taken_shifts)

      Rails.logger.info "Weekly notificaiton: shift gaps found: #{gap_shifts}"
      Notifier.new(Contact.pluck(:number)).weekly_notification(gap_shifts)
    end
  end

  desc "Check and alert if next-day gaps are found"
  task next_shift: :environment do
    Rails.logger.info 'gaps:next_shift task started'
    File.open('./schedule.yml') do |schedule_file|
      schedule_hash = YAML.load(schedule_file.read)
      time = DateTime.now
      schedule = Schedule.build(hash: schedule_hash, current_time: time)
      gap_shifts = Gap::NextShift.new(schedule: schedule).call.map(&:to_s)
      Rails.logger.info "shift gaps found: #{gap_shifts}"
      if gap_shifts.any?
        Notifier.new(Contact.pluck(:number)).gap_shifts(gap_shifts)
      end
    end
  end

  desc "TEST ACCOUNTS: Check and alert if next-day gaps are found"
  task test_next_shift: :environment do
    Rails.logger.info 'gaps:next_shift task started'
    File.open('./schedule.yml') do |schedule_file|
      schedule_hash = YAML.load(schedule_file.read)
      time = DateTime.now
      schedule = Schedule.build(hash: schedule_hash, current_time: time)
      gap_shifts = Gap::NextShift.new(schedule: schedule).call.map(&:to_s)
      Rails.logger.info "shift gaps found: #{gap_shifts}"
      if gap_shifts.any?
        Notifier.new(Contact.testers.pluck(:number)).gap_shifts(gap_shifts)
      end
    end
  end
end
