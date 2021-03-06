require 'dm-core'
require 'dm-types/support/flags'

module DataMapper
  class Property
    class Enum < Object
      include Flags

      load_as ::Object
      dump_as ::Integer

      def initialize(model, name, options = {})
        @flag_map = {}

        flags = options.fetch(:flags, self.class.flags)
        flags.each_with_index do |flag, i|
          @flag_map[i + 1] = flag
        end

        if self.class.accepted_options.include?(:set) && !options.include?(:set)
          options[:set] = @flag_map.values_at(*@flag_map.keys.sort)
        end

        super
      end

      def load(value)
        flag_map[value]
      end

      def dump(value)
        case value
        when ::Array then value.collect { |v| dump(v) }
        when ::Integer then flag_map.has_key?(value) ? value : nil
        else              flag_map.invert[value]
        end
      end

      def typecast(value)
        return if value.nil?
        # Attempt to typecast using the class of the first item in the map.
        case flag_map[1]
        when ::Symbol then value.to_sym
        when ::String then value.to_s
        when ::Fixnum then value.to_i
        else               value
        end
      end

    end # class Enum
  end # class Property
end # module DataMapper
