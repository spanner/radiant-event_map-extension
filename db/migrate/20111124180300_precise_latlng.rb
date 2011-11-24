class LatLong < ActiveRecord::Migration
  def self.up
    change_column :event_venues, :lat, :decimal, :precision => 15, :scale => 10
    change_column :event_venues, :lng, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    change_column :event_venues, :lat, :string
    change_column :event_venues, :lng, :string
  end
end
