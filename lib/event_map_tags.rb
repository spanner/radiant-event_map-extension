module EventMapTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  desc %{ 
    Drops onto the page a couple of scripts and a div with the id #map_canvas, which between them will 
    present a google map of all your events. To show only one calendar, pass its slug as a calendar attribute:
    
    <pre><code><r:events:googlemap calendar="slug" /></code></pre> 
    
  }
  tag 'events:googlemap' do |tag|
    parameters = {:format => :js}
    if tag.attr['calendar'] && calendar = Calendar.find_by_slug(tag.attr['calendar'])
      parameters[:calendar_id] = calendar.id
    end
    %{
      <div id="map_canvas"></div>
      <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
      <script type="text/javascript" src="#{eventmap_path(parameters)}"></script>
    }
  end
  
end