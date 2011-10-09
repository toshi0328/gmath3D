$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helper'

include GMath3D

MiniTest::Unit.autorun

class GeomTestCase < MiniTest::Unit::TestCase
  def test_tolerance
    default_tolerance = Geom.default_tolerance
    geomObject = Geom.new
    assert_equal(default_tolerance, geomObject.tolerance)
    geomObject.tolerance = 1e-8
    assert_equal(1e-8, geomObject.tolerance)
    assert_equal(default_tolerance, Geom.default_tolerance)
  end
end
