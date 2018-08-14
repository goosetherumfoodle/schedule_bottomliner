class Notifier
  def gap_shifts(shifts)
    TwilioAPI.new(Contact.pluck(:number))
      .text_all("Upcoming bookstore shift #{'gap'.pluralize(shifts.count)}:\n#{shifts.join("\n")}")
  end
end
