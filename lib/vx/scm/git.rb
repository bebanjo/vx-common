require 'ostruct'
require File.expand_path("../git/git_ssh", __FILE__)

module Vx
  module SCM

    class Git

      include Common::Helper::Shell

      COMMIT_RE = /^(.*) -:- (.*) \((.*)\) -:- (.*)$/

      attr_reader :src, :sha, :path, :logger, :git_ssh, :branch, :pull_request_id

      def initialize(src, sha, path, options = {}, &block)
        @src             = src
        @sha             = sha
        @path            = path
        @branch          = options[:branch]
        @git_ssh         = GitSSH.new options[:deploy_key]
        @pull_request_id = options[:pull_request_id]
        @logger          = block
      end

      def open
        git_ssh.open do
          yield if block_given?
        end
      end

      def fetch
        open do
          run_git make_fetch_command
        end
      end

      def self.make_export_command(from, to)
        %{ (cd '#{from}' && git checkout-index -a -f --prefix='#{to}/') }.strip
      end

      def make_fetch_command(options = {})
        depth        = options.key?(:depth) ? options[:depth] : 50
        clone_branch = " --branch=#{branch}" if branch
        checkout_cmd = "git checkout -qf #{sha}"
        fetch_cmd    = nil

        if pull_request_id
          clone_branch = ""
          fetch_cmd = "git fetch origin +refs/pull/#{pull_request_id}/merge:"
          checkout_cmd = "git checkout -q FETCH_HEAD"
        end

        clone_cmd = "git clone -q --depth=#{depth}#{clone_branch} #{src} #{path}"

        cmd = []
        cmd << %{ echo "$ #{clone_cmd}" && #{clone_cmd} }
        cmd << %{ cd #{path} }
        cmd << %{ echo "$ #{fetch_cmd}" && #{fetch_cmd} } if fetch_cmd
        cmd << %{ echo "$ #{checkout_cmd}" && #{checkout_cmd} }

        cmd = cmd.join(" && ").gsub("\n", ' ').gsub(/\ +/, ' ').strip
        cmd
      end

      def commit_info
        rs = {}
        if str = commit_info_string
          if m = str.match(COMMIT_RE)
            rs.merge!(
              sha:     m[1],
              author:  m[2],
              email:   m[3],
              message: m[4]
            )
          end
        end
        OpenStruct.new rs
      end

      private

        def commit_info_string
          output = ""
          code = spawn commit_info_cmd, chdir: path do |io|
            output << io
          end
          if code == 0
            output.strip
          else
            nil
          end
        end

        def commit_info_cmd
          %{git log -1 --pretty=format:'%H -:- %cn (%ce) -:- %s'}
        end

        def run_git(cmd, options = {})
          env = {
            'GIT_SSH' => git_ssh.location.path
          }
          spawn(env, cmd, options, &logger)
        end

    end

  end
end
