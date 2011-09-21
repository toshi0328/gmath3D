require 'gmath3D'

module GMath3D
  class Vector3 < Geom
public
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    def initialize(x=0.0,y=0.0,z=0.0)
      super()
      @x = x
      @y = y
      @z = z
    end
    def ==(rhs)
      equals_inner(rhs)
    end
    def +(rhs)
      add(rhs)
    end
    def -(rhs)
      subtract(rhs)
    end
    def *(rhs)
      multiply(rhs)
    end
    def /(rhs)
      divide(rhs)
    end

    def dot(rhs)
      Util.check_arg_type(Vector3, rhs)
      self.x*rhs.x + self.y*rhs.y + self.z*rhs.z
    end
    def cross(rhs)
      Util.check_arg_type(Vector3, rhs)
      Vector3.new(
              self.y*rhs.z - self.z*rhs.y,
              self.z*rhs.x - self.x*rhs.z,
              self.x*rhs.y - self.y*rhs.x)
    end

    def length
      Math::sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
    end
    def distance(rhs)
      Util.check_arg_type(Vector3, rhs)
      Math::sqrt((self.x - rhs.x)*(self.x - rhs.x) + (self.y - rhs.y)*(self.y - rhs.y) + (self.z - rhs.z)*(self.z - rhs.z))
    end
    def distance(rhs)
      Util.check_arg_type(Vector3, rhs)
      Math::sqrt((self.x - rhs.x)*(self.x - rhs.x) + (self.y - rhs.y)*(self.y - rhs.y) + (self.z - rhs.z)*(self.z - rhs.z))
    end

    def angle(rhs)
      Util.check_arg_type(Vector3, rhs)
      vec1Length = self.length ;
      vec2Length = rhs.length   ;
      return 0.0 if(vec1Length*vec2Length < self.tolerance )
      v = self.dot(rhs)/(vec1Length*vec2Length)
      Math::acos( v )
    end
    def normalize()
      self / self.length.to_f
    end

    def parallel?(rhs)
      Util.check_arg_type(Vector3, rhs)
      return false if(self.length < self.tolerance or rhs.length < rhs.tolerance)
      return false if(self.cross(rhs).length > self.tolerance)
      return true
    end
    def same_direction?(rhs)
      Util.check_arg_type(Vector3, rhs)
      return false if(!parallel?(rhs))
      return false if(self.dot(rhs) < self.tolerance)
      return true
    end

    def project_to(rhs)
      Util.check_arg_type(Vector3, rhs)
      return Vector3.new, 0.0 if( rhs.length < rhs.tolerance )
      parameter = self.dot( rhs ) / ( rhs.x * rhs.x + rhs.y * rhs.y + rhs.z * rhs.z ).to_f
      return rhs*parameter, parameter
    end
    def to_column_vector
      return Matrix.column_vector([x,y,z])
    end
    private
    def equals_inner(rhs)
      return false if( !rhs.kind_of?(Vector3) )
      return false if((self.x - rhs.x).abs > @tolerance) 
      return false if((self.y - rhs.y).abs > @tolerance) 
      return false if((self.z - rhs.z).abs > @tolerance) 
      true
    end
    def add(rhs)
      Util.check_arg_type(Vector3, rhs)
      Vector3.new(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
    end
    def subtract(rhs)
      Util.check_arg_type(Vector3, rhs)
      Vector3.new(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
    end
    def multiply(rhs)
      Util.check_arg_type(::Numeric, rhs)
      Vector3.new(self.x * rhs, self.y * rhs, self.z * rhs)
    end
    def divide(rhs)
      Util.check_arg_type(::Numeric, rhs)
      Vector3.new(self.x.to_f / rhs, self.y / rhs.to_f, self.z / rhs.to_f)
    end
  end
end

