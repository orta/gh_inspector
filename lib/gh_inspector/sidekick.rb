require "net/http"
require 'uri'

module GhInspector
  # The Sidekick is the one who does all the real work.
  # They take the query, get the GitHub API results, etc
  # then pass them back to the inspector who gets the public API credit.

  class Sidekick
    attr_accessor :repo_owner, :repo_name, :inspector

    def initialize(inspector, repo_owner, repo_name)
      self.inspector = inspector
      self.repo_owner = repo_owner
      self.repo_name = repo_name
    end

    # Searches for a query, with a UI delegate
    def search(query, delegate)
      validate_delegate(delegate)

      delegate.inspector_started_query(query, inspector)
      url = url_for_request query

      begin
        results = get_api_results(url)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        delegate.inspector_could_not_create_report(e, query, inspector)
        return
      end

      report = parse_results query, results

      # TODO: progress callback

      if report.issues.any?
        delegate.inspector_successfully_recieved_report(report, inspector)
      else
        delegate.inspector_recieved_empty_report(report, inspector)
      end

      report
    end

    def verbose
      self.inspector.verbose
    end

    private

    require 'json'

    # Generates a URL for the request
    def url_for_request(query, sort_by: nil, order: nil)
      url = "https://api.github.com/search/issues?q="
      url += URI.escape(query)
      url += "+repo:#{repo_owner}/#{repo_name}"
      url += "&sort=#{sort_by}" if sort_by
      url += "&order=#{order}" if order

      url
    end

    # Gets the search results
    def get_api_results(url)
      uri = URI.parse(url)
      puts "URL: #{url}" if self.verbose
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      JSON.parse(response.body)
    end

    # Converts a GitHub search JSON into a InspectionReport
    def parse_results(query, results)
      report = InspectionReport.new
      report.url = "https://github.com/#{repo_owner}/#{repo_name}/search?q=#{URI.escape(query)}&type=Issues&utf8=✓"
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
    attr_accessor :title, :number, :html_url, :state, :body, :comments, :updated_at

    # Hash -> public attributes
    def initialize(*h)
      if h.length == 1 && h.first.kind_of?(Hash)
        h.first.each { |k, v| send("#{k}=", v) if public_methods.include?("#{k}=".to_sym) }
      end
    end
  end
end
