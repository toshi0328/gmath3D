$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class TriangleTestCase < MiniTest::Unit::TestCase
  def setup
    @triangle = Triangle.new( Vector3.new(1,2,2), Vector3.new(1,4,2), Vector3.new(-1,3,0))
    @triangle_default = Triangle.new()
  end

  def test_initialize
    assert_equal(Vector3.new(1,2,2), @triangle.vertices[0])
    assert_equal(Vector3.new(1,4,2), @triangle.vertices[1])
    assert_equal(Vector3.new(-1,3,0), @triangle.vertices[2])

    assert_equal(Vector3.new(0,0,0), @triangle_default.vertices[0])
    assert_equal(Vector3.new(1,0,0), @triangle_default.vertices[1])
    assert_equal(Vector3.new(0,1,0), @triangle_default.vertices[2])
  end

  def test_equals
    assert(@triangle != nil)
    assert(@triangle != "string")

    shallow_copied = @triangle
    assert(@triangle.equal?(shallow_copied))
    assert(@triangle == shallow_copied)

    assert_equal(@triangle, Triangle.new( Vector3.new(1.0,2.0,2.0), Vector3.new(1.0,4.0,2.0), Vector3.new(-1.0,3.0,0.0)))
    assert(@triangle == Triangle.new( Vector3.new(1.0,2.0,2.0), Vector3.new(1.0,4.0,2.0), Vector3.new(-1.0,3.0,0.0)))
    assert(@triangle != Triangle.new( Vector3.new(1.0,2.0,2.0), Vector3.new(1.0,4.0,2.0), Vector3.new(-1.0,3.0,0.5)))
  end

  def test_clone
    shallow_copied = @triangle
    shallow_copied.vertices[2].x = 1
    assert(@triangle == shallow_copied)
    assert(@triangle.equal?(shallow_copied))
    assert_equal(1, @triangle.vertices[2].x)
    assert_equal(1, shallow_copied.vertices[2].x)

    cloned =@triangle.clone
    assert(@triangle == cloned)
    assert(!@triangle.equal?(cloned))

    cloned.vertices[2].x = -10
    assert_equal(-10, cloned.vertices[2].x)
    assert_equal(1, @triangle.vertices[2].x) # original never changed in editing cloned one.
  end

  def test_to_s
    assert_equal("Triangle[[1, 2, 2], [1, 4, 2], [-1, 3, 0]]", @triangle.to_s)
  end

  def test_point
    assert_equal(@triangle.vertices[0], @triangle.point( Array.new([1,0,0])))
    assert_equal(@triangle.vertices[1], @triangle.point( Array.new([0,1,0])))
    assert_equal(@triangle.vertices[2], @triangle.point( Array.new([0,0,1])))

    #on edge
    assert_equal(Vector3.new(1,3,2), @triangle.point( Array.new([0.5,0.5,0])))
    assert_equal(Vector3.new(0,3.5,1), @triangle.point( Array.new([0,0.5,0.5])))
    assert_equal(Vector3.new(0,2.5,1), @triangle.point( Array.new([0.5,0,0.5])))

    #inside
    assert_equal(Vector3.new(0, 3, 1), @triangle.point( Array.new([0.25,0.25,0.5])))
    assert_equal(@triangle.center, @triangle.point( Array.new([1.0/3.0,1.0/3.0,1.0/3.0])))
  end

  def test_edges
    edges = @triangle.edges
    assert_equal(@triangle.vertices[0], edges[0].start_point)
    assert_equal(@triangle.vertices[1], edges[0].end_point)
    assert_equal(@triangle.vertices[1], edges[1].start_point)
    assert_equal(@triangle.vertices[2], edges[1].end_point)
    assert_equal(@triangle.vertices[2], edges[2].start_point)
    assert_equal(@triangle.vertices[0], edges[2].end_point)
  end

  def test_area
    assert_in_delta(Math::sqrt(8), @triangle.area, @triangle.tolerance)
    assert_in_delta(0.5, @triangle_default.area, @triangle_default.tolerance)
  end

  def test_normal
    assert_equal( Vector3.new(-1,0,1).normalize(), @triangle.normal )
    assert_equal( Vector3.new(0,0,1) ,@triangle_default.normal )
  end

  def test_reverse
    current_normal = @triangle.normal()
    reversed_normal = @triangle.reverse().normal()
    assert( current_normal.parallel?(reversed_normal) )
    assert( !current_normal.same_direction?(reversed_normal) )
  end

  def test_center
    center = @triangle.center
    assert_in_delta( 0.333333333333333, center.x, @triangle.tolerance)
    assert_in_delta( 3.0, center.y, @triangle.tolerance)
    assert_in_delta( 1.333333333333333, center.z, @triangle.tolerance)

    barycentric_coordinate = @triangle.barycentric_coordinate(center)
    assert_in_delta( 1.0/3.0, barycentric_coordinate[0], @triangle.tolerance)
    assert_in_delta( 1.0/3.0, barycentric_coordinate[1], @triangle.tolerance)
    assert_in_delta( 1.0/3.0, barycentric_coordinate[2], @triangle.tolerance)
  end

  def test_barycentric_coordinate
    # on vertex
    coord = @triangle.barycentric_coordinate( @triangle.vertices[1])
    assert_equal( 3, coord.size )
    assert_in_delta( 0, coord[0], @triangle.tolerance)
    assert_in_delta( 1, coord[1], @triangle.tolerance)
    assert_in_delta( 0, coord[2], @triangle.tolerance)

    # on edge
    coord = @triangle.barycentric_coordinate( Vector3.new(1,3,2) )
    assert_in_delta( 0.5, coord[0], @triangle.tolerance)
    assert_in_delta( 0.5, coord[1], @triangle.tolerance)
    assert_in_delta( 0, coord[2], @triangle.tolerance)

    # inside case
    coord = @triangle.barycentric_coordinate( Vector3.new(0,3,1) )
    assert_in_delta( 1.0, coord[0] + coord[1] + coord[2], @triangle.tolerance)
    assert_in_delta( 0.25, coord[0], @triangle.tolerance)
    assert_in_delta( 0.25, coord[1], @triangle.tolerance)
    assert_in_delta( 0.5, coord[2], @triangle.tolerance)

    # outside case
    coord = @triangle_default.barycentric_coordinate( Vector3.new(2,0,0) )
    assert_in_delta( -1.0, coord[0], @triangle.tolerance)
    assert_in_delta( 2.0, coord[1], @triangle.tolerance)
    assert_in_delta( 0.0, coord[2], @triangle.tolerance)

    # outside case
    coord = @triangle.barycentric_coordinate( Vector3.new(3,3,4) )
    assert_in_delta(  1.0, coord[0], @triangle.tolerance)
    assert_in_delta(  1.0, coord[1], @triangle.tolerance)
    assert_in_delta( -1.0, coord[2], @triangle.tolerance)

    #invalid argument
    assert_raises ArgumentError do
      coord = @triangle.barycentric_coordinate( 3 )
    end
    assert_raises ArgumentError do
      coord = @triangle.barycentric_coordinate( nil )
    end
  end

  def test_contains
    check_point = @triangle.center + @triangle.normal*3.0
    assert( !@triangle.contains?( check_point) )
    assert( @triangle.contains?( @triangle.center) )
    assert( @triangle.contains?( Vector3.new( 1,3,2)))
    assert( @triangle.contains?( Vector3.new(-1,3,0)))
    assert( @triangle_default.contains?( Vector3.new( 0.5, 0.5, 0.0 ) ))
    assert( !@triangle_default.contains?( Vector3.new( -1.0, 2.0, 0.0 )))
    assert( !@triangle_default.contains?( Vector3.new( 1.0, 1.0, 0.0 )))
  end

  def test_distance_to_point
    # on inside
    check_point = @triangle.center + @triangle.normal*3.0
    distance, point_on_triangle = @triangle.distance(check_point)
    assert_in_delta(3.0, distance, @triangle.tolerance)
    assert_equal(@triangle.center, point_on_triangle)

    # on vertex
    distance, point_on_triangle = @triangle_default.distance(Vector3.new(-1,-1,0.5))
    assert_in_delta(Math::sqrt(2.25), distance, @triangle_default.tolerance)
    assert_equal(@triangle_default.vertices[0], point_on_triangle)

    # on edge
    distance, point_on_triangle = @triangle.distance( Vector3.new(2,3,2))
    assert_in_delta(1, distance, @triangle_default.tolerance)
    assert_equal(Vector3.new(1,3,2), point_on_triangle)

    # contains to inside
    distance, point_on_triangle = @triangle_default.distance(@triangle_default.center)
    assert_in_delta(0, distance, @triangle_default.tolerance)
    assert_equal(@triangle_default.center, point_on_triangle)
  end

  def test_distance_to_line
    # on inside
    line = Line.new(Vector3.new(0,3,-1), Vector3.new(0,0,4))
    distance, point_on_triangle, point_on_line, param_on_line = @triangle.distance(line)
    assert_equal(0, distance)
    assert_equal(Vector3.new(0,3,1), point_on_triangle)
    assert_equal(Vector3.new(0,3,1), point_on_line)
    assert_in_delta(0.5, param_on_line, line.tolerance)

    # on edge
    line = Line.new(Vector3.new(1,3,-1), Vector3.new(0,0,4))
    distance, point_on_triangle, point_on_line, param_on_line = @triangle.distance(line)
    assert_equal(0, distance)
    assert_equal(Vector3.new(1,3,2), point_on_triangle)
    assert_equal(Vector3.new(1,3,2), point_on_line)
    assert_in_delta(0.75, param_on_line, line.tolerance)

    # on vertex
    line = Line.new(Vector3.new(-1,3,0), Vector3.new(1,1,2))
    distance, point_on_triangle, point_on_line, param_on_line = @triangle.distance(line)
    assert_equal(0, distance)
    assert_equal(Vector3.new(-1,3,0), point_on_triangle)
    assert_equal(Vector3.new(-1,3,0), point_on_line)
    assert_in_delta(0.0, param_on_line, line.tolerance)

    # closest point is out of triangle1
    line = Line.new(Vector3.new(2,3,0), Vector3.new(0,0,4))
    distance, point_on_triangle, point_on_line, param_on_line = @triangle.distance(line)
    assert_equal(1, distance)
    assert_equal(Vector3.new(1,3,2), point_on_triangle)
    assert_equal(Vector3.new(2,3,2), point_on_line)
    assert_in_delta(0.5, param_on_line, line.tolerance)

    # closest point is out of triangle2
    line = Line.new(Vector3.new(-2,3,-1), Vector3.new(0,0,1))
    distance, point_on_triangle, point_on_line, param_on_line = @triangle.distance(line)
    assert_equal(1, distance)
    assert_equal(Vector3.new(-1,3,0), point_on_triangle)
    assert_equal(Vector3.new(-2,3,0), point_on_line)
    assert_in_delta(1, param_on_line, line.tolerance)

    # parallel case
    line = Line.new(Vector3.new(1,0,4), Vector3.new(0,6,0))
    distance, point_on_triangle, point_on_line, param_on_line = @triangle.distance(line)
    assert_equal(2, distance)
    assert_equal(nil, point_on_triangle)
    assert_equal(nil, point_on_line)
    assert_equal(nil, param_on_line)
  end

  def test_distance_to_plane
    # intersect case
    plane = Plane.new(Vector3.new(0,0,1), Vector3.new(1,0,0))
    distance, intersect_line, point_on_triangle, point_on_plane = @triangle.distance(plane)
    assert_equal( 0, distance )
    point1 = Vector3.new(0,2.5,1)
    point2 = Vector3.new(0,3.5,1)
    assert( FiniteLine.new(point1, point2) == intersect_line || FiniteLine.new(point2, point1) == intersect_line)
    assert_equal( nil, point_on_triangle )
    assert_equal( nil, point_on_plane )

    # contains edge
    plane = Plane.new(Vector3.new(1,0,1), Vector3.new(-1,0,0))
    distance, intersect_line, point_on_triangle, point_on_plane = @triangle.distance(plane)
    assert_equal( 0, distance )
    point1 = Vector3.new(1,2,2)
    point2 = Vector3.new(1,4,2)
    assert( FiniteLine.new(point1, point2) == intersect_line || FiniteLine.new(point2, point1) == intersect_line)
    assert_equal( nil, point_on_triangle )
    assert_equal( nil, point_on_plane )

    # contains vertex
    plane = Plane.new(Vector3.new(-1,0,1), Vector3.new(1,0,0))
    distance, intersect_line, point_on_triangle, point_on_plane = @triangle.distance(plane)
    assert_equal( 0, distance )
    assert_equal( nil, intersect_line)
    assert_equal( Vector3.new(-1,3,0), point_on_triangle )
    assert_equal( Vector3.new(-1,3,0), point_on_plane )

    # closeing point is outside of triangle
    plane = Plane.new(Vector3.new(-2,0,0), Vector3.new(-1,0,0))
    distance, intersect_line, point_on_triangle, point_on_plane = @triangle.distance(plane)
    assert_equal( 1, distance )
    assert_equal( nil, intersect_line)
    assert_equal( Vector3.new(-1,3,0), point_on_triangle )
    assert_equal( Vector3.new(-2,3,0), point_on_plane )

    # parallel to plane
    plane = Plane.new(Vector3.new(0,0,4), Vector3.new(0,0,1))
    distance, intersect_line, point_on_triangle, point_on_plane = @triangle_default.distance(plane)
    assert_equal( 4, distance )
    assert_equal( nil, intersect_line)
    assert_equal( nil, point_on_triangle )
    assert_equal( nil, point_on_plane )

    # parallel to edge
    plane = Plane.new(Vector3.new(3.5,0,3), Vector3.new(-1,0,0))
    distance, closest_line, point_on_triangle, point_on_plane = @triangle.distance(plane)
    assert_equal( 2.5, distance )
    point1 = Vector3.new(1,2,2)
    point2 = Vector3.new(1,4,2)
    assert( FiniteLine.new(point1, point2) == closest_line || FiniteLine.new(point2, point1) == closest_line)
    assert_equal( nil, point_on_triangle )
    assert_equal( nil, point_on_plane )
  end
end
