$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

class TriMeshTestCase < Minitest::Test
  def get_box_mesh
    box = Box.new(Vector3.new(-1,-1,-1), Vector3.new(2,3,4))
    return TriMesh.from_box(box)
  end

  def get_plane_mesh
    rect = Rectangle.new(Vector3.new(-1,-1,-1), Vector3.new(2,0,0), Vector3.new(0,4,0) )
    return TriMesh.from_rectangle(rect)
  end

  def test_initalize
    plane_mesh = get_plane_mesh()
    assert_equal( 2, plane_mesh.tri_indices.size)
    assert_equal( 4, plane_mesh.vertices.size)

    box_mesh = get_box_mesh()
    assert_equal( 12, box_mesh.tri_indices.size)
    assert_equal( 8, box_mesh.vertices.size)

    assert_raises ArgumentError do
      invalidResult = TriMesh.new(nil)
    end
    assert_raises ArgumentError do
      invalidResult = TriMesh.new(Vector3.new(), 4.0)
    end
  end

  def test_equal
    plane_mesh = get_plane_mesh()
    assert( plane_mesh != nil )
    assert( plane_mesh != "String" )

    shallow = plane_mesh
    assert( shallow == plane_mesh )
    assert( shallow.equal?(plane_mesh) )

    new_mesh = get_plane_mesh()
    assert( shallow == new_mesh )
    assert( !shallow.equal?(new_mesh) )
  end

  def test_clone
    plane_mesh = get_plane_mesh()
    shallow = plane_mesh

    shallow.vertices[0].x = 12
    shallow.vertices[2] = Vector3.new(-3,2,5)
    shallow.tri_indices[0] = [3,2,1]
    shallow.tri_indices[1][2] = 2

    assert_equal( 12, shallow.vertices[0].x )
    assert_equal( 12, plane_mesh.vertices[0].x )
    assert_equal( Vector3.new(-3,2,5), shallow.vertices[2] )
    assert_equal( Vector3.new(-3,2,5), plane_mesh.vertices[2] )
    assert_equal( [3,2,1], shallow.tri_indices[0] )
    assert_equal( [3,2,1], plane_mesh.tri_indices[0] )
    assert_equal( 2, shallow.tri_indices[1][2] )
    assert_equal( 2, plane_mesh.tri_indices[1][2] )

    deep = plane_mesh.clone
    assert( deep == plane_mesh )
    assert( !deep.equal?(plane_mesh) )

    deep.vertices[0].x = -1
    deep.vertices[2] = Vector3.new(4,2,1)
    deep.tri_indices[0] = [4,2,2]
    deep.tri_indices[1][2] = 5

    assert_equal( -1, deep.vertices[0].x )
    assert_equal( 12, plane_mesh.vertices[0].x )
    assert_equal( Vector3.new(4,2,1), deep.vertices[2] )
    assert_equal( Vector3.new(-3,2,5), plane_mesh.vertices[2] )
    assert_equal( [4,2,2], deep.tri_indices[0] )
    assert_equal( [3,2,1], plane_mesh.tri_indices[0] )
    assert_equal( 5, deep.tri_indices[1][2] )
    assert_equal( 2, plane_mesh.tri_indices[1][2] )
  end

  def test_to_s
    assert_equal( "TriMesh[triangle_count:12, vertex_count:8]", get_box_mesh().to_s)
  end

  def test_box
    box_mesh = get_box_mesh
    plane_mesh = get_plane_mesh
    assert_equal( Vector3.new(-1,-1,-1), box_mesh.box.min_point )
    assert_equal( Vector3.new( 2, 3, 4), box_mesh.box.max_point )
    assert_equal( Vector3.new(-1,-1,-1), plane_mesh.box.min_point )
    assert_equal( Vector3.new( 1, 3,-1), plane_mesh.box.max_point )
  end

  def test_triangles
    vertices = [Vector3.new(0,0,0),Vector3.new(2,0,0),Vector3.new(2,2,0),Vector3.new(0,2,0)]
    tri_indices = [[0,1,3],[1,2,3]]
    tri_mesh = TriMesh.new(vertices, tri_indices)
    triangles = tri_mesh.triangles
    assert_equal(2, triangles.size)
    assert_equal(Vector3.new(0,0,0), triangles[0].vertices[0])
    assert_equal(Vector3.new(2,0,0), triangles[0].vertices[1])
    assert_equal(Vector3.new(0,2,0), triangles[0].vertices[2])
    assert_equal(Vector3.new(2,0,0), triangles[1].vertices[0])
    assert_equal(Vector3.new(2,2,0), triangles[1].vertices[1])
    assert_equal(Vector3.new(0,2,0), triangles[1].vertices[2])

    triangle = tri_mesh.triangle(1)
    assert_equal(Vector3.new(2,0,0), triangle.vertices[0])
    assert_equal(Vector3.new(2,2,0), triangle.vertices[1])
    assert_equal(Vector3.new(0,2,0), triangle.vertices[2])

    triangle = tri_mesh.triangle(3)
    assert_equal(nil, triangle)
  end

  def test_from_triangles
    tris = Array.new(8)
    tris[0] = Triangle.new( Vector3.new(0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,1) )
    tris[1] = Triangle.new( Vector3.new(1,0,0), Vector3.new(1,1,1), Vector3.new(0,1,1) )
    tris[2] = Triangle.new( Vector3.new(1,0,0), Vector3.new(2,0,0), Vector3.new(1,1,1) )
    tris[3] = Triangle.new( Vector3.new(2,0,0), Vector3.new(2,1,1), Vector3.new(1,1,1) )
    tris[4] = Triangle.new( Vector3.new(0,1,1), Vector3.new(1,1,1), Vector3.new(0,2,2) )
    tris[5] = Triangle.new( Vector3.new(1,1,1), Vector3.new(1,2,2), Vector3.new(0,2,2) )
    tris[6] = Triangle.new( Vector3.new(1,1,1), Vector3.new(2,1,1), Vector3.new(1,2,2) )
    tris[7] = Triangle.new( Vector3.new(2,1,1), Vector3.new(2,2,2), Vector3.new(1,2,2) )
    trimesh_from_tris = TriMesh::from_triangles(tris)
    assert_equal( 9, trimesh_from_tris.vertices.size)
    assert_equal( 8, trimesh_from_tris.tri_indices.size)
  end

  def test_from_convex_polyline
    vertices = Array.new(6)
    vertices[0] = Vector3.new(1,0,0)
    vertices[1] = Vector3.new(2,0,0)
    vertices[2] = Vector3.new(3,1,0)
    vertices[3] = Vector3.new(2,2,0)
    vertices[4] = Vector3.new(1,2,0)
    vertices[5] = Vector3.new(0,1,0)
    polyline_closed = Polyline.new( vertices, false ) # closed Polyline
    polyline_open   = Polyline.new( vertices, true  ) # open Polyline
    trimesh_from_convex_polyline1 = TriMesh.from_convex_polyline( polyline_closed )
    trimesh_from_convex_polyline2 = TriMesh.from_convex_polyline( polyline_open )

    assert_equal(4, trimesh_from_convex_polyline1.area)
    assert_equal(4, trimesh_from_convex_polyline2.area)
  end

  def test_from_extruded_polyline
    vertices = Array.new(6)
    vertices[0] = Vector3.new(1,0,0)
    vertices[1] = Vector3.new(2,0,0)
    vertices[2] = Vector3.new(3,1,0)
    vertices[3] = Vector3.new(2,2,0)
    vertices[4] = Vector3.new(1,2,0)
    vertices[5] = Vector3.new(0,1,0)
    polyline_closed = Polyline.new( vertices, false ) # closed Polyline
    polyline_open   = Polyline.new( vertices, true  ) # open Polyline
    extrude_direction = Vector3.new(0,0,2)
    trimesh_from_extruded_polyline1 = TriMesh.from_extrude_polyline( polyline_closed , extrude_direction )
    trimesh_from_extruded_polyline2 = TriMesh.from_extrude_polyline( polyline_open   , extrude_direction )

    assert_in_delta(4+8*(Math.sqrt(2)), trimesh_from_extruded_polyline1.area, 1e-10)
    assert_in_delta(4+6*(Math.sqrt(2)), trimesh_from_extruded_polyline2.area, 1e-10)
  end

  def test_area
    box_mesh = get_box_mesh()
    assert_equal(94, box_mesh.area)
  end

  def test_normals_for_each_vertices
    box = Box.new(Vector3.new(-1,-1,-1), Vector3.new(1,1,1))
    box_mesh  = TriMesh.from_box(box)
    result = box_mesh.normals_for_each_vertices
    assert_equal( box_mesh.vertices.size, result.size )
    box_mesh.vertices.each do |vertex|
      assert_equal(vertex.normalize, result[vertex])
    end
  end
end
