# from activesupport

require 'logger'

module Vx
  module Common
    module TaggedLogging

      class Formatter < ::Logger::Formatter
        Format = "[%s] %1s : %s\n"

        def call(severity, time, progname, msg)
          Format % [format_datetime(time),
                    severity[0...1],
                    msg2str("#{tags_text}#{msg}")]
        end

        def thread_id
          Thread.current.object_id
        end

        def tagged(*tags)
          new_tags = push_tags(*tags)
          yield self
        ensure
          pop_tags(new_tags.size)
        end

        def push_tags(*tags)
          tags.flatten.reject{|i| i.to_s.strip.empty? }.tap do |new_tags|
            current_tags.concat new_tags
          end
        end

        def pop_tags(size = 1)
          current_tags.pop size
        end

        def clear_tags!
          current_tags.clear
        end

        def current_tags
          Thread.current[:activesupport_tagged_logging_tags] ||= []
        end

        private

          def tags_text
            tags = current_tags
            if tags.any?
              tags.collect { |tag| "[#{tag}] " }.join
            end
          end

      end

      def self.new(logger)
        # Ensure we set a default formatter so we aren't extending nil!
        logger.formatter = Formatter.new
        logger.extend(self)
      end

      %w{ push_tags pop_tags clear_tags! }.each do |m|
        define_method m do
          formatter.send(m)
        end
      end

      def tagged(*tags)
        formatter.tagged(*tags) { yield self }
      end

      def flush
        clear_tags!
        super if defined?(super)
      end

    end
  end
end
