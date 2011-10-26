$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class FiniteLineTestCase < MiniTest::Unit::TestCase
  def test_initialize
    start_point_tmp = Vector3.new(1.0,  0.0, 2.0)
    end_point_tmp   = Vector3.new(1.0, -3.5, 1.0)
    line = FiniteLine.new(start_point_tmp, end_point_tmp)

    assert_equal(start_point_tmp ,line.start_point)
    assert_equal(end_point_tmp   ,line.end_point  )

    lineDefault = FiniteLine.new()
    assert_equal(Vector3.new(0,0,0), lineDefault.start_point)
    assert_equal(Vector3.new(1,0,0), lineDefault.end_point  )
  end

  def test_to_s
    line = FiniteLine.new(Vector3.new(1,0,2), Vector3.new(1,-3.5,2))
    assert_equal("FiniteLine[from[1, 0, 2], to[1, -3.5, 2]]", line.to_s)
  end

  def test_equals
    line = FiniteLine.new()
    shallow_copied = line
    assert(line == shallow_copied)
    assert(line.equal?(shallow_copied))
    assert(line != nil)
    assert(line != "string")

    assert_equal(FiniteLine.new(Vector3.new(1,2,3), Vector3.new(2,3,4)),
                FiniteLine.new(Vector3.new(1.0,2.0,3.0), Vector3.new(2.0,3.0,4.0)))

    assert(FiniteLine.new(Vector3.new(1,2,3), Vector3.new(2,3,4)) == FiniteLine.new(Vector3.new(1.0,2.0,3.0), Vector3.new(2.0,3.0,4.0)))
    assert(FiniteLine.new(Vector3.new(1,2,3), Vector3.new(2,3,3)) != FiniteLine.new(Vector3.new(1.0,2.0,3.0), Vector3.new(2.0,3.0,4.0)))
    assert(FiniteLine.new(Vector3.new(1,2,3), Vector3.new(2,3,4)) != FiniteLine.new(Vector3.new(2,3,4), Vector3.new(1,2,3)))
  end

  def test_clone
    line = FiniteLine.new()
    shallow_copied = line
    shallow_copied.start_point.x = -1
    assert(line == shallow_copied)
    assert(line.equal?(shallow_copied))
    assert_equal(-1, shallow_copied.start_point.x)

    cloned = line.clone
    assert(line == cloned)
    assert(!line.equal?(cloned))
    cloned.start_point.x = -2
    assert_equal(-2, cloned.start_point.x)

    assert_equal(-1, line.start_point.x) # original never changed in editing cloned one.
  end

  def test_box
    start_point_tmp = Vector3.new(1.0,  0.0, 2.0)
    end_point_tmp   = Vector3.new(1.0, -3.5, 5.0)
    line = FiniteLine.new(start_point_tmp, end_point_tmp)
    assert_equal(Vector3.new(1, -3.5, 2), line.box.min_point)
    assert_equal(Vector3.new(1,    0, 5), line.box.max_point)

    line = FiniteLine.new()
    assert_equal(Vector3.new(), line.box.min_point)
    assert_equal(Vector3.new(1,0,0), line.box.max_point)
  end

  def test_direction
    start_point_tmp = Vector3.new(1.0,  0.0, 2.0)
    end_point_tmp   = Vector3.new(1.0, -3.5, 1.0)
    line = FiniteLine.new(start_point_tmp, end_point_tmp)
    assert_in_delta( 0.0, line.direction.x, line.tolerance)
    assert_in_delta(-3.5, line.direction.y, line.tolerance)
    assert_in_delta(-1.0, line.direction.z, line.tolerance)
  end

  def test_param
    start_point_tmp = Vector3.new(1.0, 1.0,  2.0)
    end_point_tmp   = Vector3.new(2.0, 3.0, -4.0)
    line = FiniteLine.new(start_point_tmp, end_point_tmp)
    assert_equal( Vector3.new(1.0, 1.0,  2.0), line.point(0.0))
    assert_equal( Vector3.new(1.5, 2.0, -1.0), line.point(0.5))
    assert_equal( Vector3.new(2.0, 3.0, -4.0), line.point(1))

    # if param is smaller than 0 or bigger than 1 then return nil
    assert_equal( nil, line.point(-1.0))
    assert_equal( nil, line.point(1.2))
  end

  def test_length
    start_point_tmp = Vector3.new(0.0, 0.0, 2.0)
    end_point_tmp   = Vector3.new(2.0, 2.0, 2.0)
    line = FiniteLine.new(start_point_tmp, end_point_tmp)

    assert_in_delta(Math::sqrt(8), line.length, line.tolerance)
  end

  def test_distance_to_point
    start_point_tmp = Vector3.new(0.0, 0.0, 2.0)
    end_point_tmp   = Vector3.new(2.0, 2.0, 2.0)
    line = FiniteLine.new(start_point_tmp, end_point_tmp)

    targetPoint = Vector3.new(1.0, 1.0, -4.0)
    distance, pointOnLine, parameter = line.distance(targetPoint)
    assert_in_delta(6.0, distance, targetPoint.tolerance)
    assert_equal( Vector3.new(1.0, 1.0, 2.0), pointOnLine)
    assert_in_delta(0.5, parameter, targetPoint.tolerance)

    targetPoint2 = Vector3.new(3.0, 3.0, 2.0)
    distance, pointOnLine, parameter = line.distance(targetPoint2)
    assert_in_delta(Math::sqrt(2), distance, targetPoint.tolerance)
    assert_equal( end_point_tmp, pointOnLine)
    assert_in_delta(1.0, parameter, targetPoint.tolerance)

    targetPoint3 = Vector3.new(0.0, -1.0, 3.0)
    distance, pointOnLine, parameter = line.distance(targetPoint3)
    assert_in_delta(Math::sqrt(2), distance, targetPoint.tolerance)
    assert_equal( start_point_tmp, pointOnLine)
    assert_in_delta(0.0, parameter, targetPoint.tolerance)

    target_point4 = Vector3.new( 2,3,3)
    line = FiniteLine.new( Vector3.new(1,2,3), Vector3.new(1,4,3))
    distance, point_on_line, parameter = line.distance( target_point4 )
    assert_in_delta( 1, distance, line.tolerance )
    assert_equal( Vector3.new(1,3,3), point_on_line )
    assert_in_delta( 0.5, parameter, line.tolerance )
  end

  def test_distance_to_line
    start_point_tmp = Vector3.new(0.0, 0.0, 2.0)
    end_point_tmp   = Vector3.new(2.0, 2.0, 2.0)
    finite_line = FiniteLine.new(start_point_tmp, end_point_tmp)

    #intersect case
    infinite_line = Line.new(Vector3.new(0.0, 2.0, 3.0), Vector3.new(2.0, -2.0, -2.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(infinite_line)
    assert_in_delta(0.0, distance, infinite_line.tolerance)
    assert_equal( Vector3.new(1,1,2), point1)
    assert_equal( Vector3.new(1,1,2), point2)
    assert_in_delta(0.5, parameter1, infinite_line.tolerance)
    assert_in_delta(0.5, parameter2, infinite_line.tolerance)

    #not intersect case
    infinite_line = Line.new(Vector3.new(0.0, 2.0, 4.0), Vector3.new(2.0, -2.0, 0.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(infinite_line)
    assert_in_delta(2.0, distance, infinite_line.tolerance)
    assert_equal( Vector3.new(1,1,2), point1)
    assert_equal( Vector3.new(1,1,4), point2)
    assert_in_delta(0.5, parameter1, infinite_line.tolerance)
    assert_in_delta(0.5, parameter2, infinite_line.tolerance)

    #not intersect case2
    infinite_line = Line.new(Vector3.new(-2.0, 2.0, 4.0), Vector3.new(0.0, -2.0, 0.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(infinite_line)
    assert_in_delta(Math::sqrt(8), distance, infinite_line.tolerance)
    assert_equal( Vector3.new(0,0,2), point1)
    assert_equal( Vector3.new(-2,0,4), point2)
    assert_in_delta(0.0, parameter1, infinite_line.tolerance)
    assert_in_delta(1.0, parameter2, infinite_line.tolerance)

    #not intersect case3
    infinite_line = Line.new(Vector3.new(12.0, 12.0, 2.0), Vector3.new(0, 5.0, 0.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(infinite_line)
    assert_in_delta(10, distance, infinite_line.tolerance)
    assert_equal( Vector3.new(2,2,2), point1)
    assert_equal( Vector3.new(12,2,2), point2)
    assert_in_delta(1.0, parameter1, infinite_line.tolerance)
    assert_in_delta(-2.0, parameter2, infinite_line.tolerance)

    #parallel case
    infinite_line = Line.new(Vector3.new(0, -2.0, 6.0), Vector3.new(-1.0, -1.0, 0.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(infinite_line)
    assert_in_delta(Math::sqrt(18), distance, infinite_line.tolerance)
    assert_equal( nil, point1)
    assert_equal( nil, point2)
    assert_equal( nil, parameter1)
    assert_equal( nil, parameter2)

    #including case
    infinite_line = Line.new(Vector3.new(-2, -2.0, 2.0), Vector3.new(1.0, 1.0, 0.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(infinite_line)
    assert_in_delta(0, distance, infinite_line.tolerance)
    assert_equal( nil, point1)
    assert_equal( nil, point2)
    assert_equal( nil, parameter1)
    assert_equal( nil, parameter2)
  end

  def test_distance_to_finite_line
    finite_line = FiniteLine.new(Vector3.new(0.0, 0.0, 2.0), Vector3.new(2.0,2.0,2.0))

    #intersect case
    target_finite_line = FiniteLine.new(Vector3.new(2.0, 0.0, 2.0), Vector3.new(0.0, 2.0,2.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(0.0, distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(1,1,2), point1)
    assert_equal( Vector3.new(1,1,2), point2)
    assert_in_delta(0.5, parameter1, target_finite_line.tolerance)
    assert_in_delta(0.5, parameter2, target_finite_line.tolerance)

    #not intersect case1
    target_finite_line = FiniteLine.new(Vector3.new(2.0, 0.0, 4.0), Vector3.new(0.0, 2.0, 4.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(2.0, distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(1,1,2), point1)
    assert_equal( Vector3.new(1,1,4), point2)
    assert_in_delta(0.5, parameter1, target_finite_line.tolerance)
    assert_in_delta(0.5, parameter2, target_finite_line.tolerance)

    #not intersect case2
    target_finite_line = FiniteLine.new(Vector3.new(3.0, 2.0, 2.0), Vector3.new(5.0, 0.0, 2.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(1.0, distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(2,2,2), point1)
    assert_equal( Vector3.new(3,2,2), point2)
    assert_in_delta(1.0, parameter1, target_finite_line.tolerance)
    assert_in_delta(0.0, parameter2, target_finite_line.tolerance)

    #not intersect case3
    target_finite_line = FiniteLine.new(Vector3.new(-3.0, 5.0, 5.0), Vector3.new(0.0, 2.0, 2.0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(Math::sqrt(2), distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(1,1,2), point1)
    assert_equal( Vector3.new(0,2,2), point2)
    assert_in_delta(0.5, parameter1, target_finite_line.tolerance)
    assert_in_delta(1.0, parameter2, target_finite_line.tolerance)

    #not intersect case4
    target_finite_line = FiniteLine.new(Vector3.new(-2.0, 5.0, 0), Vector3.new(-2.0, 2.0, 0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(Math::sqrt(12), distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(0,0,2), point1)
    assert_equal( Vector3.new(-2,2,0), point2)
    assert_in_delta(0, parameter1, target_finite_line.tolerance)
    assert_in_delta(1, parameter2, target_finite_line.tolerance)

    #parallel case1
    target_finite_line = FiniteLine.new(Vector3.new(4,4,0),Vector3.new(5,5,0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(Math::sqrt(12), distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(2,2,2), point1)
    assert_equal( Vector3.new(4,4,0), point2)
    assert_in_delta(1.0, parameter1, target_finite_line.tolerance)
    assert_in_delta(0.0, parameter2, target_finite_line.tolerance)

    #parallel case2
    target_finite_line = FiniteLine.new(Vector3.new(2,2,0),Vector3.new(5,5,0))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(2, distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(2,2,2), point1)
    assert_equal( Vector3.new(2,2,0), point2)
    assert_in_delta(1.0, parameter1, target_finite_line.tolerance)
    assert_in_delta(0.0, parameter2, target_finite_line.tolerance)

    #parallel case3
    target_finite_line = FiniteLine.new(Vector3.new(1,1,1),Vector3.new(5,5,1))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(1, distance, target_finite_line.tolerance)
    assert_equal( nil, point1)
    assert_equal( nil, point2)
    assert_equal( nil, parameter1)
    assert_equal( nil, parameter2)

    #including case1
    target_finite_line = FiniteLine.new(Vector3.new(2,2,2),Vector3.new(5,5,2))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(0, distance, target_finite_line.tolerance)
    assert_equal( Vector3.new(2,2,2), point1)
    assert_equal( Vector3.new(2,2,2), point2)
    assert_in_delta(1.0, parameter1, target_finite_line.tolerance)
    assert_in_delta(0.0, parameter2, target_finite_line.tolerance)

    #including case2
    target_finite_line = FiniteLine.new(Vector3.new(1,1,2),Vector3.new(5,5,2))
    distance, point1, point2, parameter1, parameter2 = finite_line.distance(target_finite_line)
    assert_in_delta(0, distance, target_finite_line.tolerance)
    assert_equal( nil, point1)
    assert_equal( nil, point2)
    assert_equal( nil, parameter1)
    assert_equal( nil, parameter2)
  end

  def test_distance_to_invalid_value
    finite_line = FiniteLine.new(Vector3.new(0,1,2), Vector3.new(2,3,4))
    assert_raises ArgumentError do
      finite_line.distance(4)
    end
    assert_raises ArgumentError do
      finite_line.distance(nil)
    end
  end

end
