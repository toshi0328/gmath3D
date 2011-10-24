$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class PolylineTestCase < MiniTest::Unit::TestCase
  def setup
    @vertices = Array.new(6)
    @vertices[0] = Vector3.new(1,0,0)
    @vertices[1] = Vector3.new(2.0,0,0)
    @vertices[2] = Vector3.new(3,1,0)
    @vertices[3] = Vector3.new(2,2,1)
    @vertices[4] = Vector3.new(1,2,0)
    @vertices[5] = Vector3.new(0,1,0)
    @polyline_open = Polyline.new(@vertices, true)
    @polyline_closed = Polyline.new(@vertices, false)
  end

  def test_initialize
    idx = 0
    @vertices.each do |vertex|
      assert_equal(@polyline_open.vertices[idx], vertex)
      assert_equal(@polyline_closed.vertices[idx], vertex)
      idx += 1
    end
    assert_equal( true,  @polyline_open.is_open )
    assert_equal( false, @polyline_closed.is_open )
  end

  def test_to_s
    assert_equal("Polyline[[1, 0, 0], [2.0, 0, 0], [3, 1, 0], [2, 2, 1], [1, 2, 0], [0, 1, 0]] open",
           @polyline_open.to_s);
    assert_equal("Polyline[[1, 0, 0], [2.0, 0, 0], [3, 1, 0], [2, 2, 1], [1, 2, 0], [0, 1, 0]] closed",
           @polyline_closed.to_s);
  end

  def test_center
    assert_equal(Vector3.new(1.5, 1.0, 1.0/6.0), @polyline_open.center)
    assert_equal(Vector3.new(1.5, 1.0, 1.0/6.0), @polyline_closed.center)
  end
end
