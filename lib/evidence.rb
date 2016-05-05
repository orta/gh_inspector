require 'inspector/version'

module Inspector

  # The default user interface for the inspector, its public API should be
  # considered the protocol for other classes wanting to provide a user interface.
  #
  # Your custom objects will be verified at runtime that they conform to the protocol.
  #
  # You can see the default implmentation at
  # [lib/evidence.rb](/orta/gh-issues-inspector/tree/master/lib/evidence.rb).
  #
  # Both `search_query` and `search_exception` take your custom delegate as a 2nd optional parameter.
  #
  # ``` ruby
  # require 'gh-issues-inspector'
  # inspector = Inspector::Inspector.new "orta", "eigen"
  # inspector.search_query "Someone set us up the bomb", ArtsyUI.new
  # ```
  #

  class Evidence

    # Called just as the investigation has begun.
    def inspector_started_query(query, inspector)
      puts "Looking for related issues on #{inspector.repo_owner}/#{inspector.repo_name}..."
    end

    # Called if it is taking longer than a second to pull down the results.
    # This offers a chance to offer feedback to the user that it's not frozen.
    def inspector_is_still_investigating(query, inspector)
      print "."
    end

    # Called once the inspector has recieved a report with more than one issue.
    def inspector_successfully_recieved_report(report, inspector)
      report.issues[0..2].each { |issue| print_issue_full(issue) }

      if report.issues.count > 3
        puts "and #{report.total_results - 3} more at:"
        puts report.url
      end
    end

    # Called once the report has been recieved, but when there are no issues found.
    def inspector_recieved_empty_report(report, inspector)
      puts "Found no similar issues. To create a new issue, please visit:"
      puts "https://github.com/#{inspector.repo_owner}/#{inspector.repo_name}/issues/new"
    end

    # Called when there have been networking issues in creating the report.
    def inspector_could_not_create_report(error, query, inspector)
      puts "Could not access the GitHub API, you may have better luck via the website."
      puts "https://github.com/#{inspector.repo_owner}/#{inspector.repo_name}/search?q=#{query}&type=Issues&utf8=✓"
      puts "Error: #{error.name}"
    end

    private

    def print_issue_full issue
      puts " - #{issue.title}"
      puts "   #{issue.html_url} [#{issue.state}] [#{issue.comments} comment#{issue.comments == 1 ? "" : "s"}]"
      puts ""
    end
  end
end
