# encoding: UTF-8

require 'spec_helper'
require 'vx/common/spawn'
require 'fileutils'

describe Vx::Common::Helper::UploadShCommand do
  let(:object) { Object.new }
  subject { object }

  before do
    object.extend described_class
    object.extend Vx::Common::Spawn
  end

  it { should be_respond_to(:upload_sh_command) }

  context "#upload_sh_command" do
    let(:file)    { '/tmp/.test' }
    let(:content) { 'Дима' }
    let(:cmd) { object.upload_sh_command file, content }

    before { FileUtils.rm_rf file }
    after { FileUtils.rm_rf file }

    it "should be successful" do
      object.spawn cmd do |out|
        puts " ===> #{out}"
      end

      expect(File).to be_readable(file)
      expect(File.read file).to eq content
    end

  end

end


