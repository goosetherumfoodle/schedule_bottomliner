require 'rails_helper'

RSpec.describe Contact do
  describe 'default scope' do
    it 'doesn\'t include suspended accounts' do
      current_time = "1-7-2018 18:00".to_datetime
      app_time = double(:app_time, asUTC: current_time.new_offset(0))
      allow(AppTime).to receive(:new).and_return(app_time)

      old_suspension = current_time.advance(weeks: -1)
      active_suspension = current_time.advance(weeks: 1)

      first = Contact.create!(number: '+11112223333',
                              name: 'not suspended currently',
                              suspended_until: old_suspension)
      second = Contact.create!(number: '+11112223333',
                               name: 'not suspended currently',
                               suspended_until: active_suspension)
      third = Contact.create!(number: '+11112223333',
                              name: 'not suspended currently')

      expect(Contact.all).to eq([first, third])
    end
  end

  describe '#suspend_this_week!' do
    it 'marks the contact as suspended until end of biz week' do
      current_time = "1-7-2018 18:00".to_datetime
      current_week = Shift.new(start_time: current_time, end_time: current_time.advance(days: 3))
      app_time = double(:app_time, current_week: current_week, asUTC: current_time.new_offset(0))
      allow(AppTime).to receive(:new).and_return(app_time)

      contact = Contact.create!(number: '+11112223333',
                                name: 'not suspended currently')

      contact.suspend_this_week!

      expect(contact.reload.suspended_until).to eq(current_time.advance(days: 3))
    end
  end
end
