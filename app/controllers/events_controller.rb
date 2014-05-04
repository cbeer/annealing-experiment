class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :vote, :unvote]
  before_action :set_schedule

  # GET /events
  # GET /events.json
  def index
    @events = Event.where(schedule_id: params[:schedule_id]).all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new schedule: @schedule, user: current_user
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.schedule = @schedule
    @event.user ||= current_user

    respond_to do |format|
      if @event.save
        format.html { redirect_to @schedule, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: [@schedule,@event] }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @schedule, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: [@schedule,@event] }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to @schedule, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def vote
    if current_user 
      v = @event.votes.where(user:current_user).first_or_create
      v.vote = params.fetch(:rating, 1)
      v.save!
    end
    redirect_to @schedule
  end
  
  def unvote
    @event.votes.where(user: current_user).delete_all
    redirect_to @schedule
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    def set_schedule
      @schedule = @room.try(:schedule) || Schedule.find(params[:schedule_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params[:event].permit(:title)
    end
end
