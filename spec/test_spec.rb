require 'spec_helper'

describe "" do
  it "should do something" do
    s = Schedule.new
    s.starts_at = Time.now.beginning_of_day + 9.hours
    s.ends_at = Time.now.beginning_of_day + 17.hours
    ('a'..'z').each { |t| s.events << Event.new(title: t) }
    
    s.rooms << Room.new(name: "Room 1")
    s.rooms << Room.new(name: "Room 2")
    s.rooms << Room.new(name: "Room 3")
    
    s.save
    
    users = (1..15).map { |e| User.create email: "user#{e}@example.com", password: "user#{e}@example.com" }
    
    users.each do |u|
      votes = 15
      while votes > 0
        e = s.events.shuffle.first
        v = rand(1..5)
        votes -= v
        e.votes.create!(user: u, vote: v)
      end
    end
    
    s.save
    
    s.anneal
  end
end
