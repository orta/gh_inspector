require 'spec_helper'

describe GhInspector::Evidence do
  before do
    time = Time.new(2016, 5, 13)
    allow(Time).to receive(:now).and_return time

    inspector = GhInspector::Inspector.new('orta', 'my_repo')
    @subject = inspector.sidekick
    @evidence = GhInspector::Evidence.new
  end

  describe 'reaction to delegate calls' do
    before do
      url = 'https://api.github.com/search/issues?q=Testing%20OK+repo:orta/my_repo'
      json = JSON.parse File.read('spec/inspector/stubbed_example.json')
      allow(@subject).to receive(:get_api_results).with(url).and_return(json)
      @report = @subject.search 'Testing OK', SilentEvidence.new
    end

    it 'handles a message about the start of a query' do
      allow(@evidence).to receive(:puts).with("")
      allow(@evidence).to receive(:puts).with("Looking for related GitHub issues on orta/my_repo...")
      @evidence.inspector_started_query("Problem", @subject)
    end

    it 'handles full results' do
      message = ""
      allow(@evidence).to receive(:puts).and_wrap_original do |original_method, *args, &block|
        message << args.first + "\n"
      end

      @evidence.inspector_successfully_received_report(@report, @subject)
      # rubocop:disable Layout/IndentHeredoc
      expect(message).to start_with <<-ISSUE
 - Travis CI with Ruby 1.9.x fails for recent pull requests
   https://github.com/CocoaPods/CocoaPods/issues/646 [closed] [8 comments]
   14 Nov 2012

 - pod search --full chokes on cocos2d.podspec:14
   https://github.com/CocoaPods/CocoaPods/issues/657 [closed] [1 comment]
   20 Nov 2012

 - about pod
   https://github.com/CocoaPods/CocoaPods/issues/4345 [closed] [21 comments]
   2 weeks ago

and 30 more at: https://github.com/orta/my_repo/search?q=Testing%20OK&type=Issues&utf8=✓

ISSUE
      # rubocop:enable Layout/IndentHeredoc
      expect(message).to end_with "\nYou can ⌘ + double-click on links to open them directly in your browser. 🔗\n" if /darwin/ =~ RUBY_PLATFORM
    end

    describe '' do
      before do
        @message = ""
        allow(@evidence).to receive(:puts).and_wrap_original do |original_method, *args, &block|
          @message << args.first + "\n"
        end
      end

      it 'handles full results' do
        @evidence.inspector_successfully_received_report(@report, @subject)

        # rubocop:disable Layout/IndentHeredoc
        expect(@message).to start_with <<-ISSUE
 - Travis CI with Ruby 1.9.x fails for recent pull requests
   https://github.com/CocoaPods/CocoaPods/issues/646 [closed] [8 comments]
   14 Nov 2012

 - pod search --full chokes on cocos2d.podspec:14
   https://github.com/CocoaPods/CocoaPods/issues/657 [closed] [1 comment]
   20 Nov 2012

 - about pod
   https://github.com/CocoaPods/CocoaPods/issues/4345 [closed] [21 comments]
   2 weeks ago

and 30 more at: https://github.com/orta/my_repo/search?q=Testing%20OK&type=Issues&utf8=✓

  ISSUE
        # rubocop:enable Layout/IndentHeredoc
        expect(@message).to end_with "\nYou can ⌘ + double-click on links to open them directly in your browser. 🔗\n" if /darwin/ =~ RUBY_PLATFORM
      end

      it 'handles less results differenly' do
        @report.issues = [@report.issues.first]
        @evidence.inspector_successfully_received_report(@report, @subject)

        expect(@message).to start_with <<-ISSUE
 - Travis CI with Ruby 1.9.x fails for recent pull requests
   https://github.com/CocoaPods/CocoaPods/issues/646 [closed] [8 comments]
   14 Nov 2012

ISSUE
        expect(@message).to end_with "\nYou can ⌘ + double-click on links to open them directly in your browser. 🔗\n" if /darwin/ =~ RUBY_PLATFORM
      end

      it 'handles empty results' do
        @evidence.inspector_received_empty_report(@report, @subject)
        # rubocop:disable Layout/IndentHeredoc
        expect(@message).to start_with <<-ISSUE
Found no similar issues. To create a new issue, please visit:
https://github.com/orta/my_repo/issues/new
  ISSUE
        # rubocop:enable Layout/IndentHeredoc
        expect(@message).to end_with "\nYou can ⌘ + double-click on links to open them directly in your browser. 🔗\n" if /darwin/ =~ RUBY_PLATFORM
      end

      it 'handles network errors' do
        error = Object.new
        allow(error).to receive(:name).and_return("Network Error")

        @evidence.inspector_could_not_create_report(error, "query", @subject)
        # rubocop:disable Layout/IndentHeredoc
        expect(@message).to start_with <<-ISSUE
Could not access the GitHub API, you may have better luck via the website.
https://github.com/orta/my_repo/search?q=query&type=Issues&utf8=✓
Error: Network Error
  ISSUE
        # rubocop:enable Layout/IndentHeredoc
        expect(@message).to end_with "\nYou can ⌘ + double-click on links to open them directly in your browser. 🔗\n" if /darwin/ =~ RUBY_PLATFORM
      end
    end
  end
end
