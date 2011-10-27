module GMath3D
  class Util
    def self.check_arg_type(type, instance)
      unless(instance.kind_of?(type))
        raise(ArgumentError::new("type mismatch: #{instance.class} for #{type}"))
      end
    end

    def self.raise_argurment_error(instance)
      raise(ArgumentError::new("type mismatch: #{instance.class}"))
    end
  end

  # Including 'vertices' methodshould be implimented that gets geometry vertices as Array of Vector3.
  module BoxAvailable
    # [Output]
    #  return axially aligned bounding box as Box.
    def box
      return Box.from_points( vertices )
    end
  end
end

class Array
public
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
