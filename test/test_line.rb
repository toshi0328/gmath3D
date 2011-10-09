include GMath3D

MiniTest::Unit.autorun

class LineTestCase < MiniTest::Unit::TestCase
  def test_initialize
    base_point_tmp = Vector3.new(2.0, 3.0, 5.0)
    direction_tmp  = Vector3.new(1.0, 1.0, 1.0)
    line = Line.new(base_point_tmp, direction_tmp)

    assert(base_point_tmp == line.base_point)
    assert(direction_tmp  == line.direction )

    lineDefault = Line.new()
    assert(Vector3.new(0,0,0) == lineDefault.base_point)
    assert(Vector3.new(1,0,0) == lineDefault.direction )
  end

  def test_to_s
    line =  Line.new(Vector3.new(2.0, 3, 5), Vector3.new(1.0, 1.0, 1.0))
    assert_equal("Line[point[2.0, 3, 5], vector[1.0, 1.0, 1.0]", line.to_s);
  end

  def test_point
    base_point_tmp = Vector3.new(2.0, 3.0, 5.0)
    direction_tmp  = Vector3.new(1.0, 1.0, 0.0)
    line = Line.new(base_point_tmp, direction_tmp)

    assert(Vector3.new(2.0, 3.0, 5.0) == line.point(0.0))
    assert(Vector3.new(3.0, 4.0, 5.0) == line.point(1.0))
    assert(Vector3.new(2.5, 3.5, 5.0) == line.point(0.5))
    assert(Vector3.new(4.0, 5.0, 5.0) == line.point(2))
    assert(Vector3.new(1.0, 2.0, 5.0) == line.point(-1.0))
  end

  def test_distance_to_point
    base_point_tmp = Vector3.new(2.0, 3.0, 5.0)
    direction_tmp  = Vector3.new(1.0, 1.0, 0.0)
    line = Line.new(base_point_tmp, direction_tmp)

    check_point1 = base_point_tmp + Vector3.new(-1.0, 1.0, 0.0)
    distance, closest_point, parameter = line.distance(check_point1)
    assert_in_delta(Math::sqrt(2.0), distance, line.tolerance)
    assert(base_point_tmp == closest_point)
    assert_in_delta(0.0, parameter, line.tolerance)

    check_point2 = check_point1 + direction_tmp
    distance, closest_point, parameter = line.distance(check_point2)
    assert_in_delta(Math::sqrt(2.0), distance, line.tolerance)
    assert(base_point_tmp + direction_tmp == closest_point)
    assert_in_delta(1.0, parameter, line.tolerance)

    check_point3 = line.point(0.3)
    distance, closest_point = line.distance(check_point3)
    assert_in_delta(0.0, distance, line.tolerance)
    assert(check_point3 == closest_point)

    target_point4 = Vector3.new(2,3,3)
    line2 = Line.new( Vector3.new(1,2,3), Vector3.new(0,2,0))
    distance, point_on_line, parameter = line2.distance( target_point4 )
    assert_in_delta( 1, distance, line.tolerance )
    assert_equal( Vector3.new(1,3,3), point_on_line )
    assert_in_delta( 0.5, parameter, line.tolerance ) 
  end

  def test_distance_to_line
    base_point_tmp1 = Vector3.new(0.0, 0.0, 0.0)
    direction_tmp1  = Vector3.new(1.0, 1.0, 0.0)
    line1 = Line.new(base_point_tmp1, direction_tmp1)

    base_point_tmp2 = Vector3.new(1.0, 1.0, 3.0)
    direction_tmp2  = Vector3.new(-1.0, 1.0, 0.0)
    line2 = Line.new(base_point_tmp2, direction_tmp2)

    distance, point1, point2, parameter1, parameter2 = line1.distance(line2)
    assert_in_delta(3.0, distance, line1.tolerance)
    assert(Vector3.new(1.0, 1.0, 0.0) == point1)
    assert(Vector3.new(1.0, 1.0, 3.0) == point2)
    assert_in_delta(1.0, parameter1, line1.tolerance)
    assert_in_delta(0.0, parameter2, line2.tolerance)

    # distance for same lines
    distance, point1, point2, parameter1, parameter2 = line1.distance(line1)
    assert_in_delta(0.0, distance, line1.tolerance)
    assert_equal(nil, point1)
    assert_equal(nil, point2)
    assert_equal(nil, parameter1)
    assert_equal(nil, parameter2)

    # parallel case
    base_point_tmp3 = Vector3.new(0.0, 0.0, 4.0)
    direction_tmp3  = Vector3.new(-1.0, -1.0, 0.0)
    line3 = Line.new(base_point_tmp3, direction_tmp3)
    distance, point1, point2, parameter1, parameter2 = line1.distance(line3)
    assert_in_delta(4.0, distance, line3.tolerance)
    assert_equal(nil, point1)
    assert_equal(nil, point2)
    assert_equal(nil, parameter1)
    assert_equal(nil, parameter2)
  end

  def test_distance_to_invalid_value
    assert_raises ArgumentError do
      invalidResult = Line.new.distance(nil)
    end
    assert_raises ArgumentError do
      invalidResult = Line.new.distance(5.0)
    end
  end
end
