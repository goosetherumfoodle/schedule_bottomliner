class TwilioAPI

  def initialize(numbers, test: nil)
    @numbers = numbers
    @test = test
  end

  def text_all(msg)
    # set up a client to talk to the Twilio REST API
    client = Twilio::REST::Client.new account_sid, auth_token

    numbers.each do |number|
      client.api.account.messages.create(
        from: twilio_number,
        to: number,
        body: msg
      )
    end
  end

  private
  attr_reader :numbers, :test


  def account_sid
    @account_sid ||= ENV['TWILIO_ACCOUNT_SID']
  end

  def auth_token
    @token ||= ENV['TWILIO_AUTH_TOKEN']
  end

  def twilio_number
    @twil_number ||= if test
                       ENV['TEST_TWILIO_NUMBER']
                     else
                       ENV['TWILIO_NUMBER']
                     end
  end
end
