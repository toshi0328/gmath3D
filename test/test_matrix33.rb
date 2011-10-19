$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class Matrix33TestCase < MiniTest::Unit::TestCase
  def setup
    @mat_default = Matrix33.zero()
    @mat = Matrix33[[1,2,3],[4,5,6],[7,8,9]]
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
    assert_equal("Matrix[[1, 2, 3], [4, 5, 6], [7, 8, 9]]", @mat.to_s)
  end

  def test_constructor
    diagonal = Matrix33.diagonal(2,6)
    assert_equal(3, diagonal.row_size)
    assert_equal(3, diagonal.column_size)
    assert_equal(2, diagonal[0,0])
    assert_equal(6, diagonal[1,1])
    assert_equal(0, diagonal[2,2])
    [0,1,2].each do | i |
      [0,1,2].each do | j |
        assert_equal(0, diagonal[i,j]) if (i != j)
      end
    end

    scalar   = Matrix33.scalar(4)
    assert_equal(3, scalar.row_size)
    assert_equal(3, scalar.column_size)
    [0,1,2].each do | i |
      [0,1,2].each do | j |
        assert_equal(4, scalar[i,j]) if (i == j)
        assert_equal(0, scalar[i,j]) if (i != j)
      end
    end

    scalar_one = Matrix33.scalar(1)
    identity = Matrix33.identity()
    unit     = Matrix33.unit()
    i        = Matrix33.I()

    assert(identity == scalar_one)
    assert(identity == unit)
    assert(identity == i)

    row_vector = Matrix33.row_vector([2,3,4])
    col_vector = Matrix33.column_vector([5,6,7])
    assert_equal(nil, row_vector)
    assert_equal(nil, col_vector)
  end

end
