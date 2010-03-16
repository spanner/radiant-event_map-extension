module EventMapTags
  include Radiant::Taggable
  class TagError < StandardError; end
  
  desc %{
    Renders the tags that will show a google map with markers for all the events in the current list.
    Unlike other events: tags, the list will not be paginated.
    
    You need to make sure there's a gmaps_api_key.yml file in your main application/config directory.

    *Usage:* 
    <pre><code><r:events:googlemap /></code></pre>
  }
  tag "events:googlemap" do |tag|
    tag.locals.events ||= get_events(tag, false)
	  map = GMap.new("events_map")
    points = []
    # map.center_zoom_init(["52.4008075","0.2635165"], 8)
	  map.control_init(:large_map => true,:map_type => true)

    tag.locals.events.each do |event|
      tag.locals.event = event
      ll = GLatLng.new([event.lat, event.lng])
      html = %{
        <h3 class="event">#{tag.render('event:title')}</h3>
        <p class="venue">#{tag.render('event:venue')}</p>
        <p class="description">#{tag.render('event:short_description')}</p>
      }
      points.push ll
      map.overlay_init(GMarker.new(ll, :title => event.title, :info_window => html))
    end

    lats = points.map(&:lat)
    lngs = points.map(&:lng)
	  bounds = [[lats.min, lngs.max], [lats.max, lngs.min]]
    map.center_zoom_on_bounds_init(bounds)
    
    map.div + map.to_html
  end
  
  tag "events:map_header" do |tag|
    %{
<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;key=#{Radiant::Config['event_calendar.google_api_key']}&amp;hl=&amp;sensor=false" type="text/javascript"></script>      
    }  
  end
  
  tag "events:unobtrusive_googlemap" do |tag|
    %{<script type="text/javascript" charset="utf-8" src="#{events_path(url_parts.merge({:format => :js}))}"></script>}  
  end

  tag "events:googlemap_container" do |tag|
    %{<div id="events_map"></div>}
  end
end