require 'vx/common/rack/builder'

module Vx
  module Common
    module Helper
      module Middlewares

        def self.included(base)
          base.send :extend, ClassMethods
        end

        def run_middlewares(*args, &block)
          self.class.builder.to_app(block).call(*args)
        end
        private :run_middlewares

        module ClassMethods

          attr_reader :builder

          def middlewares(&block)
            @builder = Vx::Common::Rack::Builder.new(&block)
          end

        end

      end
    end
  end
end
