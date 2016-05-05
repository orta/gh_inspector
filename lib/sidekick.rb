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
    def search(query)
      url = url_for_request query
      results = get_api_results url
      parse_results query, results
    end

    private

    require 'json'

    # Generates a URL for the request
    def url_for_request(query)
      "https://api.github.com/search/issues?q=#{query}%2Brepo%3A#{repo_owner}%2F#{repo_name}&sort=created&order=asc"
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
      report.issues = results['items'].map do |item|
        issue = Issue.new
        issue.title = item['title']
        issue.number = item['number']
        issue.url = item['url']
        issue.state = item['state']
        issue.body = item['body']
        issue.comments = item['comments']
        issue
      end
      report
    end
  end

  class InspectionReport
    attr_accessor :issues, :url, :query, :total_results
  end

  # TODO, as these are key compliant with the json dicts, maybe they could just have an init func that
  # loops through their attrs and pulls the values out of the hash?

  class Issue
    attr_accessor :title, :number, :url, :state, :body, :comments
  end
end
