require 'spec_helper'
require 'sidekick'
require 'evidence'


describe Inspector::Sidekick do
  before do
    @subject = Inspector::Sidekick.new 'orta', 'my_repo'
    @evidence = Inspector::Evidence.new
  end

  it 'keeps track of user / repo' do
    expect(@subject.repo_owner).to eq 'orta'
    expect(@subject.repo_name).to eq 'my_repo'
  end

  describe 'when searching' do
    before do
      url = 'https://api.github.com/search/issues?q=Testing%2Brepo%3Aorta%2Fmy_repo&sort=created&order=asc'
      json = JSON.parse File.read('spec/inspector/stubbed_example.json')
      allow(@subject).to receive(:get_api_results).with(url).and_return(json)
    end

    it 'verifies the ui delegate for protocol comformance' do
      expect { @subject.search 'Testing', Object.new }.to raise_error RuntimeError
    end

    it 'works right with fixtured data' do
      results = @subject.search 'Testing', @evidence

      expect(results.url).to eq "https://github.com/orta/my_repo/search?q=Testing&type=Issues&utf8=✓"
      expect(results.query).to eq 'Testing'
      expect(results.total_results).to eq 33
    end

    it 'creates fully set up issues' do
      results = @subject.search 'Testing', @evidence
      issue = results.issues.first

      expect(issue.title).to eq 'Travis CI with Ruby 1.9.x fails for recent pull requests'
      expect(issue.number).to eq 646
      expect(issue.html_url).to eq 'https://github.com/CocoaPods/CocoaPods/issues/646'
      expect(issue.state).to eq 'closed'
      expect(issue.body).to include 'The Ruby 1.8.x builds work fine'
      expect(issue.comments).to eq 8
    end
  end
end
