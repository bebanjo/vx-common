require 'thread'

module Vx
  module Common
    class OutputBuffer

      attr_reader :interval

      def initialize(interval = 1, &block)
        @interval = interval.to_f
        @buffer   = ""
        @write    = block
        @mutex    = Mutex.new
        @closed   = false

        start_watching
      end

      def << (str)
        closed!

        @mutex.synchronize do
          @buffer << str
        end
      end

      def close
        @closed = true
        @thread.join
      end

      def flush
        closed!
        @mutex.synchronize { write }
      end

      def empty?
        @buffer.size == 0
      end

      class ClosedBuffer < Exception ; end

      private

        def write
          unless empty?
            @write.call @buffer.dup
            @buffer.clear
          end
        end

        def closed!
          raise ClosedBuffer if @closed
        end

        def start_watching
          @thread = Thread.new do
            loop do
              sleep interval

              unless empty?
                @mutex.synchronize { write }
              end

              break if @closed
            end
          end
          @thread.abort_on_exception = true
        end

    end
  end
end
