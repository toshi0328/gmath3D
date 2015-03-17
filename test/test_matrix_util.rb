# -*- coding: cp932 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

Minitest.autorun

class MatrixTestCase < Minitest::Test
  def setup
    @mat_default = Matrix.zero(3)
    @mat = Matrix[[1,2,3],[4,5,6],[7,8,9]]
  end

  def test_initalize
    @mat_default.each do |cell|
      assert_equal(0, cell)
    end

    i = 1
    @mat.each do |cell|
      assert_equal(i, cell)
      i+=1
    end
  end

  def test_to_s
    assert_equal("Matrix[[0, 0, 0], [0, 0, 0], [0, 0, 0]]", @mat_default.to_s)
    assert_equal("Matrix[[1, 2, 3], [4, 5, 6], [7, 8, 9]]", @mat.to_s)
  end

  def test_multiply
    mat = Matrix[[3,2,1],[-4,2,1],[3,4,1]]
    vec = Matrix.column_vector([2,3,4])
    ans = mat*vec

    assert_equal(ans[0,0], 16)
    assert_equal(ans[1,0], 2 )
    assert_equal(ans[2,0], 22)

    vec2 = Vector3.new(2,3,4)
    ans2 = mat*(vec2)
    assert_equal(Vector3.new(16,2,22), ans2)
  end

  def test_from_axis
    local_point = Vector3.new(1,0,1)
    angle = 45*Math::PI/180
    local_cod_x = Vector3.new(Math.cos(angle), Math.sin(angle),0)
    x_vec = Vector3.new(1,0,0)
    diff_angle = x_vec.angle(local_cod_x)
    axis = x_vec.cross(local_cod_x).normalize()

    rotate_matrix = Matrix.from_axis(axis, diff_angle)
    rotated_point = rotate_matrix.inv * local_point
    assert_equal(Vector3.new(Math.sqrt(2)/2, Math.sqrt(2)/2, 1), rotated_point)

    local_point = Vector3.new(1,0,0)
    local_cod_x = Vector3.new(1,1,1).normalize()
    diff_angle = x_vec.angle(local_cod_x)
    axis = x_vec.cross(local_cod_x).normalize()

    assert_equal(Math::PI/2, local_cod_x.angle(axis))
    rotate_matrix = Matrix.from_axis(axis, diff_angle)
    rotated_point = rotate_matrix.inv()*local_point

    assert_in_delta(rotated_point.x, rotated_point.y, rotated_point.tolerance)
    assert_in_delta(rotated_point.x, rotated_point.z, rotated_point.tolerance)
  end

  def test_from_quat
    axis = Vector3.new(1,2,4).normalize()
    angle = 46*Math::PI/180
    quat = Quat.from_axis(axis, angle)
    mat_expected = Matrix.from_axis(axis, angle)
    mat_actual = Matrix.from_quat(quat)

    [0,1,2].each do |i|
      [0,1,2].each do |j|
        assert_in_delta( mat_expected[i,j], mat_actual[i,j], 1e-8)
      end
    end
  end
end
