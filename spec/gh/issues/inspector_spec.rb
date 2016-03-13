require 'spec_helper'

describe Gh::Issues::Inspector do
  it 'has a version number' do
    expect(Gh::Issues::Inspector::VERSION).not_to be nil
  end
end
