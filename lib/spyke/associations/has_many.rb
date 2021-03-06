module Spyke
  module Associations
    class HasMany < Association
      def initialize(*args)
        super
        @options.reverse_merge!(uri: "/#{parent.class.model_name.plural}/:#{foreign_key}/#{klass.model_name.plural}/(:id)")
        @params[foreign_key] = parent.id
      end

      def load
        self
      end

      def assign_nested_attributes(incoming)
        incoming = incoming.values if incoming.is_a?(Hash)
        combined_attributes = combine_with_existing(incoming)
        clear_existing!
        combined_attributes.each do |attributes|
          build(attributes)
        end
      end

      private

        def combine_with_existing(incoming)
          return incoming unless primary_keys_present_in_existing?
          combined = embedded_params + incoming
          group_by_primary_key(combined).flat_map do |primary_key, hashes|
            if primary_key.present?
              hashes.reduce(:merge)
            else
              hashes
            end
          end
        end

        def group_by_primary_key(array)
          array.group_by { |h| h.with_indifferent_access[:id].to_s }
        end

        def primary_keys_present_in_existing?
          embedded_params && embedded_params.any? { |attr| attr.has_key?('id') }
        end

        def clear_existing!
          update_parent []
        end

        def add_to_parent(record)
          parent.attributes[name] ||= []
          parent.attributes[name] << record
          record
        end
    end
  end
end
