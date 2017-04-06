module RsvpsHelper

  def send_rsvp_to_nationbuilder(rsvp, person, attended=true)

    # return {status: true, id: 10000000}

    rsvpObject = rsvp.to_rsvp_object(person)
    rsvpObject["rsvp"]["attended"] = attended
    puts rsvpObject
    if rsvpObject["rsvp"].has_key?("id")
      begin
        checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/#{rsvp.rsvpNBID}", :headers => standard_headers, :body => rsvpObject.to_json)
        checked_in = JSON.parse(checkInResponse.body)["rsvp"]
      rescue => ex
        begin
          nb_error = JSON.parse(ex.response.body)
          error = nb_error['message']
          if nb_error['validation_errors']
            error += "<ul>"
            for v_error in nb_error['validation_errors']
              error = error + "<li>" + v_error + "</li>"
            end
            error += "</ul>"
          end
        rescue JSON::ParserError => e
          error = "Nationbuilder unresponsive, please try again"
        end
        return {status: false, error: error}
      else
        puts checked_in
        return {status: true, id: checked_in["id"].to_i }
      end

    else

      begin
        checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
      rescue => ex
        begin
          nb_error = JSON.parse(ex.response.body)
          error = nb_error['message']
          if nb_error['validation_errors']
            error += "<ul>"
            for v_error in nb_error['validation_errors']
              error = error + "<li>" + v_error + "</li>"
            end
            error += "</ul>"
          end
        rescue JSON::ParserError => e
          error = "Nationbuilder unresponsive, please try again"
        end
        return {status: false, error: error}
      else
        checked_in = JSON.parse(checkInResponse.body)["rsvp"]
        return {status: true, id: checked_in["id"].to_i }
      end

    end

  end

  def get_count
    rsvps = @current_event.rsvps
    @total = rsvps.select { |r| r if !r.host_id}.count
    rsvps.each do |r|
      @total += r.guests_count
    end

    @attending =  rsvps.select { |r| r if r.attended }.count
  end

  def add_guests(rsvp)
    if rsvp.guests.count >= rsvp.guests_count
      return false
    else
      return true
    end
  end

  def get_rsvps
    response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :params => {per_page: 100, limit: 100}, :headers => standard_headers)
    parsed = JSON.parse(response.body)
    rsvpListfromNB = []

    # This is due different pagination rules implemented by NationBuilder
    
    if parsed['next']
      rsvpListfromNB << parsed["results"]
      currentpage = 1
      is_next = parsed['next']
      while is_next
        currentpage += 1
        pagination_result = token.get(is_next, :headers => standard_headers, :params => { token_paginator: currentpage, per_page: 100, limit: 100})
        response = JSON.parse(pagination_result.body)
        rsvpListfromNB << response['results']
        is_next = response['next']
      end

    elsif parsed["total_pages"]
      current_page = 1
      total_pages = parsed["total_pages"]
      rsvpListfromNB << parsed["results"]
      while total_pages >= current_page
        current_page += 1
        response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :headers => standard_headers, params: {page: current_page, per_page: 100, limit: 100})
        rsvpListfromNB << JSON.parse(response.body)["results"]
      end
    else 
      rsvpListfromNB << parsed["results"]
    end

    return rsvpListfromNB.flatten!
  end

	def create_cache

      get_rsvps.each do |r|
      person = Person.import(get_person(r), current_user.nation.id)
      rsvp = Rsvp.import(r, @current_event.id, person.id, current_user.nation.id)

	  end
	end

  def check_sync

    return get_rsvps 

  end
end