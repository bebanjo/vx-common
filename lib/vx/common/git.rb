require 'ostruct'

module Vx
  module Common

    class Git

      COMMIT_RE = /^(.*) -:- (.*) \((.*)\) -:- (.*)$/

      attr_reader :src, :sha, :path, :logger, :git_ssh, :branch, :pull_request_id

      def initialize(src, sha, path, options = {}, &block)
        @src             = src
        @sha             = sha
        @path            = path
        @branch          = options[:branch]
        @pull_request_id = options[:pull_request_id]
        @logger          = block
      end

      def git_ssh_content(key_location)
        key = key_location ? "-i #{key_location}" : ""
        out = "#!/bin/sh\n"
        out << "/usr/bin/ssh"
        out << " -A -o LogLevel=quiet"
        out << " -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
        out << " #{key} $@\n"
        out
      end

      def fetch_cmd(options = {})
        depth        = options.key?(:depth) ? options[:depth] : 50
        clone_branch = " --branch=#{branch}" if branch
        checkout_cmd = "git checkout -qf #{sha}"
        fetch_cmd    = nil

        if pull_request_id
          clone_branch = ""
          fetch_cmd = "git fetch origin +refs/pull/#{pull_request_id}/head"
          checkout_cmd = "git checkout -q FETCH_HEAD"
        end

        fetch_origin_cmd = "cd #{path} && git clean -q -d -x -f && git fetch -q origin && git fetch --tags -q origin && git reset -q --hard #{sha}"
        clone_cmd = "git clone --depth=#{depth}#{clone_branch} #{src} #{path}"
        sync_repo_cmd = "if [ -d #{path}/.git ]; then #{fetch_origin_cmd}; else #{clone_cmd}; fi"

        cmd = []
        cmd << %{ echo "$ #{sync_repo_cmd}" }
        cmd << sync_repo_cmd
        if fetch_cmd
          cmd << %{ echo "$ #{fetch_cmd}" }
          cmd << %{ ( cd #{path} && #{fetch_cmd} ) }
        end
        cmd << %{ echo "$ #{checkout_cmd}" }
        cmd << %{ ( cd #{path} && #{checkout_cmd} ) }

        cmd.join("\n")
      end

    end

  end
end
