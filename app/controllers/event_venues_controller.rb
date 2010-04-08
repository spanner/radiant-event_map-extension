class EventVenuesController < EventsController
  helper_method :venues, :events_at_venue
  radiant_layout { |controller| controller.layout_for :event_map }

  def index
    respond_to do |format|
      format.html { }
      format.js {
        render :layout => false
      }
    end
  end
  
  def events
    @events ||= event_finder.all
  end
  
  def venues
    @venues ||= events.map(&:event_venue).uniq
  end
  
  # events are stashed in venue buckets to avoid returning to the database
  
  def events_at_venue(venue)
    venue_events[venue.id]
  end
  
protected

  def venue_events
    return @venue_events if @venue_events
    @venue_events = {}
    events.each do |e|
      @venue_events[e.event_venue.id] ||= []
      @venue_events[e.event_venue.id].push(e)
    end
    @venue_events
  end

end