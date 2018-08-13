class TwilioAPI

  def initialize(numbers)
    @numbers = numbers
  end

  def text_all(msg)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    twilio_number = ENV['TWILIO_NUMBER']

    # set up a client to talk to the Twilio REST API
    client = Twilio::REST::Client.new account_sid, auth_token

    @numbers.each do |number|
      client.api.account.messages.create(
        from: twilio_number,
        to: number,
        body: msg
      )
    end
  end
end
