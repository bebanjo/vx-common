require 'spec_helper'

describe Vx::Common::Helper::Shell do

  let(:klass) { Class.new.tap{|i| i.send :include, described_class } }
  let(:object) { klass.new }

  subject { object }

  context "path" do
    it "should create Pathname" do
      expect_method(:path, '/tmp').to eq Pathname.new('/tmp')
    end
  end

  context "mkdir" do

    after { FileUtils.rm_rf '/tmp/.a/' }

    it "should create directories" do
      expect_method(:mkdir, '/tmp/.a/b/c')
      expect(File.directory? '/tmp/.a/b/c')
    end
  end

  context "rm" do
    before { FileUtils.mkdir_p '/tmp/.a/b/c' }
    after  { FileUtils.rm_rf '/tmp/.a' }

    it "should force remove" do
      expect_method :rm, '/tmp/.a'
      expect(File.exists? '/tmp/.a').to be_false
    end
  end

  context "recreate" do
    before { FileUtils.mkdir_p '/tmp/.a/b/c' }
    after  { FileUtils.rm_rf '/tmp/.a' }

    it "should remove and create directory" do
      expect_method :recreate, '/tmp/.a/b'
      expect(File.exists? '/tmp/.a/b/c').to be_false
    end
  end

  context "write_file" do
    let(:fname) { '/tmp/.a' }
    after { FileUtils.rm_f fname }

    it "should write content to file" do
      expect_method :write_file, fname, 'content', 0611
      expect(File.readable? fname).to be_true
      expect(File.read fname).to eq 'content'
    end
  end

  context "write_tmp_file" do
    let(:tmp_file) { object.send :write_tmp_file, 'fname', 'content', 0611 }

    after { FileUtils.rm_f tmp_file.path }

    it "should create tmp file and write content" do
      expect(tmp_file).to be
      expect(File.readable? tmp_file.path).to be_true
      expect(File.read tmp_file.path).to eq 'content'
    end
  end

  context "read_file" do
    let(:fname) { '/tmp/.a' }
    before do
      File.open fname, 'w' do |io|
        io << "content"
      end
    end
    after { FileUtils.rm_f fname }

    it "should read file" do
      expect_method(:read_file, fname).to eq 'content'
    end

    context "when file does not exists" do
      it "should return nil" do
        expect_method(:read_file, 'not_exists').to be_nil
      end
    end
  end

  context "bash" do
    let(:output) { '' }

    context "when command is string" do
      it "should spawn bash command and return exit code" do
        expect_method(:bash, "echo $HOME", &method(:add_to_output)).to eq 0
        expect(output).to eq ENV['HOME'] + "\n"
      end
    end

    context "when command is a file" do
      let(:fname) { '/tmp/.a' }

      before do
        File.open fname, 'w' do |io|
          io << "echo $HOME"
        end
      end

      after { FileUtils.rm_f fname }

      it "should spawn bash, execute file and return exit code" do
        expect_method(:bash, file: fname, &method(:add_to_output)).to eq 0
      end
    end

    context "when :ssh options passed" do
      let(:ssh) { 'ssh' }

      before do
        mock(ssh).spawn("/usr/bin/env -i HOME=${HOME} bash -c command", {}) { 0 }
      end

      it "should execute command thougth :ssh" do
        expect_method(:bash, 'command', ssh: ssh, &method(:add_to_output)).to eq 0
      end

    end

    def add_to_output(out)
      output << out
    end
  end

  def expect_method(name, *args, &block)
    expect(object.send(name, *args, &block))
  end

end
