require 'spec_helper'
require 'exception_hound'

describe Inspector::ExceptionHound do
  before do
    @hound = Inspector::ExceptionHound.new(Object)
  end

  it "removes instances memory addresses" do
    exception_string = "message for #<Danger::NewPlugin:0x007f806a3248e8>"
    @hound.message = exception_string

    expect(@hound.query).to eq "message for Danger::NewPlugin"
  end

  it "strips nil:Nill" do
    exception_string = "message was nil:NilClass"
    @hound.message = exception_string

    expect(@hound.query).to eq "message was nil"
  end

  it "simplifies the undefined message" do
    exception_string = "undefined local variable or method message"
    @hound.message = exception_string

    expect(@hound.query).to eq "undefined message"
  end
end
