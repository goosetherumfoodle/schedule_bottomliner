class AppTime
  def self.current
    DateTime.now.change(offset: '-0400')
  end
end

class InboundsController < ApplicationController
  include ActionController::Cookies

  # TODO: extract an AppTime object
  # TODO: fix logic (cookies or commands have precedence?)
  def create
    if /shifts/i =~ params['Body']
      ## Showing shifts that can be taken
      now = AppTime.current
      week_from_now = now.advance(weeks: 1).end_of_day
      this_week = Shift.new(start_time: now,
                            end_time: week_from_now)
      taken_shifts = CalApi.new.shifts_for_period(this_week)

      openings = []
      File.open('./schedule.yml') do |schedule_file|
        schedule_hash = YAML.load(schedule_file.read)
        schedule = Schedule.build(hash: schedule_hash, current_time: now)
        openings = Gap::Finder.new(current_time: now, schedule: schedule).
                     call(look_in: this_week, calendar_shifts: taken_shifts)
      end

      responses = openings.each_with_index.reduce({}) do |hash, (shift, i)|
        hash.merge({(i + 1).to_s.to_sym => {action: :take_shift,
                                      payload: {start_time: shift.start_time.to_s,
                                                end_time: shift.end_time.to_s
                                               }
                                     }})
      end

      if openings.empty?
        full_message = "No open shifts found in the coming week!"
      else
        base_message = openings.map.with_index do |shift, i|
          "#{i + 1}: #{shift}"
        end.join("\n")
        full_message = ["Open shifts this week.\nRespond with the number to take it.",
                        base_message].join("\n")
      end

      twiml = Twilio::TwiML::MessagingResponse.new do |r|
        r.message(body: full_message)
      end

      cookies['responses'] = responses.to_json

      render xml: twiml.to_s
    else
      if request.cookies['responses']
        body = params['Body'].strip
        action = JSON.parse(request.cookies["responses"]).fetch(body, nil)&.fetch('action', nil)
        payload = JSON.parse(request.cookies["responses"]).fetch(body, nil)&.fetch('payload', nil)
        if action && payload && action == 'take_shift'
          start_time = payload['start_time'].to_datetime
          end_time = payload['end_time'].to_datetime
          name = Contact.find_by!(number: params['From']).name
          shift = Shift.new(start_time: start_time.advance(minutes: 1), end_time: end_time)
          result = CalApi.new.post_shift(shift: shift, name: name)

          twiml = nil
          if result[:success]
            message = result[:success]

            twiml = Twilio::TwiML::MessagingResponse.new do |r|
              r.message(body: message)
            end
          else
            message = result[:error].concat("\nReply with \"shifts\" to see updated list.")
            twiml = Twilio::TwiML::MessagingResponse.new do |r|
              r.message(body: message)
            end
          end

          cookies.delete('responses')
          render xml: twiml.to_s
        else
          message = 'Sorry, unsure what to do with this. Let Jesse know how you got this message. (If you can figure out the steps to reproduce it, that would help)'
          twiml = Twilio::TwiML::MessagingResponse.new do |r|
            r.message(body: message)
          end
          cookies.delete('responses')
          render xml: twiml.to_s
        end
      else
        cookies.delete('responses')
        message = 'Sorry, unsure what to do with this. Let Jesse know how you got this message. (If you can figure out the steps to reproduce it, that would help)'
        twiml = Twilio::TwiML::MessagingResponse.new do |r|
          r.message(body: message)
        end
        cookies.delete('responses')
        render xml: twiml.to_s
      end
    end
  end
end
