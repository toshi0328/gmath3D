require 'gmath3D'
require 'matrix'

class Matrix
  def self.from_axis(axis, angle)
    Util.check_arg_type(Vector3, axis)
    Util.check_arg_type(Numeric, angle)
  end

  alias_method :multi_inner, :*  # hold original multiply processing
  def multi_new(rhs)
    if(rhs.kind_of?(Vector3))
        ans = self*(rhs.to_column_vector)
      return Vector3.new(ans[0,0], ans[1,0], ans[2,0])
    end
    multi_inner(rhs)
  end
  alias_method :*, :multi_new   # overwrite new multiply processing


end
