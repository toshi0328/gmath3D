require 'helper'

include GMath3D

class Vector3TestCase < Minitest::Test
  def setup
    @vector_init_zero = Vector3.new()
    @vector = Vector3.new(1, 2.0, 3.0)
  end

  def test_initalize
    assert_equal(0, @vector_init_zero.x)
    assert_equal(0, @vector_init_zero.y)
    assert_equal(0, @vector_init_zero.z)

    assert_equal(1.0, @vector.x)
    assert_equal(2.0, @vector.y)
    assert_equal(3.0, @vector.z)

    assert_equal(Geom.default_tolerance, @vector.tolerance)

    assert_raises ArgumentError do
      invalidResult = Vector3.new( "hoge" )
    end
  end

  def test_to_s
    assert_equal("Vector3[1, 2.0, 3.0]", @vector.to_s)
  end

  def test_to_element_s
    assert_equal("[1, 2.0, 3.0]", @vector.to_element_s)
  end

  def test_to_ary
    assert_equal(Array, @vector_init_zero.to_ary.class)
    assert_equal(3, @vector_init_zero.to_ary.size)
    assert_equal(@vector_init_zero.x, @vector_init_zero.to_ary[0])
    assert_equal(@vector_init_zero.y, @vector_init_zero.to_ary[1])
    assert_equal(@vector_init_zero.z, @vector_init_zero.to_ary[2])

    assert_equal(Array, @vector.to_ary.class)
    assert_equal(@vector.x, @vector.to_ary[0])
    assert_equal(@vector.y, @vector.to_ary[1])
    assert_equal(@vector.z, @vector.to_ary[2])
    assert_equal(3, @vector.to_ary.size)
  end

  def test_assign_value
    assert_equal(1.0, @vector.x)
    assert_equal(2.0, @vector.y)
    assert_equal(3.0, @vector.z)

    @vector.x = 2.0
    @vector.y *= 2.0
    @vector.z -= 3.0

    assert_equal(2.0, @vector.x)
    assert_equal(4.0, @vector.y)
    assert_equal(0.0, @vector.z)
  end

  def test_assign_invalid_value
    #TODO unimplemented!
    @vector.x = "this is a pen"
  end

  def test_clone
    vec1 = Vector3.new(1,2,3)
    vec1_shallow_copy = vec1
    vec1_shallow_copy.x = 4
    assert_equal( 4, vec1.x )
    assert_equal( 2, vec1.y )
    assert_equal( 3, vec1.z )

    vec1_deep_copy = vec1.clone
    vec1_deep_copy.x = 6
    assert_equal( 4, vec1.x )
    assert_equal( 6, vec1_deep_copy.x )

    vec_ary = [Vector3.new(1,2,3), Vector3.new(4,5,6)]
    vec_ary_shallow = vec_ary
    vec_ary_shallow[0].x = 4
    vec_ary_shallow[1] = Vector3.new(7,8,9)
    vec_ary_shallow.push(Vector3.new(10,11,12))
    assert_equal(4, vec_ary_shallow[0].x)
    assert_equal(Vector3.new(7,8,9), vec_ary_shallow[1])
    assert_equal(3, vec_ary_shallow.size)
    assert_equal(4, vec_ary[0].x)
    assert_equal(Vector3.new(7,8,9), vec_ary[1])
    assert_equal(3, vec_ary.size)

    vec_ary = [Vector3.new(1,2,3), Vector3.new(4,5,6)]
    vec_ary_deep = vec_ary.clone
    vec_ary_deep[0].x = 4
    vec_ary_deep[1] = Vector3.new(7,8,9)
    vec_ary_deep.push(Vector3.new(10,11,12))
    assert_equal(4, vec_ary_deep[0].x)
    assert_equal(Vector3.new(7,8,9), vec_ary_deep[1])
    assert_equal(3, vec_ary_deep.size)

    # Array.clone does not call element.clone
#    assert_equal(1, vec_ary[0].x)
    assert_equal(4, vec_ary[0].x)
    assert_equal(Vector3.new(4,5,6), vec_ary[1])
    assert_equal(2, vec_ary.size)
  end

  def test_equals
    assert(!(@vector_init_zero == @vector))
    assert(@vector_init_zero != @vector)

    assert(@vector == @vector)
    assert(@vector.eql?(@vector))

    vector = Vector3.new(1,2,3)
    assert(@vector == vector)
    assert(@vector.eql?(vector))

    # Floating error check
    floatingError = Geom.default_tolerance*0.1
    vector = Vector3.new(1.0 - floatingError, 2.0 + floatingError, 3.0)
    assert(@vector == vector)

    floatingError2 = Geom.default_tolerance*10.0
    vector = Vector3.new(1.0 - floatingError2, 2.0 + floatingError2, 3.0)
    assert(@vector != vector)

    assert_equal(Vector3.new(1,2,3), Vector3.new(1.0,2.0,3.0))

    #invlid value comparison
    assert(@vector != "string")
    assert(@vector != -4)
  end

  def test_equ_hash
    # in case use Vector3 as Key of hash...
    # Vector3#eql? and Vector3#hash should be implement
    hash = Hash.new()
    vec = Vector3.new(1,2,3)
    hash[vec] = 1
    assert_equal(1, hash.keys.count)
    assert_equal(1, hash[vec])

    hash[vec] = 2
    assert_equal(1, hash.keys.count)
    assert_equal(2, hash[vec])

    hash[Vector3.new(3,2,1)] = 3
    assert_equal(2, hash.keys.count)
    assert_equal(2, hash[vec])

    hash[@vector] = 3
    assert_equal(2, hash.keys.count)
    assert_equal(3, hash[vec])
  end

  def test_box
    box1 = @vector.box
    box2 = Vector3.new().box
    assert_equal(Vector3.new(1,2,3), box1.min_point)
    assert_equal(Vector3.new(1,2,3), box1.max_point)
    assert_equal(Vector3.new(), box2.min_point)
    assert_equal(Vector3.new(), box2.max_point)
  end

  def test_add
    vector = Vector3.new(4,5,6)
    addedVector = vector + @vector

    assert_equal(5.0, addedVector.x)
    assert_equal(7.0, addedVector.y)
    assert_equal(9.0, addedVector.z)

    addedVector = @vector + vector

    assert_equal(5.0, addedVector.x)
    assert_equal(7.0, addedVector.y)
    assert_equal(9.0, addedVector.z)
  end
  def test_add_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector + 5
    end
    assert_raises ArgumentError do
      invalidResult = @vector + nil
    end
  end

  def test_subtract
    vector = Vector3.new(4,5,6)
    subtractedVector = vector - @vector

    assert_equal(3.0, subtractedVector.x)
    assert_equal(3.0, subtractedVector.y)
    assert_equal(3.0, subtractedVector.z)

    subtractedVector = @vector - vector

    assert_equal(-3.0, subtractedVector.x)
    assert_equal(-3.0, subtractedVector.y)
    assert_equal(-3.0, subtractedVector.z)
  end
  def test_subtract_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector - 5
    end
    assert_raises ArgumentError do
      invalidResult = @vector - nil
    end
  end

  def test_multiply
    multipliedVector = @vector * 5

    assert_equal( 5.0, multipliedVector.x)
    assert_equal(10.0, multipliedVector.y)
    assert_equal(15.0, multipliedVector.z)

    multipliedVector = @vector * -3.0

    assert_equal(-3.0, multipliedVector.x)
    assert_equal(-6.0, multipliedVector.y)
    assert_equal(-9.0, multipliedVector.z)
  end
  def test_multiply_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector * @vector
    end
    assert_raises ArgumentError do
      invalidResult = @vector * nil
    end
  end

  def test_divide
    dividedVector = @vector / 5

    assert_equal(1.0/5.0, dividedVector.x)
    assert_equal(2.0/5.0, dividedVector.y)
    assert_equal(3.0/5.0, dividedVector.z)

    dividedVector = @vector / -3.0

    assert_equal(-1.0/3.0, dividedVector.x)
    assert_equal(-2.0/3.0, dividedVector.y)
    assert_equal(-3.0/3.0, dividedVector.z)
  end
  def test_divide_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector / @vector
    end
    assert_raises ArgumentError do
      invalidResult = @vector / nil
    end
  end

  def test_dot
    vector = Vector3.new(2.0, 4.0, 6.0)
    innerProduct = @vector.dot(vector)
    assert_in_delta( 1.0*2.0 + 2.0*4.0 + 3.0*6.0, innerProduct, @vector.tolerance)

    innerProduct = @vector.dot(@vector_init_zero)
    assert_in_delta( 0.0, innerProduct, @vector.tolerance)
  end
  def test_dot_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector.dot(5.0)
    end
    assert_raises ArgumentError do
      invalidResult = @vector.dot(nil)
    end
  end

  def test_cross
    outerProduct = Vector3.new(1.0,0.0,0.0).cross(Vector3.new(0.0,1.0,0.0))
    assert(outerProduct == Vector3.new(0.0,0.0,1.0))

    vector = Vector3.new(1.0, 1.0, 4.0)
    outerProduct = @vector.cross(vector)
    assert_in_delta(2.0*4.0 - 3.0*1.0, outerProduct.x, @vector.tolerance)
    assert_in_delta(3.0*1.0 - 1.0*4.0, outerProduct.y, @vector.tolerance)
    assert_in_delta(1.0*1.0 - 2.0*1.0, outerProduct.z, @vector.tolerance)

    outerProduct = @vector.cross(@vector_init_zero)
    assert_in_delta( 0.0, outerProduct.x, @vector.tolerance)
    assert_in_delta( 0.0, outerProduct.y, @vector.tolerance)
    assert_in_delta( 0.0, outerProduct.z, @vector.tolerance)
  end
  def test_cross_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector.cross(5.0)
    end
    assert_raises ArgumentError do
      invalidResult = @vector.cross(nil)
    end
  end

  def test_length
    assert_in_delta(0.0, @vector_init_zero.length, @vector_init_zero.tolerance)
    assert_in_delta( Math::sqrt(1.0*1.0+2.0*2.0+3.0*3.0), @vector.length, @vector.tolerance)
    vector = Vector3.new(3.0, 4.0, 0.0)
    assert_in_delta( 5.0, vector.length, @vector.tolerance)
  end

  def test_distance
    point1 = Vector3.new(1.0,  3.0, -5.0)
    point2 = Vector3.new(3.0, -5.5,  2.2)
    vector1to2 = point2 - point1
    assert_in_delta( vector1to2.length, point2.distance(point1), vector1to2.tolerance)
    assert_in_delta( vector1to2.length, point1.distance(point2), vector1to2.tolerance)
    assert_in_delta( 0.0, point1.distance(point1), vector1to2.tolerance)
  end
  def test_distance_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector.distance(5.0)
    end
    assert_raises ArgumentError do
      invalidResult = @vector.distance(nil)
    end
  end

  def test_angle
    vector1 = Vector3.new(  1.0 ,  0.0, 0.0 )
    vector2 = Vector3.new(  1.0 ,  1.0, 0.0 )
    vector3 = Vector3.new( -1.0 ,  1.0, 0.0 )
    vector4 = Vector3.new( -1.0 ,  0.0, 0.0 )
    vector5 = Vector3.new( -1.0 , -1.0, 0.0 )
    vector6 = Vector3.new(  1.0 , -1.0, 0.0 )

    # result should be between 0 and PI.
    assert_in_delta(0.0,vector1.angle(vector1), vector1.tolerance) ;
    assert_in_delta(Math::PI/4.0,vector1.angle(vector2), vector1.tolerance) ;
    assert_in_delta(Math::PI*3.0/4.0, vector1.angle(vector3), vector1.tolerance) ;
    assert_in_delta(Math::PI, vector1.angle(vector4), vector1.tolerance) ;
    assert_in_delta(Math::PI*3.0/4.0, vector1.angle(vector5), vector1.tolerance) ;
    assert_in_delta(Math::PI/4.0, vector1.angle(vector6), vector1.tolerance) ;
  end
  def test_angle_invalid_value
    assert_raises ArgumentError do
      invalidResult = @vector.angle(5.0)
    end
    assert_raises ArgumentError do
      invalidResult = @vector.angle(nil)
    end
  end

  def test_normalize
    normalized = @vector.normalize()
    assert_in_delta(1.0, normalized.length, normalized.tolerance) ;
    assert(normalized.same_direction?(@vector))
  end

  def test_parallel
    vectorZero = Vector3.new( 0.0, 0.0, 0.0) ;
    vector1 = Vector3.new( 1.0, 2.0, 3.0 ) ;
    vector2 = Vector3.new( 1.0, 1.0, 4.0 ) ;
    vector3 = Vector3.new( 2.0, 4.0, 6.0 ) ;
    vector4 = Vector3.new( -1.0, -2.0, -3.0 ) ;
    vector5 = Vector3.new( -3.0, -6.0, -9.0 ) ;

    assert(!vector1.parallel?(vectorZero)) ;
    assert(!vectorZero.parallel?(vector2)) ;
    assert(!vector1.parallel?(vector2)) ;

    assert(vector1.parallel?(vector3)) ;
    assert(vector1.parallel?(vector4)) ;
    assert(vector1.parallel?(vector5)) ;
  end

  def test_same_direction
    vectorZero = Vector3.new( 0.0, 0.0, 0.0) ;
    vector1 = Vector3.new( 1.0, 2.0, 3.0 ) ;
    vector2 = Vector3.new( 1.0, 1.0, 4.0 ) ;
    vector3 = Vector3.new( 2.0, 4.0, 6.0 ) ;
    vector4 = Vector3.new( -1.0, -2.0, -3.0 ) ;
    vector5 = Vector3.new( -3.0, -6.0, -9.0 ) ;

    assert(!vector1.same_direction?(vectorZero)) ;
    assert(!vectorZero.same_direction?(vector2)) ;
    assert(!vector1.same_direction?(vector2)) ;

    assert(vector1.same_direction?(vector3)) ;
    assert(!vector1.same_direction?(vector4)) ;
    assert(!vector1.same_direction?(vector5)) ;
  end

  def test_project
    vector1 = Vector3.new(1.0, 1.0, 0.0)
    vector2 = Vector3.new(0.0, 1.0, 0.0)

    projectedVector, parameter = vector2.project_to(vector1)
    assert(Vector3.new(0.5,0.5,0.0) == projectedVector)
    assert_in_delta(0.5, parameter, projectedVector.tolerance)

    projectedVector, parameter = vector2.project_to(Vector3.new(0.0, 0.0, 0.0))
    assert(Vector3.new() == projectedVector)
    assert_in_delta(0.0, parameter, projectedVector.tolerance)

    vector3 = Vector3.new(5.0, -1.0, 4.0)
    projectedVector, parmeter = vector3.project_to(vector1)
    assert(projectedVector.same_direction?(vector1))
  end

  def test_to_column_vector
    matrix = @vector.to_column_vector
    assert_equal( 3, matrix.row_size )
    assert_equal( 1, matrix.column_size )
    assert_equal( 1, matrix[0,0])
    assert_equal( 2, matrix[1,0])
    assert_equal( 3, matrix[2,0])

    matrix = @vector_init_zero.to_column_vector
    assert_equal( 3, matrix.row_size )
    assert_equal( 1, matrix.column_size )
    assert_equal( 0, matrix[0,0])
    assert_equal( 0, matrix[1,0])
    assert_equal( 0, matrix[2,0])
  end

  def test_arbitrary_orthogonal
    vec1 = Vector3.new( 1.0, 2.0, 3.0 )
    vec2 = Vector3.new( 1.0, 1.0, 4.0 )
    vec3 = Vector3.new( 2.0, 4.0, 6.0 )
    vec4 = Vector3.new( -1.0, -2.0, -3.0 )
    vecx = Vector3.new( 1.0,  0.0,  0.0 )
    vecy = Vector3.new( 0.0, -3.0,  0.0 )
    vecz = Vector3.new( 0.0,  0.0,  5.0 )
    veczero = Vector3.new( 0.0,  0.0,  0.0 )

    vec1_orth = vec1.arbitrary_orthogonal
    vec2_orth = vec2.arbitrary_orthogonal
    vec3_orth = vec3.arbitrary_orthogonal
    vec4_orth = vec4.arbitrary_orthogonal
    vecx_orth = vecx.arbitrary_orthogonal
    vecy_orth = vecy.arbitrary_orthogonal
    vecz_orth = vecz.arbitrary_orthogonal
    veczero_orth = veczero.arbitrary_orthogonal

    assert_in_delta(0.5*Math::PI, vec1.angle(vec1_orth), vec1.tolerance)
    assert_in_delta(0.5*Math::PI, vec2.angle(vec2_orth), vec2.tolerance)
    assert_in_delta(0.5*Math::PI, vec3.angle(vec3_orth), vec3.tolerance)
    assert_in_delta(0.5*Math::PI, vec4.angle(vec4_orth), vec4.tolerance)
    assert_in_delta(0.5*Math::PI, vecx.angle(vecx_orth), vecx.tolerance)
    assert_in_delta(0.5*Math::PI, vecy.angle(vecy_orth), vecy.tolerance)
    assert_in_delta(0.5*Math::PI, vecz.angle(vecz_orth), vecz.tolerance)
    assert_in_delta(0.0, veczero_orth.x, veczero.tolerance)
    assert_in_delta(0.0, veczero_orth.y, veczero.tolerance)
    assert_in_delta(0.0, veczero_orth.z, veczero.tolerance)
  end
end
