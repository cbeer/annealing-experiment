class Schedule < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :votes, through: :events
  has_many :rooms
  belongs_to :schedule
  
  def parent
    schedule || self
  end
  
  def users
    events.map { |e| e.parent.users.to_a }.flatten.uniq
  end

end
