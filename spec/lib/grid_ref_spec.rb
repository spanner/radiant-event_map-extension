require File.dirname(__FILE__) + '/../spec_helper'

describe GridRef do
  
  it "should reject a bad gridref string" do
    lambda{ GridRef.new("S123456") }.should raise_error
    lambda{ GridRef.new("SD12345") }.should raise_error
    lambda{ GridRef.new("SD123456") }.should_not raise_error
    lambda{ GridRef.new("SD1234567890") }.should_not raise_error
  end
  
  describe "standard transformation" do
    before do
      @gr = GridRef.new("SD2873178452")
    end

    it "should calculate grid square offset" do
      @gr.offsets[:n].should == 400000
      @gr.offsets[:e].should == 300000
    end

    it "should calculate northing" do
      @gr.northing.should == 478452
    end

    it "should calculate easting" do
      @gr.easting.should == 328731
    end
    
    it "should calculate latitude and longitude" do
      @gr.coordinates[:lat].should be_close(0.945910830410541, 0.000001)
      @gr.coordinates[:lng].should be_close(-0.0539749456547823, 0.000001)
    end

    it "should return latitude and longitude in degrees" do
      @gr.lat.should == 54.196698
      @gr.lng.should == -3.092537
    end
    
    it "should return the right number of decimal places" do
      GridRef.new("SD2873178452", :precision => 2).lat.should == 54.20
      GridRef.new("SD2873178452", :precision => 4).lat.should == 54.1967
    end
  end
  
  describe " wgs84 transformation" do
    before do
      @gr = GridRef.new("SD2873178452", :datum => :wgs84)
    end
    
    it "should calculate latitude and longitude" do
      @gr.coordinates[:lat].should be_close(0.945913481900098, 0.000001)
      @gr.coordinates[:lng].should be_close(-0.0539987551350719, 0.000001)
    end
    
    it "should return latitude and longitude in degrees" do
      @gr.lat.should == 54.196850
      @gr.lng.should == -3.093901
    end
  end
end
