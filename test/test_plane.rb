$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class PlaneTestCase < MiniTest::Unit::TestCase
  def setup
    @base_point = Vector3.new(0,0,1)
    @normal = Vector3.new(0,0,1)
    @plane = Plane.new(@base_point, @normal)
    @plane_default = Plane.new()
  end

  def test_initialize
    assert_equal(@base_point, @plane.base_point)
    assert_equal(@normal, @plane.normal)
    assert_equal(Vector3.new(0,0,0),@plane_default.base_point)
    assert_equal(Vector3.new(0,0,1),@plane_default.normal)
    assert_equal(Geom.default_tolerance, @plane_default.tolerance)
  end

  def test_to_s
    assert_equal("Plane[point[0, 0, 1], normal[0.0, 0.0, 1.0]]", @plane.to_s)
  end

  def test_equals
    plane = Plane.new()
    shallow_copied = plane
    assert(plane.equal?(shallow_copied))
    assert(plane == shallow_copied)
    assert(plane != nil)
    assert(plane != "string")

    assert_equal(Plane.new(Vector3.new(1,2,3), Vector3.new(2,3,4)), Plane.new(Vector3.new(1.0,2.0,3.0), Vector3.new(2.0,3.0,4.0)))

    assert(Plane.new(Vector3.new(1,2,3), Vector3.new(2,3,4)) == Plane.new(Vector3.new(1.0,2.0,3.0), Vector3.new(2.0,3.0,4.0)))
    assert(Plane.new(Vector3.new(1,2,3), Vector3.new(2,3,4)) == Plane.new(Vector3.new(1.0,2.0,3.0), Vector3.new(4.0,6,8.0)))
    assert(Plane.new(Vector3.new(1,2,3), Vector3.new(2,3,3)) != Plane.new(Vector3.new(1.0,2.0,3.0), Vector3.new(2.0,3.0,4.0)))
    assert(Plane.new(Vector3.new(1,2,3), Vector3.new(2,3,4)) != Plane.new(Vector3.new(2,3,4), Vector3.new(1,2,3)))
  end

  def test_clone
    plane = Plane.new()
    shallow_copied = plane
    shallow_copied.base_point.x = -1
    assert(plane == shallow_copied)
    assert(plane.equal?(shallow_copied))
    assert_equal(-1, shallow_copied.base_point.x)

    cloned = plane.clone
    assert(plane == cloned)
    assert(!plane.equal?(cloned))
    cloned.base_point.x = -2
    assert_equal(-2, cloned.base_point.x)

    assert_equal(-1, plane.base_point.x) # original never changed in editing cloned one.
  end

  def test_distance_to_point
    target_point = Vector3.new(1,2,3)
    distance, closest_point = @plane.distance(target_point)
    assert_in_delta(2, distance, target_point.tolerance)
    assert_equal(Vector3.new(1,2,1),closest_point)

    target_point = Vector3.new(1,-4,-5)
    distance, closest_point = @plane_default.distance(target_point)
    assert_in_delta(5, distance, target_point.tolerance)
    assert_equal(Vector3.new(1,-4,0),closest_point)

    target_point = Vector3.new(-2,4.5,1.0)
    distance, closest_point = @plane.distance(target_point)
    assert_in_delta(0, distance, target_point.tolerance)
    assert_equal(Vector3.new(-2,4.5,1.0),closest_point)

    plane2 = Plane.new(Vector3.new( 1.0, 1.0, 1.0), Vector3.new(1.0, 1.0, 0.0))
    target_point = Vector3.new( 0.0, 0.0, 0.0 )
    distance, closest_point = plane2.distance(target_point)
    assert_in_delta( Math::sqrt(2), distance, plane2.tolerance)
    assert_equal( Vector3.new( 1,1,0 ), closest_point)
  end

  def test_distance_to_line
    #intersect case
    target_line = Line.new(Vector3.new(1,1,2),Vector3.new(1,1,1))
    distance, intersect_point, parameter = @plane.distance(target_line)
    assert_in_delta(0, distance, @plane.tolerance)
    assert_equal(Vector3.new(0,0,1), intersect_point)
    assert_in_delta(-1, parameter, intersect_point.tolerance)

    #intersect case 2
    target_line = Line.new(Vector3.new(0,0,0),Vector3.new(2,2,2))
    distance, intersect_point, parameter = @plane.distance(target_line)
    assert_in_delta(0, distance, @plane.tolerance)
    assert_equal(Vector3.new(1,1,1), intersect_point)
    assert_in_delta(0.5, parameter, intersect_point.tolerance)

    #parallel case
    target_line = Line.new(Vector3.new(1,1,1.5),Vector3.new(1,1,0))
    distance, intersect_point, parameter = @plane_default.distance(target_line)
    assert_in_delta(1.5, distance, @plane_default.tolerance)
    assert_equal(nil, intersect_point)
    assert_equal(nil, parameter)

    #contains case
    target_line = Line.new(Vector3.new(1,1,1),Vector3.new(1,2.0,0))
    distance, intersect_point, parameter = @plane.distance(target_line)
    assert_in_delta(0, distance, @plane.tolerance)
    assert_equal(nil, intersect_point)
    assert_equal(nil, parameter)
  end

  def test_distance_to_finite_line
    #intersect case
    target_finite_line = FiniteLine.new(Vector3.new(0,0,0),Vector3.new(2,2,2))
    distance, point_on_plane, point_on_line, parameter_on_line = @plane.distance(target_finite_line)
    assert_in_delta(0, distance, @plane.tolerance)
    assert_equal( Vector3.new(1,1,1), point_on_plane)
    assert_equal( Vector3.new(1,1,1), point_on_line)
    assert_in_delta(0.5, parameter_on_line, @plane.tolerance)

    #intersect case2
    target_finite_line = FiniteLine.new(Vector3.new(0,0,0),Vector3.new(1,1,1))
    distance, point_on_plane, point_on_line, parameter_on_line = @plane.distance(target_finite_line)
    assert_in_delta(0, distance, @plane.tolerance)
    assert_equal( Vector3.new(1,1,1), point_on_plane)
    assert_equal( Vector3.new(1,1,1), point_on_line)
    assert_in_delta(1, parameter_on_line, @plane.tolerance)

    #not intersect case
    target_finite_line = FiniteLine.new(Vector3.new(2,2,2),Vector3.new(4,5,6))
    distance, point_on_plane, point_on_line, parameter_on_line = @plane.distance(target_finite_line)
    assert_in_delta(1, distance, @plane.tolerance)
    assert_equal( Vector3.new(2,2,1), point_on_plane)
    assert_equal( Vector3.new(2,2,2), point_on_line)
    assert_in_delta(0, parameter_on_line, @plane.tolerance)

    #not intersect case2
    target_finite_line = FiniteLine.new(Vector3.new(3,6,-9),Vector3.new(-2,3,-5))
    distance, point_on_plane, point_on_line, parameter_on_line = @plane.distance(target_finite_line)
    assert_in_delta(6, distance, @plane.tolerance)
    assert_equal( Vector3.new(-2,3,1), point_on_plane)
    assert_equal( Vector3.new(-2,3,-5), point_on_line)
    assert_in_delta(1, parameter_on_line, @plane.tolerance)

    #parallel case
    target_finite_line = FiniteLine.new(Vector3.new(3,3,3),Vector3.new(1,-4,3))
    distance, point_on_plane, point_on_line, parameter_on_line = @plane.distance(target_finite_line)
    assert_in_delta(2, distance, @plane.tolerance)
    assert_equal( nil, point_on_plane)
    assert_equal( nil, point_on_line)
    assert_equal( nil, parameter_on_line)

    #including case
    target_finite_line = FiniteLine.new(Vector3.new(3,3,1),Vector3.new(1,-4,1))
    distance, point_on_plane, point_on_line, parameter_on_line = @plane.distance(target_finite_line)
    assert_in_delta(0, distance, @plane.tolerance)
    assert_equal( nil, point_on_plane)
    assert_equal( nil, point_on_line)
    assert_equal( nil, parameter_on_line)
  end

  def test_distance_to_plane
    #intersect case
    target_plane = Plane.new(Vector3.new(1,1,4), Vector3.new(1,-1,0))
    distance, intersect_line = @plane.distance(target_plane)
    assert_in_delta(0, distance, @plane.tolerance)
    assert(intersect_line.direction.parallel?(Vector3.new(1,1,0)))

    #parallel case
    target_plane = Plane.new(Vector3.new(1,1,4), Vector3.new(0,0,-1))
    distance, intersect_line = @plane.distance(target_plane)
    assert_in_delta(3, distance, @plane.tolerance)
    assert_equal(nil, intersect_line)

    #including case
    target_plane = Plane.new(Vector3.new(1,1,1), Vector3.new(0,0,3))
    distance, intersect_line = @plane.distance(target_plane)
    assert_in_delta(0, distance, @plane.tolerance)
    assert_equal(nil, intersect_line)
  end

  def test_distance_to_invalid_value
    assert_raises ArgumentError do
      @plane.distance(4)
    end
    assert_raises ArgumentError do
      @plane.distance(nil)
    end
  end
  
  def test_project
    assert_equal( Vector3.new( 2.0, 4.0, 1.0), @plane.project(Vector3.new(2.0, 4.0, -5.0)))
    assert_equal( Vector3.new( 2.0, 4.0, 1.0), @plane.project(Vector3.new(2.0, 4.0, 5.0)))
    assert_equal( Vector3.new( 0.0, -4.0, 1.0), @plane.project(Vector3.new(0.0, -4.0, 1.0)))
    plane2 = Plane.new( Vector3.new(1,1,1), Vector3.new(1,1,0))
    assert_equal( Vector3.new( 1,1,5), plane2.project( Vector3.new( 0,0,5)))
  end
end
