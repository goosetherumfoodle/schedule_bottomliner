class PersonalNotification

  def call(scheduled:, contacts:, openings:)
    return nil unless openings

    unscheduled = contacts.reject do |c|
      scheduled.detect { |on_schedule| /#{c.name}/i =~ on_schedule }
    end

    messages = unscheduled.map { |c| {contact: c, message: "I don't see \"#{c.name}\" on the schedule this week.\nHere are the shifts that still need staffed:" }}

    if messages.empty?
      nil
    else
      messages
    end
  end
end
