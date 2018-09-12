require 'rails_helper'

RSpec.describe InboundsController, type: :controller do
  describe '#create' do
    describe 'requesting a shift' do
      it 'sends the shift to the gcal api' do
        current_time = "01-01-2018 17:00".to_datetime
        end_of_current_day = current_time.change(hours: 23, minutes: 59)

        start_1 = "3-1-2018 10:30 -0500".to_datetime
        end_1 = "3-1-2018 10:30 -0500".to_datetime
        shift_1 = Shift.new(start_time: start_1,
                            end_time: end_1)

        start_2 = "5-5-3333 00:00 -0500".to_datetime
        end_2 = "10-10-5555 01:00 -0500".to_datetime
        shift_2 = Shift.new(start_time: start_2,
                            end_time: end_2)

        contact = Contact.create!(number: "+15555555555", name: 'Big Suze')
        request.cookies['responses'] = {'0': {action: :update},
                                        '1': {action: :take_shift,
                                              payload: {start_time: shift_1.start_time,
                                                        end_time: shift_1.end_time}},
                                        '2': {action: :take_shift,
                                              payload: {start_time: shift_2.start_time,
                                                        end_time: shift_2.end_time}}}.to_json

        cal_api = double(:cal_api, post_shift: nil)
        allow(CalApi).to receive(:new).and_return(cal_api)
        post :create, params: {"ToCountry"=>"US",
                               "ToState"=>"NY",
                               "SmsMessageSid"=>"SMd5846f78d436d20fd6a37b7432b9d606",
                               "NumMedia"=>"0",
                               "ToCity"=>"DIAMOND POINT",
                               "FromZip"=>"12804",
                               "SmsSid"=>"SMd5846f78d436d20fd6a37b7432b9d606",
                               "FromState"=>"NY",
                               "SmsStatus"=>"received",
                               "FromCity"=>"GLENS FALLS",
                               "Body"=>"1",
                               "FromCountry"=>"US",
                               "To"=>"+15182409424",
                               "ToZip"=>"12885",
                               "NumSegments"=>"1",
                               "MessageSid"=>"SMd5846f78d436d20fd6a37b7432b9d606",
                               "AccountSid"=>"AC217eb0e1351b8b23149dd61f71b70dc0",
                               "From"=>"+15555555555",
                               "ApiVersion"=>"2010-04-01",
                               "controller"=>"inbounds",
                               "action"=>"create"}

        expected_shift = Shift.new(start_time: shift_1.start_time.advance(minutes: 1),
                                   end_time: shift_1.end_time)

        expect(cal_api).to have_received(:post_shift).with({shift: expected_shift,
                                                            name: 'Big Suze'})
      end
    end

    describe 'commands' do
      # TODO: test with no taken shifts
      describe '"staff"' do
        it 'responds with a list of open shifts and a response cookie' do
          current_time = "01-01-2018 18:00 -0400".to_datetime
          end_of_current_day = current_time.change(hours: 23, minutes: 59)

          # TODO: implement AppTime
          allow(AppTime).to receive(:current).and_return(current_time)

          start_1 = "02-01-2018 10:30 -0400".to_datetime
          end_1 = "02-01-2018 16:00 -0400".to_datetime
          shift_1 = Shift.new(start_time: start_1,
                              end_time: end_1)

          start_2 = "02-01-2018 16:00 -0400".to_datetime
          end_2 = "02-01-2018 21:30 -0400".to_datetime
          shift_2 = Shift.new(start_time: start_2,
                              end_time: end_2)

          contact = Contact.create!(number: "+15555555555", name: 'Big Suze')
          cal_api = double(:cal_api, shifts_for_period: [shift_1, shift_2])
          allow(CalApi).to receive(:new).and_return(cal_api)
          command = 'staff'
          post :create, params: {"ToCountry"=>"US",
                                 "ToState"=>"NY",
                                 "SmsMessageSid"=>"SMd5846f78d436d20fd6a37b7432b9d606",
                                 "NumMedia"=>"0",
                                 "ToCity"=>"DIAMOND POINT",
                                 "FromZip"=>"12804",
                                 "SmsSid"=>"SMd5846f78d436d20fd6a37b7432b9d606",
                                 "FromState"=>"NY",
                                 "SmsStatus"=>"received",
                                 "FromCity"=>"GLENS FALLS",
                                 "Body"=> command,
                                 "FromCountry"=>"US",
                                 "To"=>"+15182409424",
                                 "ToZip"=>"12885",
                                 "NumSegments"=>"1",
                                 "MessageSid"=>"SMd5846f78d436d20fd6a37b7432b9d606",
                                 "AccountSid"=>"AC217eb0e1351b8b23149dd61f71b70dc0",
                                 "From"=>"+15555555555",
                                 "ApiVersion"=>"2010-04-01",
                                 "controller"=>"inbounds",
                                 "action"=>"create"}

          expected_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n<Message>0: Mon 1st, 06:00 PM - 09:00 PM\n1:...:00 PM\n11: Mon 8th, 10:30 AM - 04:00 PM\n12: Mon 8th, 04:00 PM - 06:00 PM</Message>\n</Response>\n"

          expected_cookie = {"0"=>{"action"=>"take_shift",
                                               "payload"=>{"start_time"=>"2018-01-01T18:00:00-04:00", "end_time"=>shift_1.end_time.to_s}},
                                         "1"=> {"action"=>"take_shift",
                                         "payload"=>{"start_time"=>"2018-01-08T16:00:00-04:00", "end_time"=>"2018-01-08T18:00:00-04:00"}}}

#          expect(response.body).to eq(expected_body)
          expect(JSON.parse(response.cookies['responses'])).to eq(expected_cookie)
        end
      end
    end
  end
end
