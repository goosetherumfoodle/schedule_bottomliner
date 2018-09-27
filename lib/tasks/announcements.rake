namespace :announcements do
  desc 'Sends any announcement to all users'
  task :all, [:message] => :environment  do |task, args|
    return nil if args[:message].blank?
    Notifier.new(Contact.unscoped.pluck(:number)).arbitrary(args[:message])
  end

  desc 'Test: Sends any announcement to all users'
  task :test_all, [:message] => :environment  do |task, args|
    return nil if args[:message].blank?
    Notifier.new(Contact.unscoped.testers.pluck(:number)).arbitrary(args[:message])
  end
end
