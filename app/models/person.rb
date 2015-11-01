class Person < ActiveRecord::Base

  belongs_to :nation
  has_many :rsvps

  
  def full_name
    return self.first_name + " " + self.last_name
  end

  def nbid=(val)
    write_attribute(:nbid, val.to_i)
  end

  def self.import(p, nation)
    person = Person.find_or_create_by(
      nbid: p['id'],
      nation_id: nation
    )

    person.update(
      first_name: p["first_name"],
      last_name: p["last_name"],
      email: p["email"],
      phone_number: p["phone"],
      pic: p["profile_image_url_ssl"]
    )

    return person

  end

  def to_person_object
    person_object = {
      :person => {
        :first_name => self.first_name,
        :last_name => self.last_name,
        :email => self.email,
      }
    }
    
    return person_object.to_json

  end

end
