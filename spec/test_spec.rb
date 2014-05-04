require 'spec_helper'

describe "" do
  it "should do something" do
    s = Schedule.new
    ('a'..'z').each { |t| s.events << Event.new(title: t) }
    users = (1..70).map { |e| User.new email: e}
    
    users.each do |u|
      votes = 15
      while votes > 0
        e = s.events.shuffle.first
        v = rand(1..5)
        votes -= v
        e.votes << e.votes.build(user: u, vote: v)
      end
    end
    
    s.send :initialize_times_and_locations
    
    s.save
    best = Annealer.new(log_to: STDOUT).anneal(s)
    best.save
    s.delete
  end
end
