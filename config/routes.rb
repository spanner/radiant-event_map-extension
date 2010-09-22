ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'event_venues', :action => 'index' do |m|
    m.eventmap "/map.:format"
    m.eventmap_year "/map/:year.:format"
    m.eventmap_month "/map/:year/:month.:format"
    m.eventmap_day "/map/:year/:month/:mday.:format"
  end
end
