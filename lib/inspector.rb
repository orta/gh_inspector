require 'inspector/version'

# Note that the README is generated from the class comments

module Inspector

  # To get started using The Issues Inspector, you will need to
  # create an inspector. This class is main public API for querying issues.
  #
  # #### Getting started
  #
  # Create an instance of `Inspector::Inspector`, you can then ask it to search
  # based on your raised exception, or as a direct query yourself.
  #
  # ``` ruby
  # require 'gh-issues-inspector'
  # inspector = Inspector::Inspector("orta", "eigen")
  # inspector.search_query "Someone set us up the bomb"
  # ```
  #
  # By default this would output something like:
  #
  #
  #
  #
  #

  class Inspector
    attr_accessor :repo_owner, :repo_name, :query, :sidekick

    # Init function with a "orta/project" style string
    def self.from_slug(slug)
      details = slug.split '/'
      Inspector.new details.first, details.last
    end

    # Init function with "orta", "project"
    def initialize(repo_owner, repo_name)
      self.repo_owner = repo_owner
      self.repo_name = repo_name
      self.sidekick = Sidekick.new(repo_owner, repo_name)
    end

    # Does some magic to try and pull out a reasonable search query
    # for an exception, then searchs with that
    def search_exception(exception, _delegate = nil)
      search_query(exception.message)
    end

    # Queries for an specific search string
    def search_query(query, _delegate = nil)
      sidekick.search(query)
    end
  end
end
