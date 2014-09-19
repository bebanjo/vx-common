require 'shellwords'

module Vx
  module Common
    module Helper
      module TraceShCommand
        def trace_sh_command(cmd, options = {})
          travis_cmd(cmd, options)
        end

        private

        def travis_cmd(cmd, options = {})
          str = ""

          str = "travis_fold start #{options[:fold]}\n" if options[:fold]
          cmd << " --retry" if options[:retry]
          cmd << " --timing" if options[:timing]
          cmd << " --assert" if options[:assert]
          cmd = "travis_cmd #{cmd}" if options[:retry] || options[:timing] || options[:assert]
          str << base_trace_sh_command(cmd, options)

          str << "\ntravis_fold end #{options[:fold]}\n" if options[:fold]

          str
        end

        # FIXME this is going to print the travis arguments too, be can include the echo option in the travis
        # command if we want (--echo)
        def base_trace_sh_command(cmd, options)
          trace = options[:trace] || cmd
          "echo #{Shellwords.escape "$ #{trace}"}\n#{cmd}"
        end
      end

    end
  end
end
