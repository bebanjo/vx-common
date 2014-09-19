require 'ostruct'
require 'shellwords' # To trace_sh_command

module Vx
  module Common

    class Git
      include Helper::TraceShCommand

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
        out << "exec /usr/bin/ssh"
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

        clone_cmd = "git clone --depth=#{depth}#{clone_branch} #{src} #{path}"

        cmd = []
        cmd << trace_sh_command(clone_cmd, {fold: "git.1", timing: true, retry: true, assert: true})
        cmd << %{ cd #{path} }
        if fetch_cmd
          cmd << trace_sh_command(fetch_cmd, {fold: "git.2", timing: true, retry: true, assert: true})
        end
        cmd << trace_sh_command(checkout_cmd, {fold: "git.3", timing: true, assert: true})

        cmd.join("\n")
      end
    end

  end
end
