# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

require "radiant-event_map-extension"

class EventMapExtension < Radiant::Extension
  version RadiantEventMapExtension::VERSION
  description RadiantEventMapExtension::DESCRIPTION
  url RadiantEventMapExtension::URL
  
  extension_config do |config|
    config.gem "geokit"
  end

  def activate
    require 'angle_conversions'           # adds String.to_latlng and some degree/radian conversions to Numeric
    require 'grid_ref'                    # converts from UK grid references to lat/long
    EventVenue.send :include, Mappable    # adds geolocation on validation
    Page.send :include, EventMapTags      # currently only a basic events:googlemap tag
  end
  
end
