require File.dirname(__FILE__) + '/../spec_helper'

describe GridRef do
  
  it "should reject a bad gridref string" do
    lambda{ GridRef.new("S123456") }.should raise_error
    lambda{ GridRef.new("SD12345") }.should raise_error
    lambda{ GridRef.new("SD123456") }.should_not raise_error
  end
  
  describe " transformation" do
    before do
      @gr = GridRef.new("SD123456")
    end
    
    it "should calculate grid square offset" do
      @gr.offsets[:n].should == 400000
      @gr.offsets[:e].should == 300000
    end

    it "should calculate northing" do
      @gr.northing.should == 445600
    end

    it "should calculate easting" do
      @gr.easting.should == 312300
    end
    
    it "should calculate latitude and longitude" do
      @gr.coordinates[:lat].should be_close(0.940713919642114, 0.00001)
      @gr.coordinates[:lng].should be_close(-0.0582041863000365, 0.00001)
    end
    
    it "should return latitude and longitude in degrees" do
      @gr.lat.should be_close(53.898937324702, 0.00001)
      @gr.lng.should be_close(-3.33485422498526, 0.00001)
    end
    
    it "should return a pair of coordinates to .to_latlng" do
      @gr.to_latlng.should == "53.898937324702, -3.33485422498526"
    end
  end
end

describe String do
  describe "that is a grid reference" do
    it "should respond positively to .is_gridref?" do
      "SD123456".is_gridref?.should be_true
    end
    
    it "should respond to .to_latlng with coordinates" do
      "SD123456".to_latlng.should == "53.898937324702, -3.33485422498526"
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
