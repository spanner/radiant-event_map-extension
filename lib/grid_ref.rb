# adapted from Geography::NationalGrid by and (c) P Kent
# with reference to the Ordnance Survey guide to coordinate systems in the UK
# http://www.ordnancesurvey.co.uk/oswebsite/gps/information/coordinatesystemsinfo/guidecontents/

class Ellipsoid
  attr_accessor :a, :b, :e2

  def initialize(a,b)
    @a = a
    @b = b
  end
  
  def ecc
    (a**2 - b**2)/(a**2)
  end
end

class GridRef
  OsTiles = {
  	:a => [0,4], :b => [1,4], :c => [2,4], :d => [3,4], :e => [4,4],
  	:f => [0,3], :g => [1,3], :h => [2,3], :j => [3,3], :k => [4,3],
  	:l => [0,2], :m => [1,2], :n => [2,2], :o => [3,2], :p => [4,2],
  	:q => [0,1], :r => [1,1], :s => [2,1], :t => [3,1], :u => [4,1],
  	:v => [0,0], :w => [1,0], :x => [2,0], :y => [3,0], :z => [4,0],
  }
  FalseOrigin = [2,1]
  SquareSize = [nil, 10000, 1000, 100, 10, 1]    # shorter grid ref = larger square.

  @@iteration_ceiling = 1000
  @@ellipsoids = {
    :osgb36 => Ellipsoid.new(6377563.396, 6356256.910),
    :wgs84 => Ellipsoid.new(6378137.000, 6356752.3141),
    :ie65 => Ellipsoid.new(6377340.189, 6356034.447),
    :utm => Ellipsoid.new(6378388.000, 6356911.946)
  }
  @@projections = {
    :gb => {:scale => 0.9996012717, :Phio => 49.to_radians, :Lambdao => -2.to_radians, :Eo => 400000, :No => -100000, :ellipsoid => :osgb36},
    :ie => {:scale => 1.000035, :Phio => 53.5.to_radians, :Lambdao => -8.to_radians, :Eo => 250000, :No => 250000, :ellipsoid => :ie65},
    :utm29 => {:scale => 0.9996, :Phio => 0, :Lambdao => -9.to_radians, :Eo => 500000, :No => 0, :ellipsoid => :utm},
    :utm30 => {:scale => 0.9996, :Phio => 0, :Lambdao => -3.to_radians, :Eo => 500000, :No => 0, :ellipsoid => :utm},
    :utm31 => {:scale => 0.9996, :Phio => 0, :Lambdao => 3.to_radians, :Eo => 500000, :No => 0, :ellipsoid => :utm}
  }
  @@helmerts = {
    :wgs84 => { :tx => 446.448, :ty => -125.157, :tz => 542.060, :rx => 0.1502, :ry => 0.2470, :rz => 0.8421, :s => -20.4894 }
  }
  
  cattr_accessor :iteration_ceiling
  attr_accessor :gridref, :projection, :ellipsoid, :datum, :options
  
  @@defaults = {
    :projection => :gb,   # mercator projection of input gridref. Can be any projection name: usually :ie or :gb
    :precision => 6       # decimal places in the output lat/long
  }
  
  def initialize(string, options={})
    raise ArgumentError, "invalid grid reference string '#{string}'." unless string.is_gridref?
    @gridref = string.upcase
    @options = @@defaults.merge(options)
    @projection = @@projections[@options[:projection]]
    @ellipsoid = @@ellipsoids[@projection[:ellipsoid]]
    @datum = @options[:datum]
    self
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
    if tile
      major = OsTiles[tile[0,1].downcase.to_sym ]
      minor = OsTiles[tile[1,1].downcase.to_sym]
    	@offset ||= {
        :e => (500000 * (major[0] - FalseOrigin[0])) + (100000 * minor[0]),
      	:n => (500000 * (major[1] - FalseOrigin[1])) + (100000 * minor[1])
    	}
    else
      { :e => 0, :n => 0 }
    end
  end
  
  def easting
    @east ||= offsets[:e] + digits[0, resolution].to_i * SquareSize[resolution]
  end
  
  def northing
    @north ||= offsets[:n] + digits[resolution, resolution].to_i * SquareSize[resolution]
  end
  
  def lat
    coordinates[:lat].to_degrees.round(self.options[:precision])
  end
  
  def lng
    coordinates[:lng].to_degrees.round(self.options[:precision])
  end
  
  def to_s
    gridref.to_s
  end
  
  def to_latlng
    "#{lat}, #{lng}"
  end

  def coordinates
    unless @coordinates
      # variable names correspond roughly to symbols in the OS algorithm, lowercased:
      # n0 = northing of true origin 
      # e0 = easting of true origin 
      # f0 = scale factor on central meridian
      # phi0 = latitude of true origin 
      # lambda0 = longitude of true origin and central meridian.
      # e2 = eccentricity squared
      # a = length of polar axis of ellipsoid
      # b = length of equatorial axis of ellipsoid
      # ning & eing are the northings and eastings of the supplied gridref
      # phi and lambda are the discovered latitude and longitude
      
      ning = northing
      eing = easting

      n0 = projection[:No]
      e0 = projection[:Eo]
      phi0 = projection[:Phio]
      l0 = projection[:Lambdao]
      f0 = projection[:scale]
      
      a = ellipsoid.a
      b = ellipsoid.b
      e2 = ellipsoid.ecc
      
      # the rest is taken from the OS equations with help from CPAN's Geography::NationalGrid
      # and only enough understanding to transliterate it, and sometimes not even that.

      n = (a - b) / (a + b)
    	m = 0
      phi = phi0
    
      # iterate to within acceptable distance of solution
      
    	count = 0
    	while ((ning - n0 - m) >= 0.001) do
        raise RuntimeError "Demercatorising equation has not converged. Discrepancy after #{count} cycles is #{ning - n0 - m}" if count >= @@iteration_ceiling

    		phi = ((ning - n0 - m) / (a * f0)) + phi
        ma = (1 + n + (1.25 * n**2) + (1.25 * n**3)) * (phi - phi0)
        mb = ((3 * n) + (3 * n**2) + (2.625 * n**3)) * Math.sin(phi - phi0) * Math.cos(phi + phi0)
        mc = ((1.875 * n**2) + (1.875 * n**3)) * Math.sin(2 * (phi - phi0)) * Math.cos(2 * (phi + phi0))
        md = (35/24) * (n**3) * Math.sin(3 * (phi - phi0)) * Math.cos(3 * (phi + phi0))
        m = b * f0 * (ma - mb + mc - md)
    		count += 1
  	  end
  	  
  	  # engage alphabet soup
  	  
  	  nu = a * f0 * ((1-(e2) * ((Math.sin(phi)**2))) ** -0.5)
    	rho = a * f0 * (1-(e2)) * ((1-(e2)*((Math.sin(phi)**2))) ** -1.5)
    	eta2 = (nu/rho - 1)
    	
    	# fire
    	
    	vii = Math.tan(phi) / (2 * rho * nu)
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

      # here coordinates are still in radians and osgb36

      @coordinates = helmerted(phi, lambda)
    end
    
    @coordinates
  end
  
  def helmerted(phi, lambda)
    return {:lat => phi, :lng => lambda} unless @datum && @datum != :osgb36
    target_datum = @@ellipsoids[@datum] 
    t = @@helmerts[@datum]
    
    if t && target_datum

      # convert polar to cartesian coordinates using osgb datum

      a = @@ellipsoids[:osgb36].a
      b = @@ellipsoids[:osgb36].b
      e2 = @@ellipsoids[:osgb36].ecc
      
      nu = a / (Math.sqrt(1 - e2 * Math.sin(phi)**2))
      h = 0

      x1 = (nu + h) * Math.cos(phi) * Math.cos(lambda)
      y1 = (nu + h) * Math.cos(phi) * Math.sin(lambda)
      z1 = ((1 - e2) * nu + h) * Math.sin(phi)
      
      # parameterise helmert transformation

      tx = t[:tx]
      ty = t[:ty]
      tz = t[:tz]
      rx = (t[:rx]/3600).to_radians
      ry = (t[:ry]/3600).to_radians
      rz = (t[:rz]/3600).to_radians
      s1 = t[:s]/1e6 + 1

      # apply helmert transformation
      
      xp = tx + x1*s1 - y1*rz + z1*ry
      yp = ty + x1*rz + y1*s1 - z1*rx
      zp = tz - x1*ry + y1*rx + z1*s1
            
      # convert back to polar coordinates using target datum

      a = target_datum.a
      b = target_datum.b
      e2 = target_datum.ecc
      precision = 4 / a
      
      p = Math.sqrt(xp**2 + yp**2)
      phi = Math.atan2(zp, p*(1-e2));
      phip = 2 * Math::PI

      count = 0
      while (phi-phip).abs > precision do
        raise RuntimeError "Helmert transformation has not converged. Discrepancy after #{count} cycles is #{phi-phip}" if count >= @@iteration_ceiling
        
        nu = a / Math.sqrt(1 - e2 * Math.sin(phi)**2)
        phip = phi
        phi = Math.atan2(zp + e2 * nu * Math.sin(phi), p)
        count += 1
      end 

      lambda = Math.atan2(yp, xp)

      {:lat => phi, :lng => lambda}
      
    else
      raise RuntimeError, "Missing ellipsoid or Helmert transformation for #{@datum}"
    end
  end
  
private

  def sec(radians)
    1 / Math.cos(radians)
  end
  
end
