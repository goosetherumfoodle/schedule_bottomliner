class SingleNotifier
  def initialize(test: nil)
    @test = test
  end

  def call(contact:, message:)
    TwilioAPI.new([contact.number], test: @test).text_all(message)
  end
end
