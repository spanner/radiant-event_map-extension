# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class EventMapExtension < Radiant::Extension
  version "1.3.1"
  description "Small additions to geocode calendar events and display on a map, separated here because only of interest to a few."
  url "spanner.org"
  
  extension_config do |config|
    config.gem "geokit"
  end

  def activate
    require 'angle_conversions'           # adds String.to_latlng and some degree/radian conversions to Numeric
    require 'grid_ref'                    # converts from UK grid references to lat/long
    EventVenue.send :include, Mappable    # adds geolocation on validation
    Page.send :include, EventMapTags      # currently only a very basic events:googlemap tag
  end
  
end
