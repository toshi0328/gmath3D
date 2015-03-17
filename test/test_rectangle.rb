$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

class RectangleTestCase < Minitest::Test
  def setup
    @rectangle = Rectangle.new( Vector3.new(1,2,3), Vector3.new(0,-0.5,0), Vector3.new(0,0,2))
    @rectangle_default = Rectangle.new()
  end

  def test_initialize
    assert_equal(Vector3.new(1, 2,3), @rectangle.base_point)
    assert_equal(Vector3.new(0,-0.5,0), @rectangle.u_vector)
    assert_equal(Vector3.new(0, 0,2), @rectangle.v_vector)

    assert_equal(Vector3.new(0,0,0), @rectangle_default.base_point)
    assert_equal(Vector3.new(1,0,0), @rectangle_default.u_vector)
    assert_equal(Vector3.new(0,1,0), @rectangle_default.v_vector)
  end

  def test_equals
    assert(@rectangle != nil)
    assert(@rectangle != "string")

    shallow_copied = @rectangle
    assert(@rectangle.equal?(shallow_copied))
    assert(@rectangle == shallow_copied)

    assert_equal(@rectangle, Rectangle.new( Vector3.new(1,2,3), Vector3.new(0,-0.5,0), Vector3.new(0,0,2)))
    assert(@rectangle == Rectangle.new( Vector3.new(1,2,3), Vector3.new(0,-0.5,0), Vector3.new(0,0,2.0)))
    assert(@rectangle != Rectangle.new( Vector3.new(1,2,3), Vector3.new(0,-0.5,0), Vector3.new(0,0,2.2)))
  end

  def test_clone
    shallow_copied = @rectangle
    shallow_copied.base_point.x = -1
    assert(@rectangle == shallow_copied)
    assert(@rectangle.equal?(shallow_copied))
    assert_equal(-1, shallow_copied.base_point.x)
    assert_equal(-1, @rectangle.base_point.x)

    cloned = @rectangle.clone
    assert(@rectangle == cloned)
    assert(!@rectangle.equal?(cloned))
    cloned.base_point.x = -2
    cloned.u_vector.x = 4
    cloned.v_vector.z = 6
    assert_equal(-2, cloned.base_point.x)
    assert_equal(4, cloned.u_vector.x)
    assert_equal(6, cloned.v_vector.z)

    assert_equal(-1, @rectangle.base_point.x) # original never changed in editing cloned one.
    assert_equal(0,  @rectangle.u_vector.x)
    assert_equal(2,  @rectangle.v_vector.z)
  end

  def test_to_s
    assert_equal("Rectangle[base[1, 2, 3], u[0, -0.5, 0], v[0, 0, 2]", @rectangle.to_s)
  end

  def test_box
    box1 = @rectangle.box
    box2 = @rectangle_default.box
    assert_equal(Vector3.new(1, 1.5, 3), box1.min_point)
    assert_equal(Vector3.new(1,   2, 5), box1.max_point)
    assert_equal(Vector3.new(0,   0, 0), box2.min_point)
    assert_equal(Vector3.new(1,   1, 0), box2.max_point)
  end

  def test_point
    point = @rectangle.point(0.2, 1.0)
    assert_equal(Vector3.new(1, 1.9, 5), point)

    point = @rectangle.point(-2.0, 0.5)
    assert_equal(Vector3.new(1, 3, 4), point)

    point = @rectangle_default.point(0,0)
    assert_equal(Vector3.new(0,0,0), point)

    point = @rectangle_default.point(0.5, 0.5)
    assert_equal(@rectangle_default.center_point, point)
  end

  def test_edges
    edges = @rectangle.edges
    assert_equal(4, edges.size)
    assert_equal(Vector3.new(1,2,  3), edges[0].start_point)
    assert_equal(Vector3.new(1,1.5,3), edges[0].end_point)
    assert_equal(Vector3.new(1,1.5,3), edges[1].start_point)
    assert_equal(Vector3.new(1,1.5,5), edges[1].end_point)
    assert_equal(Vector3.new(1,1.5,5), edges[2].start_point)
    assert_equal(Vector3.new(1,2  ,5), edges[2].end_point)
    assert_equal(Vector3.new(1,2  ,5), edges[3].start_point)
    assert_equal(Vector3.new(1,2  ,3), edges[3].end_point)
  end

  def test_vertices
    vertices = @rectangle.vertices
    assert_equal(4, vertices.size)
    assert_equal(Vector3.new(1,2,3), vertices[0])
    assert_equal(Vector3.new(1,1.5,3), vertices[1])
    assert_equal(Vector3.new(1,1.5,5), vertices[2])
    assert_equal(Vector3.new(1,2,5), vertices[3])
  end

  def test_normal
    assert_equal(Vector3.new(-1,0,0), @rectangle.normal)
    assert_equal(Vector3.new(0,0,1), @rectangle_default.normal)
  end

  def test_opposite_point
    assert_equal(Vector3.new(1,1.5,5), @rectangle.opposite_point)
    assert_equal(Vector3.new(1,1,0), @rectangle_default.opposite_point)
  end

  def test_center_point
    assert_equal(Vector3.new(1,1.75,4), @rectangle.center_point)
    assert_equal(Vector3.new(0.5,0.5,0), @rectangle_default.center_point)
  end

  def test_area
    assert_in_delta( 1.0, @rectangle.area, @rectangle.tolerance)
    assert_in_delta( 1.0, @rectangle_default.area, @rectangle_default.tolerance)
  end

  def test_uv_param
    # inside case
    check_point = @rectangle.center_point
    u, v = @rectangle.uv_parameter(check_point)
    assert_in_delta(0.5, u, @rectangle.tolerance)
    assert_in_delta(0.5, v, @rectangle.tolerance)

    # inside case2
    check_point = @rectangle.point(0.3,0.6) + @rectangle.normal*1.0
    u, v = @rectangle.uv_parameter(check_point)
    assert_in_delta(0.3, u, @rectangle.tolerance)
    assert_in_delta(0.6, v, @rectangle.tolerance)

    # on edge
    u, v = @rectangle.uv_parameter(Vector3.new(2, 1.75, 5))
    assert_in_delta(0.5, u, @rectangle.tolerance)
    assert_in_delta(1, v, @rectangle.tolerance)

    # on vertex
    u, v = @rectangle.uv_parameter(@rectangle.opposite_point)
    assert_in_delta(1.0, u, @rectangle.tolerance)
    assert_in_delta(1, v, @rectangle.tolerance)

    # outside case1
    u, v = @rectangle.uv_parameter(@rectangle.point(2.0, -3.0))
    assert_in_delta(2.0, u, @rectangle.tolerance)
    assert_in_delta(-3.0, v, @rectangle.tolerance)
  end

  def test_distance_to_point
    # inside case
    distance, point_on_rectangle = @rectangle.distance(Vector3.new(0.5,1.75,4.5))
    assert_in_delta( 0.5, distance, @rectangle.tolerance)
    assert_equal(Vector3.new(1, 1.75, 4.5), point_on_rectangle)

    # on edge
    distance, point_on_rectangle = @rectangle.distance(Vector3.new(2.0,1.5,4.5))
    assert_in_delta( 1.0, distance, @rectangle.tolerance)
    assert_equal(Vector3.new(1, 1.5, 4.5), point_on_rectangle)

    # on vertex
    distance, point_on_rectangle = @rectangle.distance(Vector3.new(-0.5,2,3))
    assert_in_delta( 1.5, distance, @rectangle.tolerance)
    assert_equal(Vector3.new(1,2,3), point_on_rectangle)

    # outside on edge
    distance, point_on_rectangle = @rectangle.distance(Vector3.new(0,1.75,2))
    assert_in_delta( Math::sqrt(2), distance, @rectangle.tolerance)
    assert_equal(Vector3.new(1,1.75,3), point_on_rectangle)

    # outside on vertex
    distance, point_on_rectangle = @rectangle.distance(Vector3.new(0,0,0))
    assert_in_delta( Math::sqrt(12.25), distance, @rectangle.tolerance)
    assert_equal(Vector3.new(1,1.5,3), point_on_rectangle)
  end
end
