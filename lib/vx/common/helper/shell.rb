require 'pathname'
require 'fileutils'
require 'tempfile'
require 'shellwords'

require 'vx/common/spawn'

module Vx
  module Common
    module Helper

      module Shell

        private

        include Vx::Common::Spawn

        def path(name)
          Pathname.new(name)
        end

        def mkdir(name)
          FileUtils.mkdir_p name.to_s
        end

        def rm(name)
          FileUtils.rm_rf name.to_s
        end

        def recreate(name)
          rm name
          mkdir name
        end

        def write_file(name, content, perm = 0644)
          File.open(name, 'w', perm) do |io|
            io.write content
          end
        end

        def write_tmp_file(name, content, perm = 0600)
          tmp = ::Tempfile.new name
          tmp.write content
          tmp.rewind
          tmp.flush
          tmp.close
          FileUtils.chmod perm, tmp.path
          tmp
        end

        def read_file(name)
          if File.readable?(name)
            File.read name
          end
        end

        def expand_path(path)
          File.expand_path path.to_s
        end

        def bash(*args, &block)
          raise ArgumentError, 'block required' unless block_given?

          options = args.last.is_a?(Hash) ? args.pop : {}
          command = args.first

          cmd = "/usr/bin/env -i HOME=${HOME} bash"

          if file = options.delete(:file)
            cmd << " #{file}"
          else
            cmd << " -c " << Shellwords.escape(command)
          end

          runner = options.delete(:ssh) || self
          runner.send(:spawn, cmd, options, &block)
        end

      end

    end
  end
end
