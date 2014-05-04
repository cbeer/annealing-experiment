require 'spec_helper'

describe "Simple case" do
  subject { Schedule.new }
  before do
    subject.starts_at = Time.now.beginning_of_hour
    subject.ends_at = Time.now.beginning_of_hour + 2.hours
    subject.rooms << Room.new(name: "Track A")
    subject.rooms << Room.new(name: "Track B")
    
    subject.events << Event.new(title: "1")
    subject.events << Event.new(title: "2")
    subject.events << Event.new(title: "3")
    subject.events << Event.new(title: "4")
    
    subject.save
    
    u1 = User.create email: 'user1@example.com', password: 'user1@example.com'
    u2 = User.create email: 'user2@example.com', password: 'user2@example.com'
    
    subject.events[0].votes.create user: u1, vote: 1
    subject.events[1].votes.create user: u1, vote: 1
    subject.events[2].votes.create user: u2, vote: 1
    subject.events[3].votes.create user: u2, vote: 1
  end
  
  it "should arrange the events so each user has a separate track" do
    subject.anneal max_iter: 20
    subject.events.each { |e| e.save }

    expect(subject.events[0].time).to_not eq (subject.events[1].time)
    expect(subject.events[2].time).to_not eq (subject.events[3].time)
  end
end
