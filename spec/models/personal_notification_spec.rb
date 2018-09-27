require 'rails_helper'

RSpec.describe PersonalNotification do
  context 'with open shifts and a contact not on the schedule' do
    it 'generates message for person not on the schedule' do
      on_schedule = double(:on_schedule_contact, number: '+12222222222', name: 'on schedule')
      not_scheduled = double(:not_scheduled_contact, number: '+13333333333', name: 'not on schedule')
      scheduled_names = ['big suze', 'On Schedule']

      expected = [{contact: not_scheduled, message: "I don't see \"not on schedule\" on the schedule this week. Here are the open shifts:"}]


      results = PersonalNotification.new.call(scheduled: scheduled_names,
                                              contacts: [on_schedule, not_scheduled],
                                              openings: true)

      expect(results).to eq(expected)
    end
  end

  context 'with open shifts and no contacts not on the schedule' do
    it 'returns nil' do
      on_schedule = double(:on_schedule_contact, number: '+12222222222', name: 'On Schedule')
      also_on_schedule = double(:also_on_schedule_contact, number: '+13333333333', name: 'also on schedule')
      scheduled_names = ['On Schedule', 'also on schedule']

      results = PersonalNotification.new.call(scheduled: scheduled_names,
                                              contacts: [on_schedule, also_on_schedule],
                                              openings: true)

      expect(results).to be_falsey
    end
  end

  context 'with no shifts and and contacts not on the schedule' do
    it 'returns nil' do
      on_schedule = double(:on_schedule_contact, number: '+12222222222', name: 'on schedule')
      not_scheduled = double(:not_scheduled_contact, number: '+13333333333', name: 'not on schedule')
      scheduled_names = ['big suze', 'Not on Schedule']


      results = PersonalNotification.new.call(scheduled: scheduled_names,
                                              contacts: [on_schedule, not_scheduled],
                                              openings: false)

      expect(results).to be_falsey
    end
  end
end
