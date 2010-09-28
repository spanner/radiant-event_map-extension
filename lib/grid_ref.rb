# much borrowed from Geography::NationalGrid
# by P Kent
# with reference to the standard transformation equations 
# gathered and summarised by the Ordnance Survey

class GridRef
  OsTiles = {
  	:a => [0,4], :b => [1,4], :c => [2,4], :d => [3,4], :e => [4,4],
  	:f => [0,3], :g => [1,3], :h => [2,3], :j => [3,3], :k => [4,3],
  	:l => [0,2], :m => [1,2], :n => [2,2], :o => [3,2], :p => [4,2],
  	:q => [0,1], :r => [1,1], :s => [2,1], :t => [3,1], :u => [4,1],
  	:v => [0,0], :w => [1,0], :x => [2,0], :y => [3,0], :z => [4,0],
  }
  FalseOrigin = [2,1]
  SquareSize = [nil, 10000, 1000, 100, 10, 1]    # shorter grid ref = larger square. no need to calculate it.

  @@iteration_ceiling = 1000;
  @@ellipsoid = {:a => 6377563.396, :b => 6356256.910, :label => "OSBG36"}
  @@projection = {:scale => 0.9996012717, :Phio => 49.to_radians, :Lambdao => -2.to_radians, :Eo => 400000, :No => -100000, :label => "National Grid"}
  
  cattr_accessor :iteration_ceiling
  attr_accessor :gridref, :projection, :ellipsoid
  
  def initialize(string)
    raise ArgumentError, "invalid grid reference string '#{string}'." unless string.is_gridref?
    self.gridref = string.upcase
    self.projection = @@projection
    self.ellipsoid = @@ellipsoid
  end
  
  def to_s
    gridref.to_s
  end
  
  def to_latlng
    "#{lat}, #{lng}"
  end
  
  def tile
    @tile ||= gridref[0,2]
  end
  
  def digits
    @digits ||= gridref[2,10]
  end
  
  def resolution
    digits.length / 2
  end
  
  def offsets
    major = OsTiles[ tile[0,1].downcase.to_sym ]
    minor = OsTiles[tile[1,1].downcase.to_sym]
    
    Rails.logger.warn "Major: #{major.inspect}. Minor: #{minor.inspect}"
    
  	@offset ||= {
      :e => (500000 * (major[0] - FalseOrigin[0])) + (100000 * minor[0]),
    	:n => (500000 * (major[1] - FalseOrigin[1])) + (100000 * minor[1])
  	}
  end
  
  def easting
    @east ||= offsets[:e] + digits[0, resolution].to_i * SquareSize[resolution]
  end
  
  def northing
    @north ||= offsets[:n] + digits[resolution, resolution].to_i * SquareSize[resolution]
  end
  
  def lat
    coordinates[:lat].to_degrees
  end
  
  def lng
    coordinates[:lng].to_degrees
  end
        
  def coordinates
    unless @coordinates
      # variable names correspond roughly to symbols in the OS algorithm, lowercased:
      # n0 = northing of true origin 
      # e0 = easting of true origin 
      # f0 = scale factor on central meridian
      # phi0 = latitude of true origin 
      # lambda0 = longitude of true origin and central meridian.
      # a = length of polar axis of ellipsoid
      # b = length of equatorial axis of ellipsoid
      # n & e are the northings and eastings of the supplied gridref
      # phi and lambda are the discovered latitude and longitude
      
      ning = northing
      eing = easting

      n0 = projection[:No]
      e0 = projection[:Eo]
      phi0 = projection[:Phio]
      l0 = projection[:Lambdao]
      f0 = projection[:scale]
      
      a = ellipsoid[:a]
      b = ellipsoid[:b]

      # the rest is taken from the OS equations with help from CPAN's Geography::NationalGrid
      # and only enough understanding to transliterate it, and sometimes not even that.

      e2 = (a**2 - b**2)/(a**2);

      # first approximation
    	
      phi = ((ning - n0) / (a * f0)) + phi0
      n = (a - b) / (a + b)
    
      m = b * f0 * ( \
    		  (1 + n + (1.25 * n**2) + (1.25 * n**3)) * (phi - phi0) \
    		- ((3 * n) + (3 * n**2) + (2.625 * n**3)) * Math.sin(phi - phi0) * Math.cos(phi + phi0) \
    		+ ((1.875 * n**2) + (1.875 * n**3)) * Math.sin(2 * (phi - phi0)) * Math.cos(2 * (phi + phi0)) \
    		- (35/24) * (n**3) * Math.sin(3 * (phi - phi0)) * Math.cos(3 * (phi + phi0)) \
    	)

      # iterate to within acceptable distance of solution
      
    	count = 0
    	while ((ning - n0 - m) >= 0.001) do
        raise RuntimeError "Demercatorising equation has not converged. Discrepancy after #{count} cycles is still #{ning - n0 - m}" if count >= @@iteration_ceiling

    		phi = ((ning - n0 - m) / (a * f0)) + phi
        m = b * f0 * ( \
    			  (1 + n + (1.25 * n**2) + (1.25 * n**3)) * (phi - phi0) \
    			- ((3 * n) + (3 * n**2) + (2.625 * n**3)) * Math.sin(phi - phi0) * Math.cos(phi + phi0) \
    			+ ((1.875 * n**2) + (1.875 * n**3)) * Math.sin(2 * (phi - phi0)) * Math.cos(2 * (phi + phi0)) \
    			- (35/24) * (n**3) * Math.sin(3 * (phi - phi0)) * Math.cos(3 * (phi + phi0)) \
    		)
    		count += 1
  	  end
  	  
  	  # engage alphabet soup
  	  
  	  nu = a * f0 * ((1-(e2) * ((Math.sin(phi)**2))) ** -0.5)
    	rho = a * f0 * (1-(e2)) * ((1-(e2)*((Math.sin(phi)**2))) ** -1.5)
    	eta2 = (nu/rho - 1)
    	
    	# fire
    	
    	vii = Math.tan(phi) / (2 * rho * nu);
    	viii = (Math.tan(phi) / (24 * rho * (nu ** 3))) * (5 + (3 * (Math.tan(phi) ** 2)) + eta2 - 9 * eta2 * (Math.tan(phi) ** 2) )
    	ix = (Math.tan(phi) / (720 * rho * (nu ** 5))) * (61 + (90 * (Math.tan(phi) ** 2)) + (45 * (Math.tan(phi) ** 4)) )
    	x = sec(phi) / nu
    	xi = (sec(phi) / (6 * nu ** 3)) * ((nu/rho) + 2 * (Math.tan(phi) ** 2))
    	xii = (sec(phi) / (120 * nu ** 5)) * (5 + (28 * (Math.tan(phi) ** 2)) + (24 * (Math.tan(phi) ** 4)))
    	xiia = (sec(phi) / (5040 * nu ** 7)) * (61 + (662 * (Math.tan(phi) ** 2)) + (1320 * (Math.tan(phi) ** 4)) + (720 * (Math.tan(phi) ** 6)))

      d = eing-e0

      # all of which was just to populate these last two equations:
      
    	phi = phi - vii*(d**2) + viii*(d**4) - ix*(d**6)
      lambda = l0 + x*d - xi*(d**3) + xii*(d**5) - xiia*(d**7)

      # note that coordinates are still in radians

      @coordinates = {:lat => phi, :lng => lambda}
    end
    
    @coordinates
  end
  
private

  def sec(radians)
    1 / Math.cos(radians)
  end
  
end

class String
  def is_gridref?
    self.upcase =~ /^(H(P|T|U|Y|Z)|N(A|B|C|D|F|G|H|J|K|L|M|N|O|R|S|T|U|W|X|Y|Z)|OV|S(C|D|E|G|H|J|K|M|N|O|P|R|S|T|U|W|X|Y|Z)|T(A|F|G|L|M|Q|R|V)){1}\d{4}(NE|NW|SE|SW)?$|((H(P|T|U|Y|Z)|N(A|B|C|D|F|G|H|J|K|L|M|N|O|R|S|T|U|W|X|Y|Z)|OV|S(C|D|E|G|H|J|K|M|N|O|P|R|S|T|U|W|X|Y|Z)|T(A|F|G|L|M|Q|R|V)){1}(\d{4}|\d{6}|\d{8}|\d{10}))$/
  end

  def to_latlng
    GridRef.new(self).to_latlng if self.is_gridref?
  end
end
