require 'spec_helper'
require 'tmpdir'
require 'vx/common/spawn'

describe Vx::Common::Git do
  let(:path)       { Dir.tmpdir }
  let(:src)        { "git@github.com:vexor/vx-test-repo.git" }
  let(:sha)        { "43048129a832a055dbd293a27de343a162609159" }
  let(:deploy_key) { File.read File.expand_path("../../../fixtures/insecure_private_key", __FILE__) }
  let(:output)     { "" }
  let(:options)    { {} }
  let(:git)        {
    described_class.new src, sha, "#{path}/repo", options, &method(:add_to_output)
  }

  subject { git }

  before do
    FileUtils.rm_rf path
    FileUtils.mkdir_p path
    File.open("#{path}/ssh.key", 'w', 0600) do |io|
      io.write deploy_key
    end
  end

  after { FileUtils.rm_rf path }

  context "just created" do
    its(:src)    { should eq src }
    its(:sha)    { should eq sha }
    its(:path)   { should eq "#{path}/repo" }
    its(:branch) { should be_nil }
  end

  context "assign branch" do
    let(:options) { { branch: 'master' } }
    its(:branch)  { should eq 'master' }
  end

  context "run fetch_cmd" do
    include Vx::Common::Spawn

    let(:options) { {
      branch: "master"
    } }
    let(:git_ssh_content) {
      git.git_ssh_content "$(dirname $0)/ssh.key"
    }
    let(:run) {
      cmd = git.fetch_cmd
      cmd = "set -e\n#{cmd}"
      spawn(git_ssh_env, cmd, &method(:add_to_output))
    }
    subject { run }

    before do
      File.open("#{path}/git_ssh", 'w', 0755) do |io|
        io.write git_ssh_content
      end
      run
    end

    context "success" do
      it { should be }

      it "should return zero" do
        expect(run).to eq 0
      end

      it "should create nessesary directories and checkout sha" do
        expect(File.directory? "#{path}/repo").to be
        expect(File.directory? "#{path}/repo/.git/objects").to be
        Dir.chdir "#{path}/repo" do
          expect((`git rev-parse HEAD`).strip).to eq sha
        end
      end

      context "with pull_request" do
        let(:options) { { pull_request_id: 1 } }
        it "should return zero" do
          expect(run).to eq 0
        end
      end
    end

    context "fail" do
      context "when repo does not exists" do
        let(:src) { "git@github.com:vexor/not-exists-repo.git"  }
        it "should return non zero status" do
          expect(run).to_not eq 0
        end
      end

      context "when sha does not exists" do
        let(:sha) { "is-not-exists"  }
        it "should return non zero status" do
          expect(run).to_not eq 0
        end
      end
    end

    def git_ssh_env
      { 'GIT_SSH' => "#{path}/git_ssh" }
    end
  end

  def add_to_output(out)
    puts "==> #{out}"
    output << out
  end
end
