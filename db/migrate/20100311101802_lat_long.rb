class LatLong < ActiveRecord::Migration
  def self.up
    add_column :events, :lat, :string
    add_column :events, :lng, :string
    add_column :event_venues, :lat, :string
    add_column :event_venues, :lng, :string
    add_index  :events, [:lat, :lng]
    add_index  :event_venues, [:lat, :lng]
    
  end

  def self.down
    remove_column :events, :lat
    remove_column :events, :lng 
    remove_column :event_venues, :lat
    remove_column :event_venues, :lng
    remove_index  :events, [:lat, :lng]
    remove_index  :event_venues, [:lat, :lng]
  end
end
