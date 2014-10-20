require 'spike/relation'

module Spike
  module Orm
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :current_scope
        delegate :find, :where, to: :all
        delegate :create, to: :all
      end
    end

    module ClassMethods
      def all
        current_scope || Relation.new(self)
      end

      def scope(name, code)
        self.class.send :define_method, name, code
      end

      def uri_template
        File.join model_name.plural, ':id'
      end

    end

    def persisted?
      id?
    end

    def save
      if persisted?
        self.class.put Path.new(self.class.uri_template, id: id), to_params
      else
        self.class.post Path.new(self.class.uri_template), to_params
      end
    end

    def to_params
      { self.class.model_name.param_key => attributes }
    end
  end
end