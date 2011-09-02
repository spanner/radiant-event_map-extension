# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

require "radiant-event_map-extension"

class EventMapExtension < Radiant::Extension
  version RadiantEventMapExtension::VERSION
  description RadiantEventMapExtension::DESCRIPTION
  url RadiantEventMapExtension::URL
  
  def activate
    require 'angle_conversions'             # adds degree/radian conversions to Numeric
    require 'string_conversions'            # adds lat/long and gridref conversions to String
    require 'grid_ref'                      # converts coordinates from UK grid references to lat/long
    EventVenue.send :include, Mappable      # adds geolocation on validation
    Page.send :include, EventMapTags        # defines a very basic events:googlemap tag
  end
  
end
