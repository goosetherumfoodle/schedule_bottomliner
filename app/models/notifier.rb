class Notifier
  def initialize(numbers)
    @numbers = numbers
  end

  def gap_shifts(shifts)
    TwilioAPI.new(numbers)
      .text_all("#{'Gap'.pluralize(shifts.count)} tomorrow:\n#{shifts.join("\n")}")
  end

  private
  attr_reader :numbers
end
