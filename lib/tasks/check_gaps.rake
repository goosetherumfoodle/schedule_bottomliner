namespace :gaps do
  desc "TEST: Notify individuals who haven't claimed a shift in the current week. For daily messages times."
  task test_personal_notify: :environment do
    Rails.logger.info 'gaps:test_personal_notify task started'
    File.open('./schedule.yml') do |schedule_file|
      now = DateTime.now

      app_time = AppTime.new(now)

      # we already send out the weekly notification on tuesday,
      # so  there's no reason to double up
      return nil if app_time.is_tuesday?

      this_week = app_time.current_week

      schedule_hash = YAML.load(schedule_file.read)
      schedule = Schedule.build(hash: schedule_hash, current_time: now)

      shifts_sums = CalApi.new.shifts_with_summaries_for_period(this_week)
      taken_shifts = shifts_sums.map { |ss| ss[:shift] }
      scheduled_names = shifts_sums.map { |ss| ss[:summary] }

      raw_gap_shifts = Gap::Finder.new(current_time: now, schedule: schedule).
                         call(look_in: this_week, calendar_shifts: taken_shifts)

      namer = Shifts::Names.new(schedule)

      gap_shifts = raw_gap_shifts.map { |shift| namer.call(shift) }

      has_gaps = !gap_shifts.empty?

      if has_gaps
        contact_msgs = PersonalNotification.new.call(contacts: Contact.testers, scheduled: scheduled_names, openings: true)
        contact_msgs.each do |contact_msg|
          contact_msg[:message] = contact_msg[:message].
                                    concat("\n").
                                    concat(gap_shifts.join("\n")).
                                    concat("\nTo claim a shift right now, respond \"shifts\"")
          Rails.logger.info "Daily notification to #{contact_msg[:contact]}: #{contact_msg[:message]}"
          SingleNotifier.new.call(contact_msg)
        end
      end
    end
  end

  desc "Notify individuals who haven't claimed a shift in the current week. For daily messages times."
  task personal_notify: :environment do
    Rails.logger.info 'gaps:personal_notify task started'
    File.open('./schedule.yml') do |schedule_file|
      now = DateTime.now

      app_time = AppTime.new(now)

      # we already send out the weekly notification on tuesday,
      # so  there's no reason to double up
      return nil if app_time.is_tuesday?

      this_week = app_time.current_week

      schedule_hash = YAML.load(schedule_file.read)
      schedule = Schedule.build(hash: schedule_hash, current_time: now)

      shifts_sums = CalApi.new.shifts_with_summaries_for_period(this_week)
      taken_shifts = shifts_sums.map { |ss| ss[:shift] }
      scheduled_names = shifts_sums.map { |ss| ss[:summary] }

      raw_gap_shifts = Gap::Finder.new(current_time: now, schedule: schedule).
                         call(look_in: this_week, calendar_shifts: taken_shifts)

      namer = Shifts::Names.new(schedule)

      gap_shifts = raw_gap_shifts.map { |shift| namer.call(shift) }

      has_gaps = !gap_shifts.empty?

      if has_gaps
        contact_msgs = PersonalNotification.new.call(contacts: Contact.all, scheduled: scheduled_names, openings: true)
        contact_msgs.each do |contact_msg|
          contact_msg[:message] = contact_msg[:message].
                                    concat("\n").
                                    concat(gap_shifts.join("\n")).
                                    concat("\nTo claim a shift right now, respond \"shifts\"")
          Rails.logger.info "Daily notification to #{contact_msg[:contact]}: #{contact_msg[:message]}"
          SingleNotifier.new.call(contact_msg)
        end
      end
    end
  end

  desc "Notify whole list of currently open shifts up until next wednesday. For arbitrary execution times."
  task arbitrary_notify: :environment do
    Rails.logger.info 'gaps:arbitrary_notify task started'
    File.open('./schedule.yml') do |schedule_file|
      now = DateTime.now

      if now.wday < 2
        # if it's not yet tuesday, select wednesday this week
        next_wed = now.advance(days: 3 - now.wday)
      else
        # if it's already tuesday, select wednesday next week
        next_wed = now.next_week(:wednesday)
      end

      this_week = Shift.new(start_time: now,
                            end_time: next_wed.end_of_day)

      schedule_hash = YAML.load(schedule_file.read)
      schedule = Schedule.build(hash: schedule_hash, current_time: now)

      taken_shifts = CalApi.new.shifts_for_period(this_week)

      raw_gap_shifts = Gap::Finder.new(current_time: now, schedule: schedule).
                         call(look_in: this_week, calendar_shifts: taken_shifts)

      namer = Shifts::Names.new(schedule)

      gap_shifts = raw_gap_shifts.map { |shift| namer.call(shift) }

      Rails.logger.info "Weekly notification: shift gaps found: #{gap_shifts}"
      Notifier.new(Contact.pluck(:number)).weekly_notification(gap_shifts)
    end
  end

  desc "TEST ACCOUNTS: notify of currently open shifts up until next wednesday. For arbitrary execution times"
  task test_arbitrary_notify: :environment do
    Rails.logger.info 'gaps:test_arbitrary_notify task started'
    File.open('./schedule.yml') do |schedule_file|
      now = DateTime.now

      if now.wday < 2
        # if it's not yet tuesday, select wednesday this week
        next_wed = now.advance(days: 3 - now.wday)
      else
        # if it's already tuesday, select wednesday next week
        next_wed = now.next_week(:wednesday)
      end

      this_week = Shift.new(start_time: now,
                            end_time: next_wed.end_of_day)

      schedule_hash = YAML.load(schedule_file.read)
      schedule = Schedule.build(hash: schedule_hash, current_time: now)

      taken_shifts = CalApi.new.shifts_for_period(this_week)

      raw_gap_shifts = Gap::Finder.new(current_time: now, schedule: schedule).
                         call(look_in: this_week, calendar_shifts: taken_shifts)

      namer = Shifts::Names.new(schedule)

      gap_shifts = raw_gap_shifts.map { |shift| namer.call(shift) }

      Rails.logger.info "Weekly notification: shift gaps found: #{gap_shifts}"
      Notifier.new(Contact.testers.pluck(:number), test: true).weekly_notification(gap_shifts)
    end
  end


  desc "Notify whole list of currently open shifts for the week. Should only execute on Tuesdays."
  task weekly_notify: :environment do
    Rails.logger.info 'gaps:weekly_notify task started'
    File.open('./schedule.yml') do |schedule_file|
      now = DateTime.now
      return nil unless now.tuesday?
      week_from_now = now.advance(weeks: 1).end_of_day
      this_week = Shift.new(start_time: now,
                            end_time: week_from_now)

      schedule_hash = YAML.load(schedule_file.read)
      schedule = Schedule.build(hash: schedule_hash, current_time: now)

      taken_shifts = CalApi.new.shifts_for_period(this_week)

      raw_gap_shifts = Gap::Finder.new(current_time: now, schedule: schedule).
                         call(look_in: this_week, calendar_shifts: taken_shifts)

      namer = Shifts::Names.new(schedule)

      gap_shifts = raw_gap_shifts.map { |shift| namer.call(shift) }

      Rails.logger.info "Weekly notification: shift gaps found: #{gap_shifts}"
      Notifier.new(Contact.pluck(:number)).weekly_notification(gap_shifts)
    end
  end

  desc "TEST ACCOUNTS: notify of currently open shifts for the week. (non-test version should only run on tuesdays)"
  task test_weekly_notify: :environment do
    Rails.logger.info 'gaps:weekly_notify task started'
    File.open('./schedule.yml') do |schedule_file|
      now = DateTime.now
      week_from_now = now.advance(weeks: 1).end_of_day
      this_week = Shift.new(start_time: now,
                            end_time: week_from_now)

      schedule_hash = YAML.load(schedule_file.read)
      schedule = Schedule.build(hash: schedule_hash, current_time: now)

      taken_shifts = CalApi.new.shifts_for_period(this_week)

      raw_gap_shifts = Gap::Finder.new(current_time: now, schedule: schedule).
                         call(look_in: this_week, calendar_shifts: taken_shifts)

      namer = Shifts::Names.new(schedule)

      gap_shifts = raw_gap_shifts.map { |shift| namer.call(shift) }

      Rails.logger.info "Weekly notification: shift gaps found: #{gap_shifts}"
      Notifier.new(Contact.testers.pluck(:number), test: true).weekly_notification(gap_shifts)
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

namespace :heroku do
  desc "Pings PING_URL to keep a dyno alive"
  task :dyno_ping do
    require "net/http"

    if ENV['PING_URL']
      uri = URI(ENV['PING_URL'])
      Net::HTTP.get_response(uri)
    end
  end
end
