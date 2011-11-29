module Util3D
  def self.check_arg_type(type, instance, nullable = false, array_check = false)
    return if(nullable && instance.nil?)
    if(array_check && instance.kind_of?(Array))
      instance.each do |item|
        check_arg_type(type, item, nullable, array_check)
      end
    else
      unless(instance.kind_of?(type))
        raise(ArgumentError::new("type mismatch: #{instance.class} for #{type}"))
      end
    end
  end

  def self.raise_argurment_error(instance)
    raise(ArgumentError::new("type mismatch: #{instance.class}"))
  end

  def self.check_key_arg(arg, key)
    if(!arg.include?(key))
      raise(ArgumentError::new("args should be contains: #{key}"))
    end
  end
end

module GMath3D
  # Including 'vertices' methodshould be implimented that gets geometry vertices as Array of Vector3.
  module BoxAvailable
    # [Output]
    #  return axially aligned bounding box as Box.
    def box
      return Box.from_points( vertices )
    end
  end
end

