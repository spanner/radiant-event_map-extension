module EventMapTags
  include Radiant::Taggable
  class TagError < StandardError; end
    
  desc %{
    Pulls in both the main google map script and the local script that defines markers and zooms the map.
    To put a map on the page unobtrusively:
      
    <pre><code>
    <head>
      <r:events:googlemap_javascript />
    </head>
    <body>
      <r:events:googlemap_container />
    </body>
    </code></pre>
    
    Note that this only works on an event calendar page.
    
  }
  tag "events:googlemap_javascript" do |tag|
    %{
<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;key=#{Radiant::Config['event_calendar.google_api_key']}&amp;hl=&amp;sensor=false" type="text/javascript"></script>
<script type="text/javascript" charset="utf-8" src="#{events_path(url_parts.merge({:format => :js}))}"></script
    }  
  end
  
  desc %{
    Renders the empty div that the googlemap will populate.
  }
  tag "events:googlemap_container" do |tag|
    %{<div id="events_map"></div>}
  end
end