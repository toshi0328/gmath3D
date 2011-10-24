$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class TriMeshTestCase < MiniTest::Unit::TestCase
  def get_box_mesh
    box = Box.new(Vector3.new(-1,-1,-1), Vector3.new(2,3,4))
    return TriMesh.from_box(box)
  end

  def get_plane_mesh
    rect = Rectangle.new(Vector3.new(-1,-1,-1), Vector3.new(2,0,0), Vector3.new(0,4,0) )
    return TriMesh.from_rectangle(rect)
  end

  def test_to_s
    assert_equal( "TriMesh[triangle_count:12, vertex_count:8]", get_box_mesh().to_s)
  end

  def test_initalize
    plane_mesh = get_plane_mesh()
    assert_equal( 2, plane_mesh.tri_indeces.size)
    assert_equal( 4, plane_mesh.vertices.size)

    box_mesh = get_box_mesh()
    assert_equal( 12, box_mesh.tri_indeces.size)
    assert_equal( 8, box_mesh.vertices.size)

    assert_raises ArgumentError do
      invalidResult = TriMesh.new(nil)
    end
    assert_raises ArgumentError do
      invalidResult = TriMesh.new(Vector3.new(), 4.0)
    end
  end

  def test_triangles
    vertices = [Vector3.new(0,0,0),Vector3.new(2,0,0),Vector3.new(2,2,0),Vector3.new(0,2,0)]
    tri_indeces = [[0,1,3],[1,2,3]]
    tri_mesh = TriMesh.new(vertices, tri_indeces)
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
    assert_equal( 8, trimesh_from_tris.tri_indeces.size)
  end

  def test_from_convex_polyline
    vertices = Array.new(6)
    #TODO impliment!
  end

  def test_from_extruded_polyline
    vertices = Array.new(6)
    #TODO impliment!
  end

end
