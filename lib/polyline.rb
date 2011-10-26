require 'gmath3D'

module GMath3D
  #
  # Polyline represents a closed or open polyline on 3D space.
  #
  class Polyline < Geom
    public
    attr_accessor :vertices
    attr_accessor :is_open

    # [Input]
    #  _vertices_ should be Array of Vector3.
    # [Output]
    #  return new instance of Polyline.
    def initialize(vertices = [], is_open = true)
      Util.check_arg_type(Array, vertices)
      super()
      @vertices = vertices
      @is_open  = is_open
    end

    def initialize_copy( original_obj )
      @vertices = Array.new(original_obj.vertices.size)
      for i in 0..@vertices.size-1
        @vertices[i] = original_obj.vertices[i].dup
      end
      @is_open = original_obj.is_open
    end

    # [Input]
    #  _rhs_ is Polyline.
    # [Output]
    #  return true if rhs equals myself.
    def ==(rhs)
      return false if rhs == nil
      return false if( !rhs.kind_of?(Polyline) )
      return false if( self.is_open != rhs.is_open )
      return false if(@vertices.size != rhs.vertices.size)
      for i in 0..(@vertices.size-1)
        return false if( self.vertices[i] != rhs.vertices[i])
      end
      return true
    end

    def to_s
      str = "Polyline["
      vertices.each do |vertex|
        str += vertex.to_element_s + ", "
      end
      str.slice!(str.length - 2, 2) if(vertices.size > 0)
      str += "] "
      str += "open" if(@is_open)
      str += "closed" if(!@is_open)
      return str
    end

    # [Output]
    #  return axially aligned bounding box as Box.
    def box
      return Box.from_points( vertices )
    end

    # [Output]
    #  return center point as Vector3.
    def center
      center = Vector3.new()
      @vertices.each do |vertex|
        center += vertex
      end
      center /= @vertices.size
      return center
    end

  end
end

