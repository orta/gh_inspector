require 'spec_helper'

describe Inspector do
  it 'has a version number' do
    expect(Inspector::VERSION).not_to be nil
  end
end

describe Inspector::Inspector do
  before do
    @subject = Inspector::Inspector.new 'orta', 'my_repo'
  end

  it 'supports a slug class method' do
    @subject = Inspector::Inspector.from_slug 'water/guy_heapo'
    expect(@subject.repo_owner).to eq 'water'
    expect(@subject.repo_name).to eq 'guy_heapo'
  end

  it 'keeps track of user / repo' do
    expect(@subject.repo_owner).to eq 'orta'
    expect(@subject.repo_name).to eq 'my_repo'
  end

  it 'creates a sidekick' do
    expect(@subject.sidekick).to_not be nil
  end

  it 'passes the message of a issue to a query' do
    expect(@subject).to receive(:search_query).with('Raising Issue', nil)

    begin
      raise 'Raising Issue'
    rescue StandardError => e
      @subject.search_exception(e)
    end
  end

  it 'passes the delegate of an exception to a query' do
    stub = Object.new
    expect(@subject).to receive(:search_query).with('Raising Issue', stub)

    begin
      raise 'Raising Issue'
    rescue StandardError => e
      @subject.search_exception(e, stub)
    end
  end

  it 'requests a search from the sidekick' do
    expect(@subject.sidekick).to receive(:search)
    @subject.search_query('Raising Issue')
  end

  describe 'delegate callbacks' do
  end
end
