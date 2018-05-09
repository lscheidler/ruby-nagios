# Nagios

Provides a basic nagios plugin class for easier plugin development

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nagios', git: 'https://github.com/lscheidler/ruby-nagios'
```

And then execute:

    $ bundle

## Usage

### Examples

For examples see examples/ directory

### Basic initialization
```ruby
require 'bundler/setup'

require 'nagios'

class MyPlugin < Nagios::Plugin
  def initialize value
    super() do
      # nagios check code
    end
  end

  # set plugin defaults
  def set_plugin_defaults
  end
end
```

### Helpers

#### Early exit

The plugin exists after running the complete block, but You can exit earlier, if some prechecks failed:

```ruby
# prechecks
...

# exit with message, if one of the prechecks are critical/warning/unknown
exit_with_msg if failed?

# checks
...
```

#### check, if value is nil

```ruby
expect_not_nil 'not_nil', nil
#=> critical

expect_not_nil 'not_nil', nil, status: :unknown
#=> unknown

expect_not_nil 'not_nil', ''
#=> ok
```

#### check, if value is empty

```ruby
expect_not_empty 'not_empty', ''
#=> critical

expect_not_empty 'not_empty', '', status: :unknown
#=> unknown

expect_not_nil 'not_empty', 'a'
#=> ok

expect_not_empty 'not_empty', []
#=> critical

expect_not_empty 'not_empty', [], status: :unknown
#=> unknown

expect_not_nil 'not_empty', ['a']
#=> ok
```

#### check value against a level

```ruby
expect_level 'name', 5, warning_level: 5, critical_level: 10
#=> ok

expect_level 'name', 6, warning_level: 5, critical_level: 10
#=> warning

expect_level 'name', 10, warning_level: 5, critical_level: 10
#=> warning

expect_level 'name', 11, warning_level: 5, critical_level: 10
#=> critical
```

#### check percentage of value against a level

```ruby
expect_percentage_level 'name', 5, 100, warning_level: 5, critical_level: 10
#=> ok

expect_percentage_level 'name', 6, 100, warning_level: 5, critical_level: 10
#=> warning

expect_percentage_level 'name', 10, 100, warning_level: 5, critical_level: 10
#=> warning

expect_percentage_level 'name', 11, 100, warning_level: 5, critical_level: 10
#=> critical
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lscheidler/ruby-nagios.


## License

The gem is available as open source under the terms of the [Apache 2.0 License](http://opensource.org/licenses/Apache-2.0).

