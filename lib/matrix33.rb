require 'gmath3D'
require 'matrix'

module GMath3D
  class Matrix33 < Matrix
    @@element_count = 3;

    def self.diagonal(v1=0, v2=0, v3=0)
      return super(v1,v2,v3)
    end

    def self.scalar( value = 0 )
      return super( @@element_count, value )
    end

    def self.zero()
      return super( @@element_count )
    end

    def self.identity()
      return super( @@element_count )
    end

    def self.unit()
      return super( @@element_count )
    end

    def self.I()
      return super( @@element_count )
    end

    def self.row_vector(val)
      return nil
    end

    def self.column_vector(val)
      return nil
    end

    def self.from_axis(axis, angle)
    end

  end
end
