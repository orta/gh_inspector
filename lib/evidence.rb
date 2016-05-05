require 'inspector/version'

module Inspector

  # The default user interface for the inspector,
  # it's public API should be considered the protocol for other classes
  # to present their own user interfaces in a way that fits their projects.

  class Evidence

    # Called just as the investigation has begun
    def inspector_started_query(query, inspector)
      puts "Looking for related issues on #{inspector.repo_owner}/#{inspector.repo_name}..."
    end

    # Called if it is taking longer than a second to pull down the results.
    # This offers a good chance to offer some kind of feedback to the user.
    def inspector_is_still_investigating(report, inspector)
      print "."
    end

    # Called once the inspector has recieved a report with more than one issue
    def inspector_successfully_recieved_report(report, inspector)
      report.issues[0..2].each { |issue| print_issue_full(issue) }

      if report.issues.count > 3
        puts "and #{report.total_results - 3} more at:"
        puts report.url
      end
    end

    # Called once the report has been recieved, but when there are no issues found
    def inspector_recieved_empty_report(inspector)

    end

    # Called when there have been networking issues in creating the report
    def inspector_could_not_create_report(error, inspector)

    end

    private

    def print_issue_full issue
      puts " - #{issue.title}"
      puts "   #{issue.url} [#{issue.status}] [#{issue.comments} comment#{issue.comments == 1 ? "" : "s"}]"
      puts ""
    end
  end
end
