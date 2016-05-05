# The Issues Inspector

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gh-issues-inspector'
```

And then execute:

    $ bundle

## Usage

#### The Inspector

To get started using The Issues Inspector, you will need to
create an inspector. This class is main API for making inspections to GitHub.
Create an instance of it, you can then ask it to search based on your
raised exception, or optionally make a direct query yourself.

``` ruby
require 'gh-issues-inspector'
inspector = Inspector::Inspector("orta", "eigen")

```
#### Presenting Your Report

The default user interface for the inspector,
it's public API should be considered the protocol for other classes
to present their own user interfaces in a way that fits their projects.
Protocol for custom objects:

 - `inspector_started_query(query,inspector)` - Called just as the investigation has begun
 - `inspector_is_still_investigating(report,inspector)` - Called if it is taking longer than a second to pull down the results.
This offers a good chance to offer some kind of feedback to the user.
 - `inspector_successfully_recieved_report(report,inspector)` - Called once the inspector has recieved a report with more than one issue
 - `inspector_recieved_empty_report(inspector)` - Called once the report has been recieved, but when there are no issues found
 - `inspector_could_not_create_report(error,inspector)` - Called when there have been networking issues in creating the report


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

The usage section of this README is generated from inline documentation inside the classes, to update it run `rake readme`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/orta/gh-issues-inspector.
