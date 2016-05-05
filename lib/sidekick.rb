module Inspector

  # The Sidekick is the one who does all the real work.
  # They take the query, get the GitHub API results, etc
  # then pass them back to the inspector who gets the public API credit.

  class Sidekick
    attr_accessor :repo_owner, :repo_name

    def initialize(repo_owner, repo_name)
      self.repo_owner = repo_owner
      self.repo_name = repo_name
    end

    # Searches for a query, with a UI delegate
    def search(query, delegate)
      validate_delegate(delegate)

      url = url_for_request query
      results = get_api_results url
      parse_results query, results
    end

    private

    require 'json'

    # Generates a URL for the request
    def url_for_request(query)
      root = "https://api.github.com/"
      root + "search/issues?q=#{query}%2Brepo%3A#{repo_owner}%2F#{repo_name}&sort=created&order=asc"
    end

    # Gets the search results
    def get_api_results(_url)
      JSON.parse File.read('spec/inspector/stubbed_example.json')
    end

    # Converts a GitHub search JSON into a InspectionReport
    def parse_results(query, results)
      report = InspectionReport.new
      report.url = "https://github.com/#{repo_owner}/#{repo_name}/search?q=#{query}&type=Issues&utf8=✓"
      report.query = query
      report.total_results = results['total_count']
      report.issues = results['items'].map { |item| Issue.new(item) }
      report
    end

    def validate_delegate(delegate)
      e = Evidence.new
      protocol = e.public_methods false
      protocol.each do |m|
        raise "#{delegate} does not handle #{m}" unless delegate.methods.include? m
      end
    end
  end

  class InspectionReport
    attr_accessor :issues, :url, :query, :total_results
  end

  class Issue
    attr_accessor :title, :number, :html_url, :state, :body, :comments

    # Hash -> public attributes
    def initialize(*h)
      if h.length == 1 && h.first.is_a?(Hash)
        h.first.each { |k, v| send("#{k}=", v) if public_methods.include?("#{k}=".to_sym) }
      end
    end
  end
end
