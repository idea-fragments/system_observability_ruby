# System Observability
![example workflow](https://github.com/idea-fragments/system_observability_ruby/actions/workflows/main.yml/badge.svg)


## Installation

Add this line to your application's Gemfile:

```ruby
gem "idea_fragments_system_observability", "~> 0.1", git: "https://github.com/idea-fragments/system_observability_ruby"
```

And then execute:

    $ bundle install

## Setup and Configuration

The gem will need to be required in your code. Since the gem is loaded from a git repo, you'll need to require bundler/setup before requiring the gem.

```ruby
require "bundler/setup"
require "system_observability"
```

Create a file in `config/initializers` called `system_observability.rb` and add the following. Be sure to set the variables to the values you need for your project.


### Bugsnag
```ruby
# system_observability.rb
SystemObservability.configure do |c|
  # ....
  c.config_bugsnag(
    api_key: "your api key",
    app_version: "1.0.0",
    enabled_release_stages: ["production", "development", "staging"]
  )
  # ....
end
```
To add extra context to Bugsnag when reporting an error, use the SystemObservability::ErrorContextSetter class. This metadata will be added to the Bugsnag error report behind the scenes.

```ruby
SystemObservability::ErrorContextSetter.call(extra: "context")
```

To add context for custom objects, such as models, be sure to set up a data formatter for the object type. This only needs to be done once, so you can add the formatter to the `config/initializers` file.

```ruby
# system_observability.rb
SystemObservability::ErrorContextDataFormatters.add(
  User, 
  ->(user) { { id: user.id, name: user.name } }
)
```

Now custom objects can be added to the error context.
```ruby
SystemObservability::ErrorContextSetter.call(user: User.first, team: Team.first)
```

Most built in types do not need a formatter. A list of objects types that do not need a formatter can be found here:
```ruby
SystemObservability::ErrorContextSetter::TYPES_WITHOUT_FORMATTERS
```

### New Relic
Generate a new relic config file in the `config` directory by running:
```
newrelic install --license_key="YOUR_KEY" "My application"
```
Be sure to make any changes to the generated file based on your specific application details.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct
