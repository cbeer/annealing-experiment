class Schedule < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :votes, through: :events
  has_many :rooms
  belongs_to :schedule
  
  def parent
    @parent ||= schedule || self
  end
  
  def users
    events.map { |e| e.parent.users.to_a }.flatten.uniq
  end
  
  def anneal options = {}, &block
    initialize_times_and_rooms
    best = Annealer.new(options).anneal(self, &block)
    best.events.each do |e|
      p = events.select { |x| x.id == e.parent.id }.first
      p.time = e.time
      p.room_id = e.room_id
    end
    self
  end
  
  def cached_room_ids
    @cached_room_ids ||= room_ids
  end

  def energy
    score = 0
    
    # voting
    parent.users.each do |u|
      events.group_by { |e| e.time }.each do |t, evs|
        scores = evs.map do |e|
          e.parent.votes.select { |x| x.user == u }.first.try(:vote)
        end.compact
        
        if scores.empty?
          # don't care
        elsif scores.length == 1 
          # no session conflicts
          score -= scores.max
        else
          # users don't like sessions they voted for scheduled at the same time
          score += 2**scores.sum
        end
      end
    end
    
    # time
    events.each do |e|
      if e.time && e.time < starts_at
        score += (starts_at - e.time) / 15
      end
      
      if e.time && e.time > ends_at
        score += (e.time - ends_at) / 15
      end
    end

    r = parent.cached_room_ids
    # compactness
    times = events.map { |x| x.time }.compact
    
    unless times.empty?
      t = times.min
      while t <= times.max
        evs = events.select { |e| e.time == t }
        if evs.empty?
          # if we have an entirely blank spot, that's bad.
          score += 100
        else
          # if we have unused rooms.. 
          score += 10*(r.length - evs.length)
          
          # if we've double-booked
          needs = evs.map { |x| (x.needs || "").split(",") }.flatten.compact
          if needs.uniq.length < needs.length
             score += 1000
          end
        end
        
        t = (t + 1.hour).beginning_of_hour
      end
    end

    score
  end
  
  def random_neighbor
    n = nil
    c = [:swap_room, 
         :swap_earlier, 
         :swap_later, 
         :switch_track].shuffle
    while n.nil? and !c.empty?
      n = send(c.pop)
    end
    n
  end

  def get_schedule
      "\n=====\n" +
      ["t", parent.rooms.flatten.sort].flatten.join("\t") + "\n" + 
      events.group_by { |e| e.time }.sort_by { |t, es| t }.map do |t, es|
        row = []
        row << t
        parent.rooms.each do |l|
          e = es.select { |e| e.room == l}.first
          row << (e.title if e ) || ""
        end
        row.join("\t")    
      end.join("\n") + 
      "\n====="
  end
  
  def session_times
    ts = []
    
    t = starts_at
    while t <= ends_at
      ts << t
      t = (t + 1.hour).beginning_of_hour
    end

    ts
  end
  
  def unassign_all_events
    events.each do |e|
      e.time = nil
      e.room_id = nil
      e.save
    end
  end
  
  private
  def initialize_times_and_rooms
    events.select { |x| x.room_id.nil? }.each do |e| 
      e.room_id = parent.cached_room_ids.shuffle.first
    end

    latest_by_room = {}

    events_by_room = events.group_by { |x| x.room_id }.each do |track, es|
      latest_by_room[track] = es.reject { |x| x.time.nil? }.map { |x| x.time }.max
    end

    events.select { |x| x.time.nil? }.group_by { |x| x.room_id }.each do |track, es|
      es.each_with_index do |e,i|
        e.time = latest_by_room[track] || ((Time.now.beginning_of_day + 8.hours) + 1 + i.hours).beginning_of_hour
      end
    end
  end
  
  def clone
    self.class.new attributes.merge(events: events.map { |x| x.clone }, schedule: parent).except('id')
  end
  
  def swap_room
    s = clone
    
    ev1 = s.events.shuffle.first
    l = (parent.cached_room_ids - [ev1.room_id]).shuffle.first
    ev2 = s.events.select { |x| x.time == ev1.time }.select { |x| x.room_id == l }.first
    
    if ev2.nil?
      ev1.room_id = l
    else
      ev1.room_id, ev2.room_id = ev2.room_id, ev1.room_id
    end

    s
  end
  
  def swap_earlier
    s = clone
    
    ev1 = s.events.shuffle.first
    ev2 = s.events.select { |x| x.room_id == ev1.room_id }.select { |x| x.time == (ev1.time - 1.hour).beginning_of_hour }.first

    if ev2.nil?
      ev1.time = (ev1.time - 1.hour).beginning_of_hour
    else
      ev1.time, ev2.time = ev2.time, ev1.time
    end
    s
  end
  
  def swap_later
    s = clone
    
    ev1 = s.events.shuffle.first
    ev2 = s.events.select { |x| x.room_id == ev1.room_id }.select { |x| x.time == (ev1.time + 1.hour).beginning_of_hour }.first
    
    if ev2.nil?
      ev1.time = (ev1.time + 1.hour).beginning_of_hour
    else
      ev1.time, ev2.time = ev2.time, ev1.time
    end
    
    s
  end
  
  def switch_track
    s = clone
    
    ev1 = s.events.shuffle.first
    ev1.room_id = (parent.cached_room_ids - [ev1.room_id]).shuffle.first

    ev2 = s.events.select { |x| x.room_id == ev1.room_id }.map { |x| x.time }
    ev1.time = ((s.session_times - ev2) + [(ev2.max + 1.hour).beginning_of_hour]).shuffle.first
    s
  end
end
