# -*- coding: cp932 -*-
require 'gmath3D'

module GMath3D
  #
  # Vector3 represents a point or a vector on 3D space.
  #
  class Vector3 < Geom
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    # [Input]
    #  _x_, _y_, _z_ should be Numeric.
    # [Output]
    #  return new instance as Vector3.
    def initialize(x=0.0,y=0.0,z=0.0)
      Util3D.check_arg_type(Numeric, x)
      Util3D.check_arg_type(Numeric, y)
      Util3D.check_arg_type(Numeric, z)
      super()
      @x = x
      @y = y
      @z = z
    end

    def to_element_s
      "[#{@x}, #{@y}, #{@z}]"
    end

    def to_s
      "Vector3" + to_element_s
    end

    def to_ary
      [@x,@y,@z]
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return true if rhs equals myself.
    def ==(rhs)
      return false if( !rhs.kind_of?(Vector3) )
      equals_inner(rhs)
    end

    # For using Vector3 as hash key
    def hash
      [@x.to_f, @y.to_f, @z.to_f].hash
    end
    def eql?(rhs)
      equals_inner(rhs)
    end

    # [Output]
    #  return axially aligned bounding box as Box.
    def box
      return Box.new(self, self)
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return added result as Vector3.
    def +(rhs)
      add(rhs)
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return subtracted result as Vector3.
    def -(rhs)
      subtract(rhs)
    end

    # [Input]
    #  _rsh_ should be Numeric.
    # [Output]
    #  return multiplyed result as Vector3.
    def *(rhs)
      multiply(rhs)
    end

    # [Input]
    #  _rhs_ should be Numeric.
    # [Output]
    #  return divided result as Vector3.
    def /(rhs)
      divide(rhs)
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return inner product as Numeric
    def dot(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      self.x*rhs.x + self.y*rhs.y + self.z*rhs.z
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return cross product as Vector3.
    def cross(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      Vector3.new(
              self.y*rhs.z - self.z*rhs.y,
              self.z*rhs.x - self.x*rhs.z,
              self.x*rhs.y - self.y*rhs.x)
    end

    # [Output]
    #  return orthogonal vector as Vector3.
    def arbitrary_orthogonal
      return Vector3.new() if(self.length < self.tolerance)

      if(!self.parallel?( Vector3.new(0.0, 1.0, 0.0) ))
        un_parallel_vec = Vector3.new(0.0,1.0,0.0)
      elsif(!self.parallel?( Vector3.new(0.0,0.0,1.0) ))
        un_parallel_vec = Vector3.new(0.0,0.0,1.0)
      else
	un_parallel_vec = Vector3.new(1.0,0.0,0.0)
      end

      orthogonal = self.cross(un_parallel_vec)
      return orthogonal.normalize
    end

    # [Output]
    #  return vector length as Numeric
    def length
      Math::sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return distance between two points as Numeric.
    def distance(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      Math::sqrt((self.x - rhs.x)*(self.x - rhs.x) + (self.y - rhs.y)*(self.y - rhs.y) + (self.z - rhs.z)*(self.z - rhs.z))
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return two vectors angle as Numeric (rad).
    def angle(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      vec1Length = self.length ;
      vec2Length = rhs.length   ;
      return 0.0 if(vec1Length*vec2Length < self.tolerance )
      v = self.dot(rhs)/(vec1Length*vec2Length)
      Math::acos( v )
    end

    # [Output]
    #  return normalized vector as Vector3
    def normalize()
      self / self.length.to_f
    end

    # [Input]
    #  _rhs_ should be Vector3
    # [Output]
    #  return true if myself and rhs is parallel as boolean
    def parallel?(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      return false if(self.length < self.tolerance or rhs.length < rhs.tolerance)
      return false if(self.cross(rhs).length > self.tolerance)
      return true
    end

    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return true if myself and rhs have same direction as boolean.
    def same_direction?(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      return false if(!parallel?(rhs))
      return false if(self.dot(rhs) < self.tolerance)
      return true
    end

    # This function projects self vector to rhs vector.
    # [Input]
    #  _rhs_ should be Vector3.
    # [Output]
    #  return projected result as Vector3.
    def project_to(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      return Vector3.new, 0.0 if( rhs.length < rhs.tolerance )
      parameter = self.dot( rhs ) / ( rhs.x * rhs.x + rhs.y * rhs.y + rhs.z * rhs.z ).to_f
      return rhs*parameter, parameter
    end

    # [Output]
    #  return column vector as Matrix
    def to_column_vector
      return Matrix.column_vector([x,y,z])
    end

    private
    def equals_inner(rhs)
      return false if((self.x - rhs.x).abs > @tolerance) 
      return false if((self.y - rhs.y).abs > @tolerance) 
      return false if((self.z - rhs.z).abs > @tolerance) 
      true
    end
    def add(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      Vector3.new(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
    end
    def subtract(rhs)
      Util3D.check_arg_type(Vector3, rhs)
      Vector3.new(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
    end
    def multiply(rhs)
      Util3D.check_arg_type(::Numeric, rhs)
      Vector3.new(self.x * rhs, self.y * rhs, self.z * rhs)
    end
    def divide(rhs)
      Util3D.check_arg_type(::Numeric, rhs)
      Vector3.new(self.x.to_f / rhs, self.y / rhs.to_f, self.z / rhs.to_f)
    end
  end
end

