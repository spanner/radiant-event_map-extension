class GetGeocodes < ActiveRecord::Migration
  def self.up
    # [Event, EventVenue].each do |klass|
    #   klass.reset_column_information
    #   klass.find(:all).each do |this|
    #     this.send :geocode_location
    #     if this.changed?
    #       p "#{this.location} -> #{this.geocode}"
    #       this.save!
    #     end
    #   end
    # end
  end

  def self.down
  end
end
