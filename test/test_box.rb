require 'box'

include GMath3D

MiniTest::Unit.autorun

class BoxTestCase < MiniTest::Unit::TestCase
  def setup
    @box_default = Box.new()
    @box = Box.new(Vector3.new(-3,2,5), Vector3.new(2,-2.5, 0))
  end

  def test_initalize
    assert_equal(0, @box_default.min_point.x)
    assert_equal(0, @box_default.min_point.y)
    assert_equal(0, @box_default.min_point.z)
    assert_equal(1, @box_default.max_point.x)
    assert_equal(1, @box_default.max_point.y)
    assert_equal(1, @box_default.max_point.z)

    assert_equal(-3.0, @box.min_point.x)
    assert_equal(-2.5, @box.min_point.y)
    assert_equal(0.0 , @box.min_point.z)
    assert_equal(2.0 , @box.max_point.x)
    assert_equal(2.0 , @box.max_point.y)
    assert_equal(5.0 , @box.max_point.z)

    assert_equal(Geom.default_tolerance, @box_default.tolerance)

    assert_raises ArgumentError do
      invalidResult = Box.new(nil)
    end
    assert_raises ArgumentError do
      invalidResult = Box.new(Vector3.new(), 4.0)
    end
  end

  def test_equal
    shallow_copied = @box
    assert( shallow_copied == @box )
    assert( shallow_copied.equal?( @box ) )

    deep_copied = Box.new(Vector3.new(-3,2,5), Vector3.new(2,-2.5, 0))
    assert( deep_copied == @box )
    assert( !deep_copied.equal?( @box ) )

    assert( @box != 5 )
  end

  def test_add
    added_box = @box_default + Vector3.new(-2, 0.5, 3)
    assert_equal(Vector3.new(-2,0,0), added_box.min_point)
    assert_equal(Vector3.new(1,1,3) , added_box.max_point)

    added_box = @box_default + Box.new( Vector3.new(-2,0.5, 3), Vector3.new(4, 0, 2.0))
    assert_equal(Vector3.new(-2,0,0), added_box.min_point)
    assert_equal(Vector3.new(4,1,3) , added_box.max_point)

    point_ary = [Vector3.new(1,4,9), Vector3.new(4,-2,4), Vector3.new(2,-5,0)]
    added_box = @box + point_ary
    assert_equal(Vector3.new(-3,-5, 0), added_box.min_point)
    assert_equal(Vector3.new( 4, 4, 9), added_box.max_point)

    assert_raises ArgumentError do
      invalidResult = @box + 4
    end
  end

  def test_center
    assert_equal( Vector3.new(0.5, 0.5, 0.5), @box_default.center)
    assert_equal( Vector3.new(-0.5,-0.25,2.5), @box.center)
  end

  def test_length
    width, height, depth = @box_default.length
    assert_in_delta( 1, width , @box_default.tolerance)
    assert_in_delta( 1, height, @box_default.tolerance)
    assert_in_delta( 1, depth , @box_default.tolerance)

    width, height, depth = @box.length
    assert_in_delta( 5.0, width , @box.tolerance)
    assert_in_delta( 4.5, height, @box.tolerance)
    assert_in_delta( 5.0, depth , @box.tolerance)
  end

  def test_volume
    assert_in_delta( 1.0, @box_default.volume, @box_default.tolerance )
    assert_in_delta( 112.5, @box.volume, @box.tolerance )
  end
end
