class Notifier
  def initialize(numbers)
    @numbers = numbers
  end

  def gap_shifts(shifts)
    TwilioAPI.new(numbers)
      .text_all("#{'Gap'.pluralize(shifts.count)} tomorrow:\n#{shifts.join("\n")}\nTo volunteer for a shift right now, respond \"shifts\"")
  end

  def weekly_notification(shifts)
    if shifts.empty?
      TwilioAPI.new(numbers).
        text_all("I couldn't find any open shifts left in the coming week! Is this even possible? I assume I have a bug...")
    else
      TwilioAPI.new(numbers)
        .text_all("#{'Shift'.pluralize(shifts.count)} still up for grabs this week:\n#{shifts.join("\n")}\nTo claim a shift right now, respond \"shifts\"")
    end
  end

  private
  attr_reader :numbers
end
