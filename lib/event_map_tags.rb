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
	  bounds = [[lats.max, lngs.min], [lats.min, lngs.max]]
    map.center_zoom_on_bounds_init(bounds)
    
    map.div + map.to_html
  end
  
  tag "events:map_header" do |tag|
    GMap.header(:with_vml => false)
  end
end