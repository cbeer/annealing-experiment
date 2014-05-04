class AnnealController < ApplicationController
  include ActionController::Live
  
  def schedule
    @schedule = Schedule.includes(:events).find(params[:id])
    
    response.headers['Content-Type'] = 'text/event-stream'
  
    @schedule.anneal logger: streaming_logger(response.stream), max_iter: 2500, log_progress_frequency: 10
  
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
