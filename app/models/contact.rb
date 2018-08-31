class Contact < ActiveRecord::Base
  scope :testers, -> { where(tester: true) }
end
