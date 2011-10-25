require 'matrix'

require 'gmath3D'

module GMath3D
  #
  # Rectangle represents a four edged finite plane on 3D space.
  #
  class Rectangle < Geom
public
    attr_accessor:base_point
    attr_accessor:u_vector
    attr_accessor:v_vector

    # [Input]
    #  _base_point_ , _u_vector_, _v_vector_ should be Vector3.
    # _u_vector_ and _v_vector_ should be orthogonalized.
    # [Output]
    #  return new instance of Rectangle.
    def initialize(base_point_arg = Vector3.new(), u_vector_arg = Vector3.new(1,0,0), v_vector_arg = Vector3.new(0,1,0))
      Util.check_arg_type(::Vector3, base_point_arg)
      Util.check_arg_type(::Vector3, u_vector_arg)
      Util.check_arg_type(::Vector3, v_vector_arg)
      super()
      self.base_point = base_point_arg
      self.u_vector = u_vector_arg
      self.v_vector = v_vector_arg
    end

    def initialize_copy( original_obj )
      @base_point = original_obj.base_point.dup
      @u_vector = original_obj.u_vector.dup
      @v_vector = original_obj.v_vector.dup
    end

    # [Input]
    #  _rhs_ is Rectangle.
    # [Output]
    #  return true if rhs equals myself.
    def ==(rhs)
      return false if rhs == nil
      return false if( !rhs.kind_of?(Rectangle) )
      return false if( self.base_point != rhs.base_point)
      return false if( self.u_vector != rhs.u_vector)
      return false if( self.v_vector != rhs.v_vector)
      return true
    end

    def to_s
      "Rectangle[base#{@base_point.to_element_s}, u#{@u_vector.to_element_s}, v#{@v_vector.to_element_s}"
    end

    # [Input]
    #  _u_, _v_ should be Numeric.
    # [Output]
    #  return point on rectangle as Vector3.
    def point(u, v)
      Util.check_arg_type(::Numeric, u)
      Util.check_arg_type(::Numeric, v)
      return base_point + u_vector*u + v_vector*v
    end

    # [Output]
    #  return edges of rectangle as Array of FiniteLine.
    def edges
      edge_ary = Array.new(4)
      edge_ary[0] = FiniteLine.new( base_point, base_point+u_vector)
      edge_ary[1] = FiniteLine.new( base_point+u_vector, base_point+u_vector+v_vector)
      edge_ary[2] = FiniteLine.new( base_point+u_vector+v_vector, base_point+v_vector)
      edge_ary[3] = FiniteLine.new( base_point+v_vector, base_point)
      return edge_ary
    end

    # [Output]
    #  return vertices of rectangle as Array of Vector3.
    def vertices
      vertices = Array.new(4)
      vertices[0] = base_point
      vertices[1] = base_point+u_vector
      vertices[2] = base_point+u_vector+v_vector
      vertices[3] = base_point+v_vector
      return vertices
    end

    # [Output]
    #  return normal of rectangle as Vector3.
    def normal
      return (u_vector.cross(v_vector)).normalize()
    end

    # [Output]
    #  return point of opposite to base_point as Vector3.
    def opposite_point
      return base_point + u_vector + v_vector
    end

    # [Output]
    #  return center point as Vector3.
    def center_point
      return base_point + u_vector*0.5 + v_vector*0.5
    end

    # [Output]
    #  return rectangle area as Numeric.
    def area
      return (u_vector.cross(v_vector)).length
    end

    # [Input]
    #  _check_point_ shold be Vector3.
    # [Output]
    #  return u, v parametes on check_point as [Numeric, Numeric].
    def uv_parameter(check_point)
      Util.check_arg_type(::Vector3, check_point)
      mat = Matrix[[u_vector.x, u_vector.y, u_vector.z],
            [v_vector.x, v_vector.y, v_vector.z],
            [normal.x, normal.y, normal.z]]
      vec = (check_point - base_point).to_column_vector
      ans = mat.t.inv*vec
      return ans[0,0], ans[1,0]
    end

    # [Input]
    #  _target_ shold be Vector3.
    # [Output]
    #  return "distance, point on rectangle" as [Numeric, Vector3].
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

