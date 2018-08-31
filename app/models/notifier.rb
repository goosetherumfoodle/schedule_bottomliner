class Notifier
  def initialize(numbers)
    @numbers = numbers
  end

  def gap_shifts(shifts)
    TwilioAPI.new(numbers)
      .text_all("Upcoming bookstore shift #{'gap'.pluralize(shifts.count)}:\n#{shifts.join("\n")}")
  end

  private
  attr_reader :numbers
end
