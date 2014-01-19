require 'spec_helper'

TestFirstMiddleware = Struct.new(:app) do
  def call(env)
    env << :first
    app.call env
  end
end

TestLastMiddleware = Struct.new(:app) do
  def call(env)
    env << :last
    app.call env
  end
end

class MiddlewaresTest
  include Vx::Common::Helper::Middlewares

  middlewares do
    use TestFirstMiddleware
    use TestLastMiddleware
  end

  def run
    run_middlewares([]) do |env|
      env << :app
    end
  end

end

describe Vx::Common::Helper::Middlewares do
  let(:klass)  { MiddlewaresTest }
  let(:object) { klass.new }
  subject { object }

  it "should run defined middlewares" do

    expect(object.run).to eq [:first, :last, :app]
  end

end
