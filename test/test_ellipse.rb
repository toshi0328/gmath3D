$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

class EllipseTestCase < Minitest::Test
  def test_initialize
  end

  def test_to_s
  end

  def test_equals
=begin
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
    line = FiniteLine.new(Vector3.new(1,0,2), Vector3.new(1,-3.5,2))
    assert_equal("FiniteLine[from[1, 0, 2], to[1, -3.5, 2]]", line.to_s)
=end
  end

  def test_clone
=begin
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
=end
  end


end
