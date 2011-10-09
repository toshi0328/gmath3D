require 'gmath3D'

module GMath3D
  #
  # Plane represents a infinite plane on 3D space.
  #
  class Plane < Geom
public
    attr_accessor:base_point
    attr_accessor:normal

    # [Input]
    #  _base_point_ and _normal_ should be Vector3.
    # [Output]
    #  returns new instance of Plane.
    def initialize(base_point = Vector3.new(), normal = Vector3.new(0,0,1))
      Util.check_arg_type(::Vector3, normal)
      Util.check_arg_type(::Vector3, base_point)
      super()
      @base_point = base_point
      @normal = normal.normalize()
    end

    # This function returns closest distance between Line and anothor element.
    # [Input]
    #  _target_ should be Vector3 or Line or FiniteLine or Plane.
    #
    # [Output]
    #  [in case _target_ is Vector3]
    #   return "distance, closest point on myself" as [Numeric, Vector3].
    #  [in case _target_ is Line]
    #   return "distance, intersect point, parameter on tatget" as [Numeric, Vector3, Numeric].
    #  [in case _target_ is FiniteLine]
    #   return "distance, point on plane, point on target, parameter on target"
    #   as [Numeric, Vector3, Vector3, Numeric].
    #  [in case _target_ is Plane]
    #   return "distance, intersect line" as [Numeric, Vector3].
    def distance(target)
      # with Point
      if(target.kind_of?(Vector3))
        return distance_to_point(target)
      #with Line
      elsif(target.kind_of?(Line))
        return distance_to_line(target)
      #with FiniteLine
      elsif(target.kind_of?(FiniteLine))
        return distance_to_finite_line(target)
      #with Plane
      elsif(target.kind_of?(Plane))
        return distance_to_plane(target)
      end
      Util.raise_argurment_error(target)
    end

    # [Input]
    #  _target_point_ should be Vector3.
    # [Output]
    #  retrun projected point on plane as Vector3.
    def project( target_point )
      Util.check_arg_type(::Vector3, target_point)
      distance, closest_point = self.distance( target_point )
      return closest_point
    end
private
    def distance_to_point(target_point)
      vector_QA = target_point - @base_point
      distance = vector_QA.dot(@normal)
      closest_point = target_point - @normal*distance
      return distance.abs, closest_point
    end

    def distance_to_line(target_line)
      inner_product_normal_and_line_vec = target_line.direction.dot(self.normal)
      #parallel
      if( inner_product_normal_and_line_vec.abs < @tolerance)
        distance, closest_point = self.distance(target_line.base_point)
        return distance, nil,nil
      end
      parameter = ( self.normal.dot(self.base_point) - self.normal.dot( target_line.base_point ) )/inner_product_normal_and_line_vec.to_f
      intersect_point = target_line.point(parameter)
      return 0.0, intersect_point, parameter
    end

    def distance_to_finite_line(target_finite_line)
      target_infinite_line = Line.new(target_finite_line.start_point, target_finite_line.direction)
      distance, intersect_point, parameter = self.distance(target_infinite_line)
      point_on_line = intersect_point
      point_on_plane = intersect_point
      if(parameter != nil and (parameter < 0 or 1 < parameter))
        parameter = [0, parameter].max
        parameter = [1, parameter].min
        point_on_line = target_finite_line.point(parameter)
        distance, point_on_plane = self.distance(point_on_line)
      end
      return distance, point_on_plane, point_on_line, parameter
    end
    def distance_to_plane(target_plane)
      line_vector = target_plane.normal.cross(self.normal)
      if(target_plane.normal.parallel?(self.normal))
        distance, point_on_plane = self.distance(target_plane.base_point)
        return distance, nil
      end
      line_vector = line_vector.normalize()
      tangent_vector_on_target_plane = line_vector.cross(target_plane.normal)
      distance, intersect_point, parameter = self.distance(Line.new( target_plane.base_point, tangent_vector_on_target_plane))
      intersect_line = Line.new(intersect_point, line_vector)
      return 0, intersect_line
    end
  end
end

