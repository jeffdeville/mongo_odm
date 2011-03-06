# encoding: utf-8
module MongoODM
  module Document
    module Validations
      class UniquenessValidator < ActiveModel::EachValidator
        def setup(klass)
          @klass = klass
        end

        def validate_each(document, attribute, value)
          criteria = @klass.find({ attribute => search_value(value) })
          unless document.new_record?
            criteria = criteria._merge_criteria({ :_id => { '$ne' => document.send(:id) } }, {})
          end

          Array.wrap(options[:scope]).each do |item|
            criteria = criteria._merge_criteria({ item => document.read_attribute(item) }, {})
          end

          unless criteria.next_document.nil?
            document.errors.add(attribute, :taken, options.except(:case_sensitive, :scope) \
                           .merge(:value => value))
          end
        end

      protected

        def search_value(value)
          if options[:case_sensitive] == false
            Regexp.new("^#{Regexp.escape(value.to_s)}$", Regexp::IGNORECASE)
          else
            value
          end
        end
      end

      module ClassMethods
        def validates_uniqueness_of(*attr_names)
          validates_with UniquenessValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
