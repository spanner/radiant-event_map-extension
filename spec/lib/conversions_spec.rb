require File.dirname(__FILE__) + '/../spec_helper'

describe String do
  describe "that is already a lat/long pair" do
    it "should respond negatively to .is_gridref?" do
      "54.07469997904575,-3.175048828125".is_gridref?.should be_false
    end
    
    it "should respond positively to .is_latlng?" do
      "54.07469997904575,-3.175048828125".is_latlng?.should be_true
      "54.07469997904575 -3.175048828125".is_latlng?.should be_true
      "54.07469997904575 3.175048828125".is_latlng?.should be_true
      "54.0 -3.0".is_latlng?.should be_true
      "54 3".is_latlng?.should be_false
      "543".is_latlng?.should be_false
      "54-3".is_latlng?.should be_false
    end
    
    it "should respond to .to_latlng with coordinates" do
      "54.07469997904575 -3.175048828125".to_latlng.should == "54.07469997904575, -3.175048828125"
    end

    it "should convert to grid ref"
  end

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
