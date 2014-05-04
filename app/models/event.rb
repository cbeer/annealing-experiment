class Event < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :event
  belongs_to :room
  has_many :votes, dependent: :destroy
  has_many :users, through: :votes
  
  def parent
    event || self
  end
end
