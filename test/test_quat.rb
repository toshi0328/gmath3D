$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class QuatTestCase < MiniTest::Unit::TestCase
  def setup
    @quat_default = Quat.new()
    @quat1 = Quat.new(2.0, 3.0, 4.0, 1.0)
    @quat2 = Quat.new(6.0, 7.0, 8.0, 5.0)
  end

  def test_initalize
    assert_equal(0, @quat_default.x)
    assert_equal(0, @quat_default.y)
    assert_equal(0, @quat_default.z)
    assert_equal(0, @quat_default.w)

    assert_equal(2.0, @quat1.x)
    assert_equal(3.0, @quat1.y)
    assert_equal(4.0, @quat1.z)
    assert_equal(1.0, @quat1.w)

    assert_raises ArgumentError do
      invalidResult = Quat.new( "hoge" )
    end
  end

  def test_from_axis
    axis = Vector3.new(1.0, 0.0, 0.0)
    rad = 30.0*Math::PI / 180
    rot_quat = Quat.from_axis(axis, rad)
    assert_equal( Math.cos(rad/2.0), rot_quat.w)
    assert_equal( Math.sin(rad/2.0), rot_quat.x)
    assert_equal( 0.0, rot_quat.y)
    assert_equal( 0.0, rot_quat.z)
  end

  def test_from_matrix
    axis = Vector3.new(1,2,4).normalize()
    angle = 46*Math::PI/180
    mat = Matrix.from_axis(axis, angle)
    quat_expected = Quat.from_axis(axis, angle)
    quat_actual   = Quat.from_matrix(mat)
    assert_equal(quat_expected, quat_actual)
  end

  def test_to_s
    assert_equal("Quat[2.0, 3.0, 4.0, 1.0]", @quat1.to_s)
  end

  def test_assign_value
    assert_equal(2.0, @quat1.x)
    assert_equal(3.0, @quat1.y)
    assert_equal(4.0, @quat1.z)
    assert_equal(1.0, @quat1.w)

    @quat1.x = 2.0
    @quat1.y *= 2.0
    @quat1.z -= 3.0
    @quat1.w /= 2.0

    assert_equal(2.0, @quat1.x)
    assert_equal(6.0, @quat1.y)
    assert_equal(1.0, @quat1.z)
    assert_equal(0.5, @quat1.w)
  end

  def test_equals
    assert(!(@quat_default == @quat1))
    assert(@quat_default != @quat1)

    assert(@quat1 == @quat1)

    quat = Quat.new(2,3,4,1)
    assert(@quat1 == quat)

    #invlid value comparison
    assert(@quat1 != "string")
    assert(@quat1 != -4)
  end

  def test_conjugate
    quat1_conjugate = @quat1.conjugate()
    quat2_conjugate = @quat2.conjugate()

    assert_equal(-2.0, quat1_conjugate.x)
    assert_equal(-3.0, quat1_conjugate.y)
    assert_equal(-4.0, quat1_conjugate.z)
    assert_equal( 1.0, quat1_conjugate.w)
    assert_equal(-6.0, quat2_conjugate.x)
    assert_equal(-7.0, quat2_conjugate.y)
    assert_equal(-8.0, quat2_conjugate.z)
    assert_equal( 5.0, quat2_conjugate.w)
  end

  def test_add
    # implemented, but how to validate?
  end

  def test_add_invalid_value
    assert_raises ArgumentError do
      invalidResult = @quat1 + 5
    end
    assert_raises ArgumentError do
      invalidResult = @quat1 + nil
    end
  end

  def test_multiply
    multiply = @quat1 * @quat2
    assert_equal(-60, multiply.w)
    assert_equal( 12, multiply.x)
    assert_equal( 30, multiply.y)
    assert_equal( 24, multiply.z)

    @quat1 *= @quat2
    assert_equal(-60, @quat1.w)
    assert_equal( 12, @quat1.x)
    assert_equal( 30, @quat1.y)
    assert_equal( 24, @quat1.z)
  end

  def test_multiply_invalid_value
    assert_raises ArgumentError do
      invalidResult = @quat1 * 3
    end
    assert_raises ArgumentError do
      invalidResult = @quat2 * nil
    end
  end

end
