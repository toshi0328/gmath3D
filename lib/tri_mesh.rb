require 'gmath3D'

module GMath3D
  #
  # TriMesh represents an structured trianglular mesh.
  #
  class TriMesh < Geom
    attr_reader :vertices
    attr_reader :tri_indices

    # [Input]
    #  vertices is Array of Vector3.
    #  tri_indices is Array of triangle whick is consist of 3 vertices index.
    # [Output]
    #  return new instance of TriMesh.
    def initialize(vertices, tri_indices)
      # check arg
      Util.check_arg_type(Array, vertices)
      Util.check_arg_type(Array, tri_indices)
      vertices.each do |item|
        Util.check_arg_type(Vector3, item)
      end
      tri_indices.each do |tri_index|
        Util.check_arg_type(Array, tri_index)
        tri_index.each do |item|
          Util.check_arg_type(Integer, item)
        end
      end
      super()
      @vertices = vertices
      @tri_indices = tri_indices
    end

    def initialize_copy( original_obj )
      @vertices = Array.new(original_obj.vertices.size)
      for i in 0..@vertices.size-1
        @vertices[i] = original_obj.vertices[i].dup
      end
      @tri_indices = Array.new(original_obj.tri_indices.size)
      for i in 0..@tri_indices.size-1
        @tri_indices[i] = original_obj.tri_indices[i].dup
      end
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

      tri_indices =[
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
      return TriMesh.new( vertices, tri_indices )
    end

    # [Input]
    #  _rect_ is a Rectangle object.
    # [Output]
    #  return new instance of TriMesh.
    def self.from_rectangle(rect)
      Util.check_arg_type(Rectangle, rect)
      return TriMesh.new(rect.vertices, [[0,1,3], [1,2,3]])
    end

    # [Input]
    #  _tris_ is Array of Triangle object.
    # [Output]
    #  return new instance of TriMesh
    def self.from_triangles(tris)
      Util.check_arg_type(Array, tris)
      tris.each do | item |
        Util.check_arg_type(Triangle, item)
      end

      tri_idx = 0
      vert_tris_map = Hash.new(nil)
      tris.each do | triangle |
        triangle.vertices.each do | vertex |
          vert_tris_map[vertex] = Array.new() if( !vert_tris_map.key?(vertex) )
          vert_tris_map[vertex] = vert_tris_map[vertex].push(tri_idx)
        end
        tri_idx += 1
      end

      tri_indices = Array.new( tris.size )
      vertices = vert_tris_map.keys

      vert_idx = 0
      vert_tris_map.each do | vertex, tri_index_ary |
        tri_index_ary.each do | tri_index |
          tri_indices[tri_index] = Array.new() if( !tri_indices[tri_index] )
          tri_indices[tri_index].push(vert_idx)
        end
        vert_idx += 1
      end

      # modify noamal direction
      tri_idx = 0
      tri_indices.each do | tri_index_ary |
        if ( tri_index_ary.size > 2 )
          tmp_tri = Triangle.new(vertices[tri_index_ary[0]], vertices[tri_index_ary[1]], vertices[tri_index_ary[2]])
          if( tmp_tri.normal.dot(tris[tri_idx].normal) < 0 )
            tri_index_ary.reverse!
          end
        end
        tri_idx += 1
      end

      return TriMesh.new( vertices, tri_indices )
    end

    # [Input]
    #  _polyline_ is Poyline object that should be convex.
    # [Output]
    #  return new instance of TriMesh
    def self.from_convex_polyline(polyline)
      trimesh_vertices = Array.new(polyline.vertices.size + 1)
      trimesh_vertices[0] = polyline.center
      i = 1
      polyline.vertices.each do | poly_vert |
        trimesh_vertices[i] = poly_vert.clone
        i += 1
      end
      trimesh_tri_indices = Array.new(polyline.vertices.size)
      for i in 0..polyline.vertices.size-1
        trimesh_tri_indices[i] = [0,i+1,i+2]
      end
      trimesh_tri_indices[trimesh_tri_indices.size - 1] = [0,polyline.vertices.size,1]
      return TriMesh.new( trimesh_vertices, trimesh_tri_indices )
    end

    # [Input]
    #  _polyline_ is Poyline object.
    #  _extrude_direction_ is Vector3.
    # [Output]
    #  return new instance of TriMesh that is extruded polyline
    def self.from_extrude_polyline(polyline, extrude_direction)
      trimesh_vertices = Array.new(polyline.vertices.size*2)
      poly_vert_cnt = polyline.vertices.size
      i = 0
      polyline.vertices.each do | poly_vert |
        trimesh_vertices[i] = poly_vert.clone
        trimesh_vertices[i + poly_vert_cnt] = poly_vert + extrude_direction
        i+=1
      end

      tri_indices_cnt = (poly_vert_cnt-1)*2
      trimesh_tri_indices = Array.new(tri_indices_cnt)

      for i in 0..poly_vert_cnt-2
        trimesh_tri_indices[2*i    ] = [i,     i + 1,                 i + poly_vert_cnt]
        trimesh_tri_indices[2*i + 1] = [i + 1, i + 1 + poly_vert_cnt, i + poly_vert_cnt]
      end
      if(!polyline.is_open)
        trimesh_tri_indices[2*(poly_vert_cnt - 1)    ] = [poly_vert_cnt - 1, 0, 2*(poly_vert_cnt - 1) + 1]
        trimesh_tri_indices[2*(poly_vert_cnt - 1) + 1] = [0, poly_vert_cnt, 2*(poly_vert_cnt - 1) + 1]
      end
      return TriMesh.new(trimesh_vertices, trimesh_tri_indices)
    end

    # [Input]
    #  _rhs_ is TriMesh.
    # [Output]
    #  return true if rhs equals myself.
    def ==(rhs)
      return false if rhs == nil
      return false if( !rhs.kind_of?(TriMesh) )
      return false if(@vertices.size != rhs.vertices.size)
      return false if(@tri_indices.size != rhs.tri_indices.size)

      for i in 0..(@vertices.size-1)
        return false if( @vertices[i] != rhs.vertices[i])
      end

      for i in 0..(@tri_indices.size-1)
        return false if( @tri_indices[i] != rhs.tri_indices[i])
      end
      return true
    end

    def to_s
      "TriMesh[triangle_count:#{tri_indices.size}, vertex_count:#{vertices.size}]"
    end

    # [Input]
    #  _index_ is index of triangle.
    # [Output]
    #  return new instance of Triangle.
    def triangle(index)
      return nil if( index < 0 || @tri_indices.size <= index )
      tri_index = @tri_indices[index]
      return Triangle.new(vertices[tri_index[0]], vertices[tri_index[1]], vertices[tri_index[2]])
    end

    # [Output]
    #  return Array of Triangle.
    def triangles
      tris = Array.new(tri_indices.size)
      i = 0
      tri_indices.each do |tri_index|
        tris[i] =  self.triangle(i)
        i += 1
      end
      return tris
    end

    # [Output]
    #  return surface area of TriMesh.
    def area
      area_sum = 0
      triangles.each do | tri |
        area_sum += tri.area
      end
      return area_sum
    end
  end
end

