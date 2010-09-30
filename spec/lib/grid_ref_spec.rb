require File.dirname(__FILE__) + '/../spec_helper'

describe GridRef do
  
  it "should reject a bad gridref string" do
    lambda{ GridRef.new("S123456") }.should raise_error
    lambda{ GridRef.new("SD12345") }.should raise_error
    lambda{ GridRef.new("SD123456") }.should_not raise_error
    lambda{ GridRef.new("SD1234567890") }.should_not raise_error
  end
  
  describe " standard transformation" do
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

describe String do
  describe "that is a grid reference" do
    it "should respond positively to .is_gridref?" do
      "SD123456".is_gridref?.should be_true
    end
    
    it "should respond to .to_latlng with coordinates" do
      "SD2873178452".to_latlng.should == "54.196698, -3.092537"
    end

    it "should pass through options to the grid ref" do
      "SD2873178452".to_latlng(:datum => :wgs84).should == "54.19685, -3.093901"
      "SD2873178452".to_wgs84.should == "54.19685, -3.093901"
    end
  end

  describe "that is a not recognised as a grid reference" do
    it "should respond negatively to .is_gridref?" do
      "banana".is_gridref?.should be_false
    end
    
    it "should return nil to .to_latlng" do
      lambda{ "banana".to_latlng }.should_not raise_error
      "banana".to_latlng.should be_nil
    end
  end
  
end
