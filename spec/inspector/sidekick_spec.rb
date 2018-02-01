require 'spec_helper'

describe GhInspector::Sidekick do
  before do
    @inspector = GhInspector::Inspector.new('orta', 'my_repo')
    @subject = GhInspector::Sidekick.new @inspector, 'orta', 'my_repo'
    @evidence = SilentEvidence.new
    @new_evidence = NewSilentEvidence.new
  end

  it 'keeps track of user / repo' do
    expect(@subject.repo_owner).to eq 'orta'
    expect(@subject.repo_name).to eq 'my_repo'
  end

  describe 'when searching' do
    before do
      url = 'https://api.github.com/search/issues?q=Testing%20something+repo:orta/my_repo'
      json = JSON.parse File.read('spec/inspector/stubbed_example.json')
      allow(@subject).to receive(:get_api_results).with(url).and_return(json)
    end

    it 'verifies the ui delegate for protocol comformance' do
      expect { @subject.search 'Testing', Object.new }.to raise_error RuntimeError
    end

    it 'works right with fixtured data' do
      results = @subject.search 'Testing something', @evidence

      expect(results.url).to eq "https://github.com/orta/my_repo/search?q=Testing%20something&type=Issues&utf8=✓"
      expect(results.query).to eq 'Testing something'
      expect(results.total_results).to eq 33
    end

    it 'creates fully set up issues' do
      results = @subject.search 'Testing something', @evidence
      issue = results.issues.first

      expect(issue.title).to eq 'Travis CI with Ruby 1.9.x fails for recent pull requests'
      expect(issue.number).to eq 646
      expect(issue.html_url).to eq 'https://github.com/CocoaPods/CocoaPods/issues/646'
      expect(issue.state).to eq 'closed'
      expect(issue.body).to include 'The Ruby 1.8.x builds work fine'
      expect(issue.comments).to eq 8
    end
  end

  describe 'delegate calls' do
    before do
      url = 'https://api.github.com/search/issues?q=Testing+repo:orta/my_repo'
      @json = JSON.parse File.read('spec/inspector/stubbed_example.json')
    end

    it 'sends the starting message' do
      allow(@subject).to receive(:get_api_results).and_return(@json)

      expect(@evidence).to receive(:inspector_started_query).with("Testing", @inspector)
      @subject.search 'Testing', @evidence
    end

    it 'passes errors to the delegate' do
      error = Net::HTTPError.new('', '')
      allow(@subject).to receive(:get_api_results).and_raise(error)

      expect(@evidence).to receive(:inspector_could_not_create_report).with(error, "Testing", @inspector)
      @subject.search 'Testing', @evidence
    end

    it 'sends a report if successful and there are issues' do
      allow(@subject).to receive(:get_api_results).and_return(@json)

      expect(@evidence).to receive(:inspector_successfully_recieved_report)
      @subject.search 'Testing', @evidence
    end

    it 'sends a message about empty reports' do
      @json['items'] = []
      allow(@subject).to receive(:get_api_results).and_return(@json)

      expect(@evidence).to receive(:inspector_recieved_empty_report)
      @subject.search 'Testing', @evidence
    end

    it 'sends a report if successful and there are issues for delegate with new methods' do
      allow(@subject).to receive(:get_api_results).and_return(@json)

      expect(@new_evidence).to receive(:inspector_successfully_received_report)
      @subject.search 'Testing', @new_evidence
    end

    it 'sends a message about empty reports for delegate with new methods' do
      @json['items'] = []
      allow(@subject).to receive(:get_api_results).and_return(@json)

      expect(@new_evidence).to receive(:inspector_received_empty_report)
      @subject.search 'Testing', @new_evidence
    end
  end
end
