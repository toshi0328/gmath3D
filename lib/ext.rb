require 'gmath3D'
require 'matrix'

module GMath3D
  class ::Matrix
    def self.from_axis(axis, angle)
      Util3D::check_arg_type(Vector3, axis)
      Util3D::check_arg_type(Numeric, angle)

      return Matrix[
             [axis.x*axis.x*(1 - Math.cos(angle)) +        Math.cos(angle),
                      axis.x*axis.y*(1 - Math.cos(angle)) + axis.z*Math.sin(angle),
                      axis.x*axis.z*(1 - Math.cos(angle)) - axis.y*Math.sin(angle)],
             [axis.x*axis.y*(1 - Math.cos(angle)) - axis.z*Math.sin(angle),
                      axis.y*axis.y*(1 - Math.cos(angle)) +        Math.cos(angle),
                      axis.y*axis.z*(1 - Math.cos(angle)) + axis.x*Math.sin(angle)],
             [axis.x*axis.z*(1 - Math.cos(angle)) + axis.y*Math.sin(angle),
                      axis.y*axis.z*(1 - Math.cos(angle)) - axis.x*Math.sin(angle),
                      axis.z*axis.z*(1 - Math.cos(angle)) +        Math.cos(angle)]]
    end

    def self.from_quat(quat)
      Util3D::check_arg_type(Quat, quat)
      qw = quat.w
      qx = quat.x
      qy = quat.y
      qz = quat.z

      x2 = 2.0 * qx * qx;
      y2 = 2.0 * qy * qy;
      z2 = 2.0 * qz * qz;
      xy = 2.0 * qx * qy;
      yz = 2.0 * qy * qz;
      zx = 2.0 * qz * qx;
      wx = 2.0 * qw * qx;
      wy = 2.0 * qw * qy;
      wz = 2.0 * qw * qz;

      return Matrix[
             [ 1.0 - y2 - z2, xy + wz, zx - wy],
             [ xy - wz, 1.0 - z2 - x2, yz + wx],
             [ zx + wy, yz - wx, 1.0 - x2 - y2]]
    end

    alias_method :multi_inner, :*  # hold original multiply processing
    def multi_new(rhs)
      if(rhs.kind_of?(Vector3))
        ans = self.multi_inner(rhs.to_column_vector)
      return Vector3.new(ans[0,0], ans[1,0], ans[2,0])
      end
      multi_inner(rhs)
    end
    alias_method :*, :multi_new   # overwrite new multiply processing
  end

  class ::Array
    def sum
      s, n = self.sum_with_number
      return s
    end
    def avg
      s, n = self.sum_with_number
      return s / n
    end

    def sum_with_number
      return nil, 0 if(self.size <= 0)
      s = nil
      n = 0
      self.each do |v|
        next if v.nil?
        if(s==nil)
          s = v
        else
          s += v
        end
        n += 1
      end
      return s, n
    end
  end
end
