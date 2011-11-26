require 'gmath3D'

module GMath3D
  #
  # Quat represents quaternion.
  #
  class Quat
public
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z
    attr_accessor :w

    # [Input]
    #  _x_, _y_, _z_, _w_should be Numeric.
    # [Output]
    #  return new instance of Quat.
    def initialize(x=0.0,y=0.0,z=0.0,w=0.0)
      Util3D.check_arg_type(Numeric, x)
      Util3D.check_arg_type(Numeric, y)
      Util3D.check_arg_type(Numeric, z)
      Util3D.check_arg_type(Numeric, w)
      super()
      @x = x
      @y = y
      @z = z
      @w = w
    end

    # [Input]
    #  _axsi_ should be Vector3 and _angle_ should be Numeric.
    # [Output]
    #  return new instance of Quat.
    def self.from_axis(axis, angle)
      Util3D.check_arg_type(Vector3, axis)
      Util3D.check_arg_type(Numeric, angle)
      s = Math.sin(0.5*angle)
      x = s * axis.x
      y = s * axis.y
      z = s * axis.z
      w = Math.cos(0.5*angle)
      return Quat.new(x,y,z,w)
    end

    # [Input]
    #  _matrix_ should be Matrix which row and column size are 3.
    # [Output]
    #  return new instance of Quat.
    def self.from_matrix(mat)
      fourWSquaredMinus1 = mat[0,0] + mat[1,1] + mat[2,2]
      fourXSquaredMinus1 = mat[0,0] - mat[1,1] - mat[2,2]
      fourYSquaredMinus1 = mat[1,1] - mat[0,0] - mat[2,2]
      fourZSquaredMinus1 = mat[2,2] - mat[0,0] - mat[1,1]

      biggestIndex = 0
      fourBiggestSquaredMinus1 = fourWSquaredMinus1
      if(fourXSquaredMinus1 > fourBiggestSquaredMinus1)
        fourBiggestSquaredMinus1 = fourXSquaredMinus1
        biggestIndex = 1
      end
      if(fourYSquaredMinus1 > fourBiggestSquaredMinus1)
        fourBiggestSquaredMinus1 = fourYSquaredMinus1
        biggestIndex = 2
      end
      if(fourZSquaredMinus1 > fourBiggestSquaredMinus1)
        fourBiggestSquaredMinus1 = fourZSquaredMinus1
        biggestIndex = 3
      end

      biggestVal = Math.sqrt(fourBiggestSquaredMinus1 + 1.0) * 0.5
      multi = 0.25 / biggestVal

      case biggestIndex
      when 0
        w = biggestVal
        x = (mat[1,2] - mat[2,1]) *multi
        y = (mat[2,0] - mat[0,2]) *multi
        z = (mat[0,1] - mat[1,0]) *multi
      when 1
        x = biggestVal;
        w = (mat[1,2] - mat[2,1]) *multi
        y = (mat[0,1] + mat[1,0]) *multi
        z = (mat[2,0] + mat[0,2]) *multi
      when 2
        y = biggestVal;
        w = (mat[2,0] - mat[0,2]) *multi
        x = (mat[0,1] + mat[1,0]) *multi
        z = (mat[1,2] + mat[2,1]) *multi
      when 3
        z = biggestVal;
        w = (mat[0,1] - mat[1,0]) *multi
        x = (mat[2,0] + mat[0,2]) *multi
        y = (mat[1,2] + mat[2,1]) *multi
      end
      return Quat.new(x,y,z,w)
    end

    def to_element_s
      "[#{@x}, #{@y}, #{@z}, #{@w}]"
    end

    def to_s
      "Quat" + to_element_s
    end

    # [Input]
    #  _rhs_ should be Quat.
    # [Output]
    #  return true if rhs equals myself.
    def ==(rhs)
      return false if( !rhs.kind_of?(Quat) )
      return false if(self.x != rhs.x)
      return false if(self.y != rhs.y)
      return false if(self.z != rhs.z)
      return false if(self.w != rhs.w)
      true
    end

    # [Output]
    #  return conjugated Quat.
    def conjugate
      return Quat.new( -self.x, -self.y, -self.z, self.w)
    end

    # [Output]
    #  return normalized result as Quat.
    def normalize()
      mag = Math.sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
      return Quat.new(self.x/mag, self.y/mag, self.z/mag, self.w/mag)
    end

    # [Input]
    #  _rhs_ should be Quat.
    # [Output]
    #  return added result as Quat.
    def +(rhs)
      Util3D.check_arg_type(Quat, rhs)
      t1 = Vector3.new(self.x, self.y, self.z)
      t2 = Vector3.new(rhs.x, rhs.y, rhs.z)
      dot = t1.dot(t2)
      t3 = t2.cross(t1)

      t1 *= rhs.w
      t2 *= self.w

      tf = t1 + t2 + t3
      rtn_w = self.w * rhs.w - dot

      return Quat.new(tf.x, tf.y, tf.z, rtn_w)
    end

    # [Input]
    #  _rsh_ should be Quat.
    # [Output]
    #  return (outer products) multiplyed result as Quat.
    def *(rhs)
      Util3D.check_arg_type(Quat, rhs)

      pw = self.w; px = self.x; py = self.y; pz = self.z;
      qw = rhs.w ; qx = rhs.x ; qy = rhs.y ; qz = rhs.z;

      w = pw * qw - px * qx - py * qy - pz * qz
      x = pw * qx + px * qw + py * qz - pz * qy
      y = pw * qy - px * qz + py * qw + pz * qx
      z = pw * qz + px * qy - py * qx + pz * qw
      return Quat.new( x,y,z,w )
    end
  end
end

