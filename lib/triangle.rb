require 'gmath3D'

module GMath3D
  #
  # Triangle represents a three edged finite plane on 3D space.
  #
  class Triangle < Geom
public
    attr_accessor:vertices

    # [Input]
    #  _vertex1_, _vertex2_, _vertex3_ should be Vector3.
    # [Output]
    #  return new instance of Triangle.
    def initialize(vertex1 = Vector3.new(), vertex2 = Vector3.new(1,0,0), vertex3 = Vector3.new(0,1,0))
      Util.check_arg_type(::Vector3, vertex1)
      Util.check_arg_type(::Vector3, vertex2)
      Util.check_arg_type(::Vector3, vertex3)
      super()
      @vertices = Array.new([vertex1, vertex2, vertex3])
    end

    def to_s
      "Triangle[#{@vertices[0].to_element_s}, #{@vertices[1].to_element_s}, #{@vertices[2].to_element_s}]"
    end

    # [Input]
    #  _parameter_ should be three element Array of Numeric.
    # [Output]
    #  return point on triangle at parameter position as Vector3.
    def point( parameter )
      Util.check_arg_type(::Array, parameter )
      # TODO Argument check
      return self.vertices[0]*parameter[0] + self.vertices[1]*parameter[1] + self.vertices[2]*parameter[2]
    end

    # [Output]
    #  return edges as three element Array of Vector3.
    def edges
      return_edges = Array.new(3)
      return_edges[0] = FiniteLine.new(self.vertices[0], self.vertices[1])
      return_edges[1] = FiniteLine.new(self.vertices[1], self.vertices[2])
      return_edges[2] = FiniteLine.new(self.vertices[2], self.vertices[0])
      return return_edges
    end

    # [Output]
    #  return area as Numeric.
    def area
      vec1 = vertices[1] - vertices[0]
      vec2 = vertices[2] - vertices[0]
      outer_product = vec1.cross(vec2)
      return outer_product.length / 2.0
    end

    # [Output]
    #  return center point as Vector3.
    def center
      return vertices.avg
    end

    # [Output]
    #  return normal vector as Vector3.
    def normal
      vec1 = self.vertices[1] - self.vertices[0]
      vec2 = self.vertices[2] - self.vertices[0]
      return (vec1.cross(vec2).normalize)
    end

    # [Input]
    #  _check_point_ should be Vector3.
    # [Output]
    #  return barycentric_coordinate on check_point as three element Array of Numeric.
    def barycentric_coordinate( check_point )
      Util.check_arg_type(::Vector3, check_point)

      v0 = @vertices[0]
      v1 = @vertices[1]
      v2 = @vertices[2]

      d1 = v1 - v0
      d2 = v2 - v1
      n = d1.cross(d2);
      if((n.x).abs >= (n.y).abs && (n.x).abs >= (n.z).abs)
        uu1 = v0.y - v2.y;
        uu2 = v1.y - v2.y;
        uu3 = check_point.y  - v0.y;
        uu4 = check_point.y  - v2.y;
        vv1 = v0.z - v2.z;
        vv2 = v1.z - v2.z;
        vv3 = check_point.z  - v0.z;
        vv4 = check_point.z  - v2.z;
      elsif((n.y).abs >= (n.z).abs)
        uu1 = v0.z - v2.z;
        uu2 = v1.z - v2.z;
        uu3 = check_point.z  - v0.z;
        uu4 = check_point.z  - v2.z;
        vv1 = v0.x - v2.x;
        vv2 = v1.x - v2.x;
        vv3 = check_point.x  - v0.x;
        vv4 = check_point.x  - v2.x;
      else
        uu1 = v0.x - v2.x;
        uu2 = v1.x - v2.x;
        uu3 = check_point.x  - v0.x;
        uu4 = check_point.x  - v2.x;
        vv1 = v0.y - v2.y;
        vv2 = v1.y - v2.y;
        vv3 = check_point.y  - v0.y;
        vv4 = check_point.y  - v2.y;
      end

      denom = vv1 * uu2 - vv2* uu1
      if(denom == 0.0)
	return nil
      end
      b = Array.new(3)
      oneOverDenom = 1.0 / denom ;
      b[0] = (vv4*uu2 - vv2*uu4) * oneOverDenom;
      b[1] = (vv1*uu3 - vv3*uu1) * oneOverDenom;
      b[2] = 1.0 - b[0] - b[1];
      return b;
    end

    # [Input]
    #  _target_ shold be Vector3 or Line.
    # [Output]
    #  [In case _target_ is Vector3]
    #   return "distance, point on triangle" as [Numeric, Vector3].
    #  [In case _target_ is Line]
    #   return "distance, point on tirangle, point on line, parameter on line" as [Numeric, Vector3, Vector3, Numeric].
    def distance(target)
      # with Point
      if(target.kind_of?(Vector3))
        return distance_to_point(target)
      elsif(target.kind_of?(Line))
      #with Line
        return distance_to_line(target)
      end
      Util.raise_argurment_error(target)
    end

    # [Input]
    #  _check_point_ shold be Vector3.
    # [Output]
    #  return true if triangle contains _check_point_.
    def contains?( check_point )
      Util.check_arg_type(Vector3, check_point )
      plane = Plane.new( vertices[0], self.normal)
      distance, projected_point = plane.distance(check_point)
      return false if( distance > self.tolerance )
      g_coord = self.barycentric_coordinate(check_point)
      g_coord.each do |item|
        return false if( item < 0 or 1 < item)
      end
      return true
    end

private
    def distance_to_point(target_point)
      plane = Plane.new( vertices[0], self.normal)
      distance, projected_point = plane.distance(target_point)
      if( self.contains?(projected_point))
        return distance, projected_point
      end
      #check distance to FiniteLines
      finite_lines = self.edges
      return FiniteLine.ary_distanc_to_point(finite_lines, target_point)
    end

    def distance_to_line(target_line)
      plane = Plane.new( vertices[0], self.normal )
      distance, point_on_plane, parameter_on_line = plane.distance( target_line )
      if( point_on_plane == nil)
        # parallel case
        # check distance to FiniteLines
        finite_lines = self.edges
        distance, point_on_edge, point_on_target, param_on_finiteline, param_on_target =
          FiniteLine.ary_distance_to_line(finite_lines, target_line)
        return distance, nil, nil, nil
      end
      if( self.contains?(point_on_plane) )
        return distance, point_on_plane, point_on_plane, parameter_on_line
      end
      # check distance to FiniteLines
      finite_lines = self.edges
      distance, point_on_edge, point_on_target, param_on_finiteline, param_on_target =
        FiniteLine.ary_distance_to_line(finite_lines, target_line)
      return distance, point_on_edge, point_on_target, param_on_target
    end
  end
end

