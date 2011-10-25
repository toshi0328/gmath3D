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

    def initialize_copy( original_obj )
      @vertices = Array.new(original_obj.vertices.size)
      for i in 0..@vertices.size-1
        @vertices[i] = original_obj.vertices[i].dup
      end
    end

    # [Input]
    #  _rhs_ is Line.
    # [Output]
    #  return true if rhs equals myself.
    def ==(rhs)
      return false if rhs == nil
      return false if( !rhs.kind_of?(Triangle) )
      return false if(@vertices.size != rhs.vertices.size)
      for i in 0..@vertices.size-1
        return false if(@vertices[i] != rhs.vertices[i])
      end
      return true
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

    # [Output]
    #  return normal vector reversed triangle
    def reverse()
      return Triangle.new(@vertices[0], @vertices[2], @vertices[1])
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
    #  _target_ shold be Vector3 or Line or Plane.
    # [Output]
    #  [In case _target_ is Vector3]
    #   return "distance, point on triangle" as [Numeric, Vector3].
    #  [In case _target_ is Line]
    #   return "distance, point on tirangle, point on line, parameter on line" as [Numeric, Vector3, Vector3, Numeric].
    #  [In case _target_ is Plane]
    #   return "distance, intersect_line(or closet edge), point_on_triangle, point_on_plane" as [Numeric, Vector3, Vector3, Vector3].
    def distance(target)
      # with Point
      if(target.kind_of?(Vector3))
        return distance_to_point(target)
      elsif(target.kind_of?(Line))
      #with Line
        return distance_to_line(target)
      elsif(target.kind_of?(Plane))
      #with Plane
        return distance_to_plane(target)
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

    def distance_to_plane(target_plane)
      triangle_plane = Plane.new( vertices[0], self.normal )
      distance, intersect_line_each_plane = triangle_plane.distance( target_plane )
      if( intersect_line_each_plane == nil )
        return distance, nil, nil, nil
      end

      # check distance from intersection and each edge.
      distance_zero_count = 0
      distance_info = Array.new(0)
      prallel_edge_ary = Array.new(0)
      self.edges.each do |edge|
        distance, point_on_edge, point_on_line = edge.distance( intersect_line_each_plane)
        if point_on_edge != nil && point_on_line != nil
          distance_info.push([distance, point_on_edge, point_on_line])
          if distance <= self.tolerance
            distance_zero_count += 1
          end
        else
          prallel_edge_ary.push( edge )
        end
      end
      distance_info.sort!{|a,b| a[0] <=> b[0]}
      # distance, intersect_line(or closet edge), point_on_triangle, point_on_plan
      if (distance_zero_count == 2)
        point1 = distance_info[0][1]
        point2 = distance_info[1][1]
        if point1.distance(point2) > self.tolerance
          return 0.0, FiniteLine.new(point1, point2), nil, nil
        end
        return 0.0, nil, point1, point1
      elsif (distance_zero_count == 0)
        distance, closest_point_on_plane = target_plane.distance(distance_info[0][1])
        if(distance_info[0][1] != distance_info[1][1])
          return distance, FiniteLine.new(distance_info[0][1], distance_info[1][1]), nil, nil
        end
        return distance, nil, distance_info[0][1], closest_point_on_plane
      end
      return 0.0, nil, nil, nil
    end
  end
end
