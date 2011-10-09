require 'gmath3D'

module GMath3D
  #
  # FiniteLine represents a finite line on 3D space.
  #
  class FiniteLine < Geom
public
    attr_accessor :start_point
    attr_accessor :end_point

    # [Input]
    #  _start_point_arg_ and _end_point_arg_ should be Vector3.
    # [Output]
    #  return new instance as FiniteLine
    def initialize(start_point_arg = Vector3.new(0.0,0.0,0.0), end_point_arg = Vector3.new(1.0,0.0,0.0))
      Util.check_arg_type(Vector3, start_point_arg)
      Util.check_arg_type(Vector3, end_point_arg)
      super()
      @start_point = start_point_arg
      @end_point  = end_point_arg
    end

    def to_s
      "FiniteLine[from#{start_point.to_element_s}, to#{end_point.to_element_s}]"
    end

    # [Output]
    #  return direction as vector from start_point to end_point as Vector3
    def direction
      @end_point - @start_point
    end

    # [Input]
    #  _parameter_ should be Numeric.
    # [Output]
    #  return a point on line at input parameter position as Vector3
    def point(parameter)
      if(parameter < 0.0 or 1.0 < parameter)
        return nil
      else
        return @start_point * (1.0 - parameter) + @end_point * parameter
      end
    end

    # [Output]
    #  return length as Numeric
    def length
      @start_point.distance(@end_point)
    end

    # This function returns closest distance between FiniteLine and anothor element.
    # [Input]
    #  _target_ should be Vector3 or Line or FiniteLine
    #
    # [Output]
    #  [in case _target_ is Vector3]
    #   return "distance, closest point on myself, parameter on myself" as [Numeric, Vector3, Numeric]
    #  [in case _target_ is Line or FiniteLine]
    #   return "distance, point on myself, point on target, parameter on myself, parameter on tatget" 
    #   as [Numeric, Vector3, Vector3, Numeric, Numeric]
    def distance(target)
      # with Point
      if(target.kind_of?(Vector3))
        return distance_to_point(target)
        #with Line
      elsif(target.kind_of?(Line))
        return distance_to_line(target)
      #widh Finite Line
      elsif(target.kind_of?(FiniteLine))
        return distance_to_finite_line(target)
      end
      Util.raise_argurment_error(target)
    end

    def self.ary_distanc_to_point(finite_lines, target_point)
      Util.check_arg_type(::Array, finite_lines)
      Util.check_arg_type(Vector3, target_point)
      distance_ary = Array.new(0)
      points_ary   = Array.new(0)
      finite_lines.each do | item |
        distance, point = item.distance(target_point)
        distance_ary.push(distance);
        points_ary.push(point)
      end
      distance = distance_ary.min
      closest_point = points_ary[distance_ary.index(distance)]
      return distance, closest_point
    end
private
    def distance_to_point(target)
      # get distance using infinite line
      infinite_line = Line.new(self.start_point, self.direction)
      distance, closest_point, parameter = infinite_line.distance(target)
      if(0.0 <= parameter and parameter <= 1.0)
        return distance, closest_point, parameter
      end

      distance_to_start_point = @start_point.distance(target)
      distance_to_end_point   = @end_point.distance(target)
      if(distance_to_start_point < distance_to_end_point)
        distance = distance_to_start_point
        closest_point = @start_point
        parameter = 0.0
      else
        distance = distance_to_end_point
        closest_point = @end_point
        parameter = 1.0
      end
      return distance, closest_point, parameter
    end

    def distance_to_line(target_infinite_line)
      self_infinite_line = Line.new(self.start_point, self.direction)
      distance, point1, point2, parameter1, parameter2 = self_infinite_line.distance(target_infinite_line)
      #parallel
      return distance, nil, nil, nil, nil if( point1 == nil and point2 == nil)
      #parameter is in range
      return distance, point1, point2, parameter1, parameter2 if(0 < parameter1 and parameter1 < 1)
      distance_to_start_point, closest_point_to_start_point, parameter_to_start_point =
        target_infinite_line.distance(self.start_point)
      distance_to_end_point, closest_point_to_end_point, parameter_to_end_point =
        target_infinite_line.distance(self.end_point)
      if(distance_to_start_point < distance_to_end_point)
        return distance_to_start_point, self.start_point, closest_point_to_start_point, 0.0, parameter_to_start_point
      else
        return distance_to_end_point, self.end_point, closest_point_to_end_point, 1.0, parameter_to_end_point
      end
    end

    def distance_to_finite_line(target_finite_line)
      line1 = Line.new(self.start_point, self.direction)
      line2 = Line.new(target_finite_line.start_point, target_finite_line.direction)
      distance, point_myself, point_target, parameter_myself, parameter_target = line1.distance( line2 )
      if(point_myself == nil and point_target == nil)
        #prallel or including case
        point_pair = Array.new(4)
        point_pair[0] = Array.new([self.start_point, target_finite_line.start_point, 0, 0])
        point_pair[1] = Array.new([self.start_point, target_finite_line.end_point, 0,1])
        point_pair[2] = Array.new([self.end_point, target_finite_line.start_point, 1,0])
        point_pair[3] = Array.new([self.end_point, target_finite_line.end_point,1,1])

        distance_ary = Array.new(0)
        point_pair.each do |points|
          distance_ary << points[0].distance(points[1])
        end
        distance_min = distance_ary.min
        distance_min_ary = Array.new(0)
        distance_min_index = nil
        distance_ary.each do |item|
          if( item - tolerance < distance_min )
            distance_min_ary << item
            distance_min_index = distance_ary.index(item)
          end
        end
        if( distance_min_ary.size == 1)
          target_point_pair = point_pair[distance_min_index]
          distance = target_point_pair[0].distance(target_point_pair[1])
          return distance, target_point_pair[0], target_point_pair[1], target_point_pair[2], target_point_pair[3]
        else
          return distance, nil, nil, nil, nil
        end
      #out of range
      elsif( parameter_myself < 0 or 1 < parameter_myself or parameter_target < 0 or 1 < parameter_target )
        parameter_myself = [1, parameter_myself].min
        parameter_myself = [0, parameter_myself].max
        distance1, point_target, paramter_target_tmp = target_finite_line.distance(point_myself)

        parameter_target = [1, parameter_target].min
        parameter_target = [0, parameter_target].max
        distance2, point_myself, parameter_myself_tmp = self.distance(point_target)
        if(distance1 < distance2)
          parameter_target = paramter_target_tmp
        else
          parameter_myself = parameter_myself_tmp
        end
      end
      point_myself = line1.point(parameter_myself);
      point_target = line2.point(parameter_target);
      distance = point_myself.distance(point_target)
      return distance, point_myself, point_target, parameter_myself, parameter_target
    end
  end
end

