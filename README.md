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
create an inspector. This class is main public API for querying issues.

#### Getting started

Create an instance of `Inspector::Inspector`, you can then ask it to search
based on your raised exception, or as a direct query yourself.

``` ruby
require 'gh-issues-inspector'
inspector = Inspector::Inspector("orta", "eigen")
inspector.search_query "Someone set us up the bomb"

# or
inspector.search_exception(e)
```

By default this would output:

```
Looking for related issues on CocoaPods/CocoaPods...

  - undefined method `to_ary' for #<Pod::Specification name="iVersion">Did you mean? to_query
    https://github.com/CocoaPods/CocoaPods/issues/4748 [closed] [1 comment]

  - NoMethodError - undefined method `to_ary' for Pod EAIntroView
    https://github.com/CocoaPods/CocoaPods/issues/4391 [closed] [15 comments]

  - Do a search on GitHub for issues relating to a crash?
    https://github.com/CocoaPods/CocoaPods/issues/4391 [open] [3 comments]

and 10 more at:
https://github.com/CocoaPods/CocoaPods/search?q=undefined+method+%60to_ary%27&type=Issues&utf8=✓
```


#### Presenting Your Report

The default user interface for the inspector, its public API should be
considered the protocol for other classes wanting to provide a user interface.

Your custom objects will be verified at runtime that they conform to the protocol.

You can see the default implmentation at
[lib/evidence.rb](/orta/gh-issues-inspector/tree/master/lib/evidence.rb).

*Protocol for custom objects:*

 - `inspector_started_query(query, inspector)` - Called just as the investigation has begun.
 - `inspector_is_still_investigating(report, inspector)` - Called if it is taking longer than a second to pull down the results.
This offers a chance to offer feedback to the user that it's not frozen.
 - `inspector_successfully_recieved_report(report, inspector)` - Called once the inspector has recieved a report with more than one issue.
 - `inspector_recieved_empty_report(inspector)` - Called once the report has been recieved, but when there are no issues found.
 - `inspector_could_not_create_report(error, inspector)` - Called when there have been networking issues in creating the report.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

The usage section of this README is generated from inline documentation inside the classes, to update it run `rake readme`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/orta/gh-issues-inspector.
