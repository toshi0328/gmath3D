require 'gmath3D'

module GMath3D
  #
  # TriMesh represents an structured trianglular mesh.
  #
  class TriMesh < Geom
    attr_reader :vertices
    attr_reader :tri_indeces

    # [Input]
    #  vertices is Array of Vector3.
    #  tri_indeces is Array of triangle whick is consist of 3 vertices index.
    # [Output]
    #  return new instance of TriMesh.
    def initialize(vertices, tri_indeces)
      # check arg
      Util.check_arg_type(Array, vertices)
      Util.check_arg_type(Array, tri_indeces)
      vertices.each do |item|
        Util.check_arg_type(Vector3, item)
      end
      tri_indeces.each do |tri_index|
        Util.check_arg_type(Array, tri_index)
        tri_index.each do |item|
          Util.check_arg_type(Integer, item)
        end
      end
      super()
      @vertices = vertices
      @tri_indeces = tri_indeces
    end

    # [Input]
    #  _box_ is a Box object.
    # [Output]
    #  return new instance of TriMesh.
    def self.from_box(box)
      Util.check_arg_type(Box, box)
      width, height, depth = box.length()
      vertices = Array.new(8)
      vertices[0] = box.min_point
      vertices[1] = box.min_point + Vector3.new(width, 0, 0)
      vertices[2] = box.min_point + Vector3.new(width, 0, depth)
      vertices[3] = box.min_point + Vector3.new(0    , 0, depth)
      vertices[4] = box.min_point + Vector3.new(0    , height, 0)
      vertices[5] = box.min_point + Vector3.new(width, height, 0)
      vertices[6] = box.min_point + Vector3.new(width, height, depth)
      vertices[7] = box.min_point + Vector3.new(0    , height, depth)

      tri_indeces =[
        [0, 1, 2],
        [0, 2, 3],
        [1, 5, 6],
        [1, 6, 2],
        [5, 4, 7],
        [5, 7, 6],
        [4, 0, 3],
        [4, 3, 7],
        [2, 6, 7],
        [2, 7, 3],
        [0, 4, 5],
        [0, 5, 1]]
      return TriMesh.new( vertices, tri_indeces )
    end

    # [Input]
    #  _rect_ is a Rectangle object.
    # [Output]
    #  return new instance of TriMesh.
    def self.from_rectangle(rect)
      Util.check_arg_type(Rectangle, rect)
      return TriMesh.new(rect.vertices, [[0,1,3], [1,2,3]])
    end

    def to_s
      "TriMesh[triangle_count:#{tri_indeces.size}, vertex_count:#{vertices.size}]"
    end

    # [Output]
    #  return Array of Triangle.
    def triangles
      tris = Array.new(tri_indeces.size)
      i = 0
      tri_indeces.each do |tri_index|
        tris[i] =  Triangle.new(vertices[tri_index[0]], vertices[tri_index[1]], vertices[tri_index[2]])
        i += 1
      end
      return tris
    end

  end
end

