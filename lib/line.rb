require 'gmath3D'

module GMath3D
  class Line < Geom
    public
    attr_accessor :base_point
    attr_accessor :direction
    
    def initialize(point = Vector3.new(0.0,0.0,0.0), direction = Vector3.new(1.0,0.0,0.0))
      Util.check_arg_type(Vector3, point)
      Util.check_arg_type(Vector3, direction)
      super()
      @base_point = point
      @direction  = direction
    end
    
    def point(parameter)
                  Util.check_arg_type(::Numeric, parameter)
      @base_point + @direction*parameter
    end
    
    def distance(target)
      # with Point
      if(target.kind_of?(Vector3))
        return distance_to_point(target)
        #with Line
      elsif(target.kind_of?(Line))
        return distance_to_line(target)
      end
      Util.raise_argurment_error(target)
    end
    
    private
    def distance_to_point(target_point)
      point_on_line1 = self.base_point
      point_on_line2 = self.base_point + self.direction

      vecAB = point_on_line2 - point_on_line1
      vecAP = target_point - point_on_line1
      vecAQ, parameter = vecAP.project_to(vecAB)
      cross_point = point_on_line1 + vecAQ
      vecPQ = vecAQ - vecAP
      return vecPQ.length, cross_point, parameter
    end
    
    def distance_to_line(target_line)
      if(self.direction.parallel?(target_line.direction)) then
        distanceInfo = self.distance(target_line.base_point)
        return distanceInfo[0], nil, nil, nil, nil
      else
        line1_point1 = self.base_point
        line1_point2 = self.base_point + self.direction
        line2_point1 = target_line.base_point
        line2_point2 = target_line.base_point + target_line.direction
        
        vec_da = line1_point2 - line1_point1
        vec_db = line2_point2 - line2_point1
        vec_ab = line2_point1 - line1_point1
        
        abs_vec_db = vec_db.length*vec_db.length 
        abs_vec_da = vec_da.length*vec_da.length 
        
        delta = (abs_vec_da*abs_vec_db - vec_da.dot( vec_db )*vec_da.dot( vec_db ))
        
        if( delta < self.tolerance )
          # TODO ASSERT(false)
          return nil
        end
        parameter1 = (abs_vec_db*vec_ab.dot(vec_da) - vec_da.dot( vec_db )*vec_ab.dot( vec_db ) ) / delta
        parameter2 = (vec_da.dot( vec_db )*vec_ab.dot( vec_da ) - abs_vec_da*vec_ab.dot( vec_db ))/ delta
        
        line1_closest_point = line1_point1 + vec_da*parameter1
        line2_closest_point = line2_point1 + vec_db*parameter2
        distance = line1_closest_point.distance( line2_closest_point )
        return distance, line1_closest_point, line2_closest_point, parameter1, parameter2
      end
    end
  end
end

