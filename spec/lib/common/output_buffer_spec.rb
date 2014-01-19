require 'spec_helper'

describe Vx::Common::OutputBuffer do
  let(:collected) { "" }
  let(:write)     { ->(str) { collected << str } }
  let(:buffer)    { described_class.new(0.5, &write) }

  after do
    buffer.close
  end

  it { should be }

  it "should add string to buffer" do
    buffer << "1"
    buffer << "2"
    expect(collected).to eq ''
    sleep 1
    expect(collected).to eq '12'

    buffer << '3'
    expect(collected).to eq '12'
    sleep 1
    expect(collected).to eq '123'
  end

  it "should raise error when add to closed buffer" do
    buffer.close
    expect {
      buffer << "1"
    }.to raise_error
  end

  it "should flush buffer" do
    buffer << "1"
    sleep 0.1
    expect(collected).to eq ''
    buffer.flush
    expect(collected).to eq '1'
  end

end
