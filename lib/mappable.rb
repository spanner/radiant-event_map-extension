module Mappable
  include Geokit::Geocoders
  
  def self.included(base)
    base.class_eval {
      before_validation :geocode_location
    }
  end
  
  def geocode
    "#{lat},#{lng}" if geocoded
  end
  
  def geocoded
    true if lat && lng
  end
  
  def geocode_basis
    postcode || address || location
  end
  
  def url
    if url = read_attribute(:url) && !url.blank?
      url
    elsif geocoded
      if Radiant::Config['event_map:link_to'] == 'bing'
        "http://www.bing.com/maps/?v=2&cp=#{lat}~#{lng}&lvl=12&sty=s&eo=0"
      else
        "http://maps.google.com/maps?q=#{lat}+#{lng}+(#{title})"
      end
    end
  end
  
private

  def geocode_location
    unless geocode_basis.blank? || ENV['RAILS_ENV'] == 'test'
      if geocode_basis.is_gridref? && gr = GridRef.new(geocode_basis)
        self.lat = gr.lat
        self.lng = gr.lng
      else
        bias = Radiant::Config['event_map.zone'] || 'uk'
        geo = Geokit::Geocoders::MultiGeocoder.geocode(location, :bias => bias)
        errors.add(:postcode, "Could not Geocode location: please specify here") if !geo.success
        self.lat, self.lng = geo.lat, geo.lng if geo.success
      end
    end
  end

end