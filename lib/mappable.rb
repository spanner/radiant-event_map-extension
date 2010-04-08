module Mappable
  include Geokit::Geocoders
  
  def self.included(base)
    base.class_eval {
      before_validation :geocode_location
    }
  end
  
  def geocode
    "#{lat},#{lng}"
  end
  
  def geocode_basis
    postcode.blank? ? address : postcode
  end

private

  def geocode_location
    unless geocode_basis.blank? || ENV['RAILS_ENV'] == 'test'
      bias = Radiant::Config['event_map.zone'] || 'uk'
      geo = Geokit::Geocoders::MultiGeocoder.geocode(location, :bias => bias)
      errors.add(:location, "Could not Geocode location") if !geo.success
      self.lat, self.lng = geo.lat, geo.lng if geo.success
    end
  end

end