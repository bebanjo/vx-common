require 'vx/common/amqp'
require 'vx/common/error_notifier'

module Vx
  module Common

    module AMQP
      extend self

      def setup(logger, options = {})
        Vx::Common::AMQP.configure do |c|

          c.before_subscribe do |e|
            logger.warn "[#{e[:name]}] subsribing #{e[:exchange].name}"
          end

          c.after_subscribe do |e|
            logger.warn "[#{e[:name]}] shutdown"
          end

          c.before_recieve do |e|
            logger.warn "[#{e[:name]}] payload recieved #{e[:payload].inspect[0..60]}"
          end

          c.after_recieve do |e|
            logger.warn "[#{e[:name]}] commit message"
          end

          c.on_error do |e|
            Vx::Common::ErrorNotifier.notify(e)
          end

          c.content_type = 'application/x-protobuf'
          c.logger       = nil
          c.url          = options[:url]

        end
      end
    end
  end
end
