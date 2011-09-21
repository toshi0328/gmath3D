require 'matrix'

require 'gmath3D'

module GMath3D
  class Rectangle < Geom
public
    attr_accessor:base_point
    attr_accessor:u_vector
    attr_accessor:v_vector

    def initialize(base_point_arg = Vector3.new(), u_vector_arg = Vector3.new(1,0,0), v_vector_arg = Vector3.new(0,1,0))
      Util.check_arg_type(::Vector3, base_point_arg)
      Util.check_arg_type(::Vector3, u_vector_arg)
      Util.check_arg_type(::Vector3, v_vector_arg)
      super()
      self.base_point = base_point_arg
      self.u_vector = u_vector_arg
      self.v_vector = v_vector_arg
    end

    def point(u, v)
      Util.check_arg_type(::Numeric, u)
      Util.check_arg_type(::Numeric, v)
      return base_point + u_vector*u + v_vector*v
    end

    def edges
      edge_ary = Array.new(4)
      edge_ary[0] = FiniteLine.new( base_point, base_point+u_vector)
      edge_ary[1] = FiniteLine.new( base_point+u_vector, base_point+u_vector+v_vector)
      edge_ary[2] = FiniteLine.new( base_point+u_vector+v_vector, base_point+v_vector)
      edge_ary[3] = FiniteLine.new( base_point+v_vector, base_point)
      return edge_ary
    end

    def normal
      return (u_vector.cross(v_vector)).normalize()
    end

    def opposite_point
      return base_point + u_vector + v_vector
    end

    def center_point
      return base_point + u_vector*0.5 + v_vector*0.5
    end

    def area
      return (u_vector.cross(v_vector)).length
    end

    def uv_parameter(check_point)
      Util.check_arg_type(::Vector3, check_point)
      mat = Matrix[[u_vector.x, u_vector.y, u_vector.z],
            [v_vector.x, v_vector.y, v_vector.z],
            [normal.x, normal.y, normal.z]]
      vec = (check_point - base_point).to_column_vector
      ans = mat.t.inv*vec
      return ans[0,0], ans[1,0]
    end

    def distance(target)
      # with Point
      if(target.kind_of?(Vector3))
        return distance_to_point(target)
      elsif(target.kind_of?(Line))
        #with Line
#        return distance_to_line(target)
      end
      Util.raise_argurment_error(target)
    end

private
    def distance_to_point(check_point)
      u,v = self.uv_parameter(check_point)
      if(u >= 0 && u <= 1 && v >= 0 && v <= 1)
        point_on_rect = self.point( u, v )
        distance = point_on_rect.distance(check_point)
        return distance, point_on_rect
      end
      # rectangle does not contain projected point
      # check distance to FiniteLines
      finite_lines = self.edges
      return FiniteLine.ary_distanc_to_point(finite_lines, check_point)
    end
  end
end

