require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class CalApi
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  STAFFING_CAL_ID = ENV['STAFFING_CAL_ID']

  def initialize(current_time = nil)
    @current_time = current_time || DateTime.now
  end

  def post_shift(shift:, name:)
    existing_shifts = shifts_for_period(shift)
    if !existing_shifts.empty?
      # TODO: handle shift already exists case. maybe send an update
      return {error: "It looks like that shift's already been taken"}
    else
      event = Google::Apis::CalendarV3::Event.new(
        summary: name,
        description: "Created by bot. Complain to Jesse if there's a problem",
        start: {
          date_time: shift.start_time.to_s
        },
        end: {
          date_time: shift.end_time.to_s
        }
      )

      result = service.insert_event(STAFFING_CAL_ID, event)

      start_time = result.start.date_time
      end_time = result.end.date_time
      shift = Shift.new(start_time: start_time, end_time: end_time)
      return {success: "Shift posted: #{shift.full_name}"}
    end
  end

  def shifts_for_period(period)
    # Fetch the next 10 events for the user
    calendar_id = STAFFING_CAL_ID
    response = service.list_events(calendar_id,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_min: period.start_time.iso8601,
                                   time_max: period.end_time.iso8601)

    response_shifts = response.items

    response_shifts.map do |event|
      start = event.start.date || event.start.date_time
      Shift.new(start_time: event.start.date_time,
                end_time: event.end.date_time)
    end
  end

  private
  attr_reader :service, :current_time

  def service
    @service ||= start_service
  end

  def start_service
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(scope: SCOPE)
    authorizer.fetch_access_token!

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorizer

    service
  end
end
