class Rsvp < ActiveRecord::Base
	
	belongs_to :event
	belongs_to :person
		
	has_many :guests, class_name: "Rsvp", foreign_key: "host_id"
	belongs_to :host, class_name: "Rsvp"

	def self.import(r, event, p_id, n_id)

		rsvp = Rsvp.find_or_create_by(
		  event_id: event,
		  rsvpNBID: r['id'].to_i,
		  person_id: p_id,
		  nation_id: n_id
		)
		
		rsvp.update(
			guests_count: r['guests_count'].to_i,
			canceled: r['canceled'],
			volunteer: r['volunteer'],
			shift_ids: r['shift_ids'].to_a,
			attended: r['attended']
			)

		return rsvp

	end

	def self.create_new_rsvp(nation, event, p_id)
		Rsvp.new(
		  nation_id: nation,
		  event_id: event,
		  person_id: p_id,
			guests_count: 0,
			canceled: false,
			volunteer: false,
			shift_ids: [],
			attended: true
			)
	end

	def to_rsvp_object(person)

		rsvpObject = {
		  "rsvp" => {
		    "event_id" => self.event_id.to_i,
		    "person_id" => person.nbid.to_i,
		    "guests_count" => self.guests_count.to_i,
		    "volunteer" => self.volunteer,
		    "private" => self.is_private,
		    "canceled" => self.canceled,
		    "attended" => self.attended,
		    "shift_ids" => self.shift_ids
		  }
		}

		if self.rsvpNBID
			rsvpObject["rsvp"]["id"] = self.rsvpNBID.to_i
		end

		return rsvpObject

	end

end
