require 'spec_helper'
require 'vx/message/testing'

describe Vx::SCM::Git do
  let(:path)       { '/tmp/.test/repo'               }
  let(:message)    { Vx::Message::PerformBuild.test_message }
  let(:src)        { message.src }
  let(:sha)        { message.sha }
  let(:deploy_key) { message.deploy_key }
  let(:output)     { "" }
  let(:options)    { {} }
  let(:git)        {
    described_class.new src, sha, path, options, &method(:add_to_output)
  }

  subject { git }

  before do
    FileUtils.rm_rf path
    FileUtils.mkdir_p path
  end

  after  { FileUtils.rm_rf path }

  context "just created" do
    its(:src)                 { should eq src }
    its(:sha)                 { should eq sha }
    its(:path)                { should eq path }
    its(:branch)              { should be_nil }
    its("git_ssh.deploy_key") { should be_nil }
  end

  context "assign branch" do
    let(:options) { { branch: 'master' } }
    its(:branch)  { should eq 'master' }
  end

  context "assign deploy_key" do
    let(:options) { { deploy_key: deploy_key } }
    its("git_ssh.deploy_key") { should eq deploy_key }
  end

  context "fetch" do
    let(:options) { { deploy_key: deploy_key } }
    subject { git.fetch }

    it { should eq 0 }

    it "should create nessesary directories and checkout sha" do
      subject
      expect(File.directory? path).to be
      expect(File.directory? "#{path}/.git").to be
      Dir.chdir path do
        expect((`git rev-parse HEAD`).strip).to eq sha
      end
    end

    it "should capture output" do
      subject
      expect(output).to match(Regexp.escape "$ git clone -q --depth=50 #{src} #{path}")
    end

    context "with error" do
      let(:src) { "/not-exists-repo.git"  }

      it "should return 128 exitstatus and add error to output" do
        expect(subject).to eq 128
        expect(output).to match('does not exist')
      end
    end
  end

  context "make_fetch_command" do
    include Vx::Common::Spawn

    let(:options) { { deploy_key: deploy_key, branch: "master" } }
    let(:run) do
      git.open do
        spawn(git_ssh_env, git.make_fetch_command, &method(:add_to_output))
      end
    end
    subject { git.make_fetch_command }

    before do
      run
    end

    it { should be }

    it "should be success" do
      expect(run).to eq 0
    end

    it "should create nessesary directories and checkout sha" do
      expect(File.directory? path).to be
      expect(File.directory? "#{path}/.git").to be
      Dir.chdir path do
        expect((`git rev-parse HEAD`).strip).to eq sha
      end
    end

    context "with error" do
      let(:src) { "/not-exists-repo.git"  }

      it "should return 128 exitstatus and add error to output" do
        expect(run).to eq 128
      end
    end

    def git_ssh_env
      { 'GIT_SSH' => git.git_ssh.location.path }
    end
  end

  context ".make_export_command" do
    let(:options)  { { deploy_key: deploy_key } }
    let(:from)     { path }
    let(:to)       { '/tmp/.test/export' }
    let(:expected) { "(cd '#{ from }' && git checkout-index -a -f --prefix='#{ to}/')" }
    subject { described_class.make_export_command from, to}
    it { should eq expected }

    context "run" do
      before do
        git.fetch
        system subject
      end

      it "should be success" do
        expect($?.to_i).to eq 0
      end

      it "should export repo" do
        expect(File.readable? "#{to}/Gemfile").to be_true
      end

      context "run with pull_request" do
        let(:options) { { deploy_key: deploy_key, pull_request_id: 1 } }

        it "should be success" do
          expect($?.to_i).to eq 0
        end

        it "should export repo" do
          expect(File.readable? "#{to}/Gemfile").to be_true
        end
      end
    end

  end

  context "commit_info" do
    let(:options) { { deploy_key: deploy_key } }
    subject { git.commit_info }
    before  { git.fetch }

    it "should be" do
      expect(subject.sha).to     eq 'b665f90239563c030f1b280a434b3d84daeda1bd'
      expect(subject.author).to  eq "Dmitry Galinsky"
      expect(subject.email).to   eq 'dima.exe@gmail.com'
      expect(subject.message).to eq 'first release'
    end
  end

  def add_to_output(out)
    puts "==> #{out}"
    output << out
  end
end
