# System Observability
![example workflow](https://github.com/idea-fragments/system_observability_ruby/actions/workflows/main.yml/badge.svg)

Bundled gem combining different system observability tools used in the IdeaFragments projects. Some gems are wrapped with helper methods, others not. Refer to the documentation of each bundled gem for detailed usage instructions.

Gems included:
- Bugsnag
- Datadog
- New Relic

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

Pass your current env to the configuration object
```ruby
# system_observability.rb
SystemObservability.configure do |c|
  # ....
  c.env = Rails.env # or whatever your current env is
  # ....
end
```

### Bugsnag
Pass in your bugsnag config value and the envs you want to report to Bugsnag for.
```ruby
# system_observability.rb
SystemObservability.configure do |c|
  # ....
  c.config_bugsnag(
    api_key: "your api key",
    app_version: "1.0.0",
    enabled_envs: [] # "production", "development", "staging"
  )
  # ....
end
```

### New Relic
Generate a new relic config file in the `config` directory by running:
```
newrelic install --license_key="YOUR_KEY" "My application"
```
Be sure to make any changes to the generated file based on your specific application details.

### Datadog
Pass in your datadog config value and the envs you want to send metrics for.
The `statsd_host` and `statsd_port` values are optional and will default to env variables for `DATADOG_HOST` and `DATADOG_PORT`, respectively, if not provided.
```ruby
# system_observability.rb
SystemObservability.configure do |c|
  # ....
  c.config_datadog(
    enabled_envs: [], # "production", "development", "staging"
    statsd_host: "Your statsd host",
    statsd_port: "Your statsd port",
  )
  # ....
end
```

If sidekiq is being used, the stats middleware for sidekiq can be enabled.
```ruby
# system_observability.rb
SystemObservability.configure do |c|
  # ....
  c.config_datadog(
    # ...
    track_sidekiq_job_timings: true,
  )
  # ....
end
```
This middleware will track the following metrics when a job is enqueued:

```ruby
tags = { job: job_name }
SystemObservability::Stats.distribution(
  "sidekiq.jobs.latency", 
  latency, # time between when the job is enqueued and when it is picked up to be processed
  tags: tags
)
SystemObservability::Stats.time(
  "sidekiq.jobs.time", 
  tags: tags, 
  &block
)
```

NOTE that distribution metrics will have "dist" prepended to the metric name.

## Usage

### Bugsnag

#### Async Jobs
To add extra context to Bugsnag when reporting an error, use the SystemObservability::ErrorContextSetter class. This metadata will be added to the Bugsnag error report behind the scenes.

```ruby
# app/jobs/some_job.rb

class SomeJob < ApplicationJob
  def perform
    SystemObservability::ErrorContextSetter.call(extra: "context")
    # ...
  end
end
```

To add context for custom objects, such as models, be sure to set up a data formatter for the object type. This only needs to be done once, so you can add the formatter to the `config/initializers` file.

```ruby
# system_observability.rb
SystemObservability::ErrorContextDataFormatters.add(
  User, 
  ->(user) { { id: user.id, name: user.name } }
)

# if using rails...In the same file, add the following:
Rails.configuration.after_initialize do
  SystemObservability::ErrorContextDataFormatters.add(
    User,
    ->(user) { { id: user.id, name: user.name } }
  )
end
```

Now custom objects can be added to the error context.
```ruby
SystemObservability::ErrorContextSetter.call(user: User.first, team: Team.first)
```

Most built in types do not need a formatter. A list of objects types that do not need a formatter can be found here:
```ruby
SystemObservability::ErrorContextSetter::TYPES_WITHOUT_FORMATTERS
```

#### Web Requests
Add user info to bugsnag when a request error occurs. This helper module will expect that `current_user` is set on the controller and will send the user info to Bugsnag. The data that's reported for the current user will rely on the formatter that's set up for the user object.

```ruby
class ApplicationController < ActionController::API
  # ...
  include SystemObservability::Rails::WebErrorReporter
end
```

### Datadog
Function calls are similar to those used in the included datadog gem.
However, tags are passed in as a hash, rather than an array.

```ruby
SystemObservability::Stats.increment(
  metric_name,
  tags: { team_id: 434, type: "something" }
)
```

The Stats instance will format the tags into the correct format for datadog, sending:
```ruby
["team_id:434", "type:something"]
```

#### Web Requests
Track web request timing automatically with the included helper module.

```ruby
class ApplicationController < ActionController::API
  # ...
  include SystemObservability::Rails::WebResponseTimer
end
```

This will send the following metrics to Datadog:
```
metric_name: "web.response.time"
tags: ["controller:some_controller", "http_method:get"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct
