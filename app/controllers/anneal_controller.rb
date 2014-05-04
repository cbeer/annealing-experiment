class AnnealController < ApplicationController
  include ActionController::Live
  
  def schedule
    @schedule = Schedule.includes(:events).find(params[:id])
    
    response.headers['Content-Type'] = 'text/event-stream'
  
    @schedule.anneal logger: streaming_logger(response.stream), max_iter: 2500, log_progress_frequency: 10 do |best_state|
      response.stream.write "event: best_state\n"
      response.stream.write "data: #{best_state.events.to_json(only: [:event_id, :room_id], methods: [:localized_time]) }\n\n"
    end
    
    response.stream.write "event: best_state\n"
    response.stream.write "data: #{@schedule.events.to_json(only: [:event_id, :room_id], methods: [:localized_time]) }\n\n"

    @schedule.events.each { |e| e.save }

    response.stream.write("event: done\ndata: x\n\n")
    response.stream.close
  end
  
  private
  
  def streaming_logger log_to
    Class.new do 
      def initialize(log_to)
        @log_to = log_to
      end
      
      def info(msg)
        return unless @log_to
        
        case msg
        when /^Iteration/
          @log_to.write("event: info\n")
        when /^New best/
          @log_to.write("event: best\n")
        end
        
        @log_to.write("data: ")
        @log_to.write(msg)
        @log_to.write("\n\n")    
      end  
    end.new(log_to)
  end
end
