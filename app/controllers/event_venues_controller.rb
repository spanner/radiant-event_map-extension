# We inherit from EventsController to share subsetting functionality
# All we do here is organise that information by venue.

class EventVenuesController < EventsController
  helper_method :venues, :events_at_venue, :slug_for_venue
  radiant_layout { Radiant::Config['event_map.layout'] }
  
  def index
    respond_to do |format|
      format.html { }
      format.js {
        render :layout => false
      }
      format.json {
        render :json => venue_events.to_json
      }
    end
  end
  
  # event_finder is in EventsController. Returns a scope than may apply a period or some other restriction.

  def events
    @events ||= event_finder
  end
  
  def venues
    @venues ||= events.map(&:event_venue).compact.uniq
  end
  
  # events are stashed in venue buckets to avoid returning to the database
  
  def events_at_venue(venue)
    venue_events[venue.id]
  end
  
  def slug_for_venue(venue)
    if events = venue_events[venue.id]
      events.first.calendar.slug
    end
  end
    
protected

  def venue_events
    @venue_events ||= events.each_with_object({}) do |event, venues|
      if event.event_venue
        venues[event.event_venue.id] ||= []
        venues[event.event_venue.id].push(event)
      end
    end
  end

end