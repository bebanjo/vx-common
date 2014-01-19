module Vx
  module SCM

    class Git

      class GitSSH

        include Common::Helper::Shell

        attr_reader :deploy_key

        def initialize(deploy_key)
          @deploy_key = deploy_key
        end

        def open
          begin
            yield create
          ensure
            destroy
          end
        end

        def create
          key_location
          location
        end

        def destroy
          key_location.unlink if key_location
          location.unlink
          @location     = nil
          @key_location = nil
        end

        def location
          @location ||= write_tmp_file 'git', self.class.template(key_location && key_location.path), 0700
        end

        def key_location
          if deploy_key
            @key_location ||= write_tmp_file 'key', deploy_key, 0600
          end
        end

        class << self
          def template(key_location)
            key = key_location ? "-i #{key_location}" : ""
            out = ['#!/bin/sh']
            out << "exec /usr/bin/ssh -A -o LogLevel=quiet -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null #{key} $@"
            out.join "\n"
          end
        end

      end
    end
  end
end
