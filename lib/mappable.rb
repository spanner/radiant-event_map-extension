require 'geokit'
require 'osgb'

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
    geocodable_columns.map{ |f| send(f) }.find{|v| !v.blank?}
  end
  
  def geocodable_columns
    [:postcode, :location, :address]
  end
  
  def url
    if url = read_attribute(:url) && !url.blank?
      url
    elsif geocoded
      format = Radiant::Config['event_map.link_format']
      format = 'google' if format.blank?
      case format
      when 'bing'
        "http://www.bing.com/maps/?v=2&cp=#{lat}~#{lng}&rtp=~pos.#{lat}_#{lng}_#{title}&lvl=15&sty=s&eo=0"
      when 'google'
        "http://maps.google.com/maps?q=#{lat}+#{lng}+(#{title})"
      when String
        interpolations = %w{lat lng title}
        interpolations.inject( format.dup ) do |result, tag|
          result.gsub(/:#{tag}/) { send( tag ) }
        end
      end
    end
  end
  
private

  def geocode_location
    unless geocode_basis.blank? || ENV['RAILS_ENV'] == 'test'
      if geocode_basis.is_gridref?
        # it's an OS grid ref
        self.lat, self.lng = geocode_basis.to_wgs84
      elsif geocode_basis.is_latlng?
        # it's already a co-ordinate pair
        self.lat, self.lng = geocode_basis.coordinates
      else
        # we will attempt to geocode it
        bias = Radiant::Config['event_map.zone'] || 'uk'
        geo = Geokit::Geocoders::MultiGeocoder.geocode(location, :bias => bias)
        errors.add(:postcode, "Could not Geocode location: please specify here") unless geo.success
        self.lat, self.lng = geo.lat, geo.lng if geo.success
      end
    end
  end

end