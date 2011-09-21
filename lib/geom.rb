module GMath3D

class Geom
  private
  @@default_tolerance = 1e-6
  @tolerance

  public
  attr_accessor :tolerance
  
  def initialize
    @tolerance = @@default_tolerance
  end
  
  def self.default_tolerance
    @@default_tolerance
  end
end

end
