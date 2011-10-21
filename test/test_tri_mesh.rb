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

  
end
