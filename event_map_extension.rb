# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class EventMapExtension < Radiant::Extension
  version "1.0"
  description "Small additions to support the display of calendar events on a map, separated here because only of interest to a few."
  url "spanner.org"
  
  extension_config do |config|
    config.extension 'event_calendar'
    config.gem 'geokit'
  end
  
  def activate
    Event.send :include, Mappable
    EventVenue.send :include, Mappable
    Page.send :include, EventMapTags
  end
  
  def deactivate
    # admin.tabs.remove "Event Map"
  end
  
end
