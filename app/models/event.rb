class Event < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :event
  belongs_to :room
  belongs_to :user
  has_many :votes, dependent: :destroy
  has_many :users, through: :votes
  
  def clone
    self.class.new attributes.except('id').merge(event: parent)
  end
  
  def parent
    event || self
  end
  
  def localized_time
    I18n.l time, format: :short
  end
end
