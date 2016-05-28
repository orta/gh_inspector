require 'inspector/version'
require 'time'

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
  # require 'inspector'
  # inspector = Inspector::Inspector.new "orta", "eigen"
  # inspector.search_query "Someone set us up the bomb", ArtsyUI.new
  # ```
  #

  NUMBER_OF_ISSUES_INLINE = 3

  class Evidence
    # Called just as the investigation has begun.
    def inspector_started_query(query, inspector)
      puts "Looking for related issues on #{inspector.repo_owner}/#{inspector.repo_name}..."
      puts "Search query: #{query}" if inspector.verbose
    end

    # Called once the inspector has recieved a report with more than one issue.
    def inspector_successfully_recieved_report(report, inspector)
      report.issues[0..(NUMBER_OF_ISSUES_INLINE - 1)].each { |issue| print_issue_full(issue) }

      if report.issues.count > NUMBER_OF_ISSUES_INLINE
        puts "and #{report.total_results - NUMBER_OF_ISSUES_INLINE} more at:"
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

    def print_issue_full(issue)
      puts " - #{issue.title}"
      puts "   #{issue.html_url} [#{issue.state}] [#{issue.comments} comment#{issue.comments == 1 ? '' : 's'}]"
      puts "   #{Time.parse(issue.updated_at).to_pretty}"
      puts ""
    end
  end
end

# Taken from https://stackoverflow.com/questions/195740/how-do-you-do-relative-time-in-rails

module PrettyDate
  def to_pretty
    a = (Time.now - self).to_i

    case a
    when 0 then 'just now'
    when 1 then 'a second ago'
    when 2..59 then a.to_s + ' seconds ago'
    when 60..119 then 'a minute ago' # 120 = 2 minutes
    when 120..3540 then (a / 60).to_i.to_s + ' minutes ago'
    when 3541..7100 then 'an hour ago' # 3600 = 1 hour
    when 7101..82_800 then ((a + 99) / 3600).to_i.to_s + ' hours ago'
    when 82_801..172_000 then 'a day ago' # 86400 = 1 day
    when 172_001..518_400 then ((a + 800) / (60 * 60 * 24)).to_i.to_s + ' days ago'
    when 518_400..1_036_800 then 'a week ago'
    when 1_036_801..4_147_204 then ((a + 180_000) / (60 * 60 * 24 * 7)).to_i.to_s + ' weeks ago'
    else strftime("%d %b %Y")
    end
  end
end

Time.send :include, PrettyDate
