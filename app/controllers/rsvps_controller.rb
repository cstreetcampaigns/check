class RsvpsController < ApplicationController
  include ApplicationHelper
  include RsvpsHelper
  include PeopleHelper

  before_filter :has_current_site_and_event
  before_filter :get_event
  before_filter :is_owner, only: [:show]

  def index
    @syncing = false
    if @current_event.sync_status == 'pending'
      @syncing = true
    else
      @page = 'rsvps'
      @rsvps = Rsvp.where(event_id: @current_event.id, host_id: nil)
      @letters = []
      @rsvps.each { |rsvp| @letters << rsvp.person.last_name[0].upcase.strip }
      @letters.sort_by!(&:downcase) unless @letters.empty?
      @letters.uniq!
      get_count
      @rsvps.order('last_name DESC') unless @rsvps.empty?
    end
  end

  def new
    @page = 'new-rsvp'
  end

  def cache
    # create_cache
    # redirect_to rsvps_path
    @current_event.update_attributes(sync_status: 'pending', sync_percent: 0, sync_date: DateTime.now)
    Resque.enqueue(Sync, params[:id], session[:current_site], session[:credential_id])

    respond_to do |format|
      format.json { render json: { status: 'started' } }
    end
  end

  def show
    check_nb_update(Rsvp.find(params[:id]).person)

    @rsvp = Rsvp.find(params[:id])
    @add_guests = add_guests(@rsvp)
  end

  def check_in
    @rsvp = Rsvp.find(params[:id])
    @rsvp.update_attribute('attended', true)
    nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @rsvp.person)
    if nationbuilder_rsvp[:status]
      respond_to do |format|
        format.js {}
      end
    end
  end

  def check_out
    @rsvp = Rsvp.find(params[:id])
    @rsvp.update_attribute('attended', false)
    nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @rsvp.person)
    if nationbuilder_rsvp[:status]
      respond_to do |format|
        format.js {}
      end
    end
  end

  # def check_out
  #  @rsvp = Rsvp.find(params[:id])
  #  @rsvp.update_attribute('attended', false)
  #  nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @rsvp.person)
  #  if nationbuilder_rsvp[:status]
  #    respond_to do |format|
  #      format.js {}
  #    end
  #  else
  #  end
  # end

  def sync
    @rsvps = Rsvp.where(nation_id: @current_event.nation_id, event_id: @current_event.id).to_a
    @nb = check_sync
    @same = []

    @rsvps.each do |r|
      next unless r.rsvpNBID
      @nb.each do |n|
        @same << r if n['id'] == r.rsvpNBID
      end
    end

    @same.each do |s|
      @rsvps.delete(s)
      @nb.delete_if { |n| n['id'] == s.rsvpNBID }
    end

    @nb_person = []
    @nb.each do |n|
      @nb_person << get_person(n)
    end

    get_count
  end

  private

  def has_current_site_and_event
    if session[:current_site]
      if session[:current_event]
        true
      else
        redirect_to choose_event_path
      end
    else
      redirect_to choose_site_path
    end
  end

  def is_owner
    if current_user.nation.id != Rsvp.find(params[:id]).person.nation_id
      begin
        redirect_to(:back, flash: { error: "Sorry, you don't have access to this information" })
      rescue ActionController::RedirectBackError
        redirect_to(:root, flash: { error: "Sorry, you don't have access to this information" })
      end
    end
  end
end
