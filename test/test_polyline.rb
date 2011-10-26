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

  def test_equals
    shallow_copied = @polyline_open
    assert(@polyline_open.equal?(shallow_copied))
    assert(@polyline_open == shallow_copied)
    assert(@polyline_open != nil)
    assert(@polyline_open != "string")

    assert(@polyline_open != @polyline_closed)

    polyline_new_open = Polyline.new(@vertices, true)
    assert(!@polyline_open.equal?(polyline_new_open))
    assert(@polyline_open == polyline_new_open)
    assert_equal(@polyline_open, polyline_new_open)

    new_vertices = @vertices.clone
    new_vertices.push( Vector3.new(3,4,5))
    polyline_new_open = Polyline.new(new_vertices, true)
    assert(polyline_new_open != @polyline_open)
    assert(@polyline_open != polyline_new_open)
  end

  def test_clone
    shallow_copied = @polyline_open
    vert_cnt = @polyline_open.vertices.size
    shallow_copied.vertices[vert_cnt - 1].x = 20
    assert(@polyline_open == shallow_copied)
    assert(@polyline_open.equal?(shallow_copied))
    assert_equal(20, @polyline_open.vertices[vert_cnt - 1].x)
    assert_equal(20, shallow_copied.vertices[vert_cnt - 1].x)

    cloned = @polyline_open.clone
    assert(@polyline_open == cloned)
    assert(!@polyline_open.equal?(cloned))

    cloned.vertices[vert_cnt - 1].x = -20
    assert_equal(-20, cloned.vertices[vert_cnt - 1].x)
    assert_equal(20, @polyline_open.vertices[vert_cnt - 1].x) # original never changed in editing cloned one.

    cloned.is_open = false
    assert_equal(false, cloned.is_open)
    assert_equal(true,  @polyline_open.is_open)
  end

  def test_to_s
    assert_equal("Polyline[[1, 0, 0], [2.0, 0, 0], [3, 1, 0], [2, 2, 1], [1, 2, 0], [0, 1, 0]] open",
           @polyline_open.to_s);
    assert_equal("Polyline[[1, 0, 0], [2.0, 0, 0], [3, 1, 0], [2, 2, 1], [1, 2, 0], [0, 1, 0]] closed",
           @polyline_closed.to_s);
  end

  def test_box
    assert_equal(Vector3.new(0,0,0), @polyline_open.box.min_point)
    assert_equal(Vector3.new(3,2,1), @polyline_open.box.max_point)
    assert_equal(Vector3.new(0,0,0), @polyline_closed.box.min_point)
    assert_equal(Vector3.new(3,2,1), @polyline_closed.box.max_point)
  end

  def test_center
    assert_equal(Vector3.new(1.5, 1.0, 1.0/6.0), @polyline_open.center)
    assert_equal(Vector3.new(1.5, 1.0, 1.0/6.0), @polyline_closed.center)
  end
end
