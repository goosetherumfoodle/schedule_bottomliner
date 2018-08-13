# client id: 168309112580-39ddqk5mimu5o4idt7k0shq10crm55rp.apps.googleusercontent.com
# client secret  Q831Rzd8VYkqRjXctnHQ5ecl
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class CalApi
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'.freeze
  CREDENTIALS_PATH = 'credentials.json'.freeze
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
  STAFFING_CAL_ID = ENV['STAFFING_CAL_ID']

  def initialize(current_time = nil)
    @current_time = current_time || DateTime.now
  end

  def shifts_for_period(period)
    # Initialize the API
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # Fetch the next 10 events for the user
    calendar_id = STAFFING_CAL_ID
    response = service.list_events(calendar_id,
                                   max_results: 10,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_min: period.start_time.beginning_of_day.iso8601)

    shifts = response.items.select do |event|
      event.end.date_time >= period.start_time &&
        event.start.date_time <= period.end_time
    end

    shifts.map do |event|
      start = event.start.date || event.start.date_time
      Shift.new(start_time: event.start.date_time,
                 end_time: event.end.date_time)
    end
  end

  private
  attr_reader :current_time

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end
end
