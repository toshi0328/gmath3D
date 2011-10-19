# -*- coding: cp932 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class MatrixTestCase < MiniTest::Unit::TestCase
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

  def test_rotate
    local_point = Vector3.new(1,0,1)
    angle = 45*Math::PI/180
    local_cod_x = Vector3.new(Math.cos(angle), Math.sin(angle),0)

    x_vec = Vector3.new(1,0,0)
    diff_angle = x_vec.angle(local_cod_x)
    axis = x_vec.cross(local_cod_x)
    axis = axis.normalize()

    rotate_matrix = Matrix.from_axis(axis, diff_angle)
    rotated_point = rotate_matrix.inv * local_point
    assert_equal(Vector3.new(Math.sqrt(2)/2, Math.sqrt(2)/2, 1), rotated_point)

=begin

	//////////////////////
	localPoint = gcnew RMath::CPoint3D(1.0,0.0,0.0) ;
	// ローカル座標の傾き
	localCodX = gcnew RMath::CVector3D(1.0, 1.0, 1.0) ;
	localCodX->Normalize();

	// 任意軸周りの回転行列を作る
	diffAngle = Xvec->GetAngle(localCodX);
	double diffAngleDeg = diffAngle * 180.0 / System::Math::PI ;

	axis = Xvec->Cross(localCodX) ;
	axis->Normalize() ;

// ちょっと確認
	double angleBetweenAxisAndLocalX = localCodX->GetAngle(axis);
	TEST_ASSERT_EQUALS_DOUBLE( System::Math::PI/2.0 , angleBetweenAxisAndLocalX, s_epsilon ) ;

	roteteMatrix = gcnew RMath::CMatrix33(axis, diffAngle) ; // →基準点をローカル点に転写する行列

	// ローカル点を回転する
	rotetedPoint = roteteMatrix->GetInverse() * (localPoint) ;

	TEST_ASSERT_EQUALS_DOUBLE( rotetedPoint->X , rotetedPoint->Y, s_epsilon ) ;
	TEST_ASSERT_EQUALS_DOUBLE( rotetedPoint->X , rotetedPoint->Z, s_epsilon ) ;
=end
  end
end
