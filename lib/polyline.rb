require 'gmath3D'

module GMath3D
  #
  # Polyline represents a closed or open polyline on 3D space.
  #
  class Polyline < Geom
    public
    attr_accessor :vertices
    attr_accessor :is_open

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

