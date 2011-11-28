$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class UtilTestCase < MiniTest::Unit::TestCase
  def test_check_arg_type
    integerInstance = 1
    floatInstance = 3.1415
    stringInstance = 'string'

   # no exception raise
    Util3D.check_arg_type(Integer, integerInstance)
    Util3D.check_arg_type(Float, floatInstance)
    Util3D.check_arg_type(String, stringInstance)

    # exception raise
    assert_raises ArgumentError do
      Util3D.check_arg_type(Integer, floatInstance)
    end
    assert_raises ArgumentError do
      Util3D.check_arg_type(Integer, stringInstance)
    end
    assert_raises ArgumentError do
      Util3D.check_arg_type(Float, integerInstance)
    end
    assert_raises ArgumentError do
      Util3D.check_arg_type(Float, stringInstance)
    end
    assert_raises ArgumentError do
      Util3D.check_arg_type(String, integerInstance)
    end
    assert_raises ArgumentError do
      Util3D.check_arg_type(String, floatInstance)
    end

    # not raise exception
    arg = {:geom => Vector3.new(), :color => [1,0,0,1]}
    Util3D.check_key_arg(arg, :geom)
    assert_raises ArgumentError do
      Util3D.check_key_arg(arg, :dummy)
    end
  end

  def test_array_methods
    point_ary = Array.new([Vector3.new(2,4,3),Vector3.new(-2,2.5,8),Vector3.new(9,0,-3)])
    assert_equal( Vector3.new(9, 6.5, 8), point_ary.sum)
    assert_equal( Vector3.new(3, 6.5/3, 8/3.0), point_ary.avg)
  end

  def test_matrix_equation_solving
    mat = Matrix[[1,2,3],[4,5,6],[7,8,-9]]
    vec = Matrix.column_vector([26,62,8])
    inv_mat = mat.inverse
    ans = inv_mat*vec
    assert_equal(3, ans.row_size)
    assert_equal(1, ans.column_size)
    assert_equal(3, ans[0,0])
    assert_equal(4, ans[1,0])
    assert_equal(5, ans[2,0])
  end
end
