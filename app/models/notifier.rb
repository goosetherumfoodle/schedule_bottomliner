class Notifier
  def initialize(numbers, test: nil)
    @numbers = numbers
    @test = test
  end

  def gap_shifts(shifts)
    twilio_api.text_all("#{'Gap'.pluralize(shifts.count)} tomorrow:\n#{shifts.join("\n")}\nTo volunteer for a shift right now, respond \"shifts\"")
  end

  def weekly_notification(shifts)
    if shifts.empty?
      twilio_api.text_all("I couldn't find any open shifts left in the coming week! Is this even possible!? Chances are I have bug...")
    else
      twilio_api.text_all("#{shifts.count} #{'Shift'.pluralize(shifts.count)} still up for grabs this week:\n#{shifts.join("\n")}\nTo claim a shift right now, respond \"shifts\"")
    end
  end

  private
  attr_reader :numbers, :test

  def twilio_api
    TwilioAPI.new(numbers, test: test)
  end
end
