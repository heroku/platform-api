# Platform API

Ruby HTTP client for the Heroku API.

## Installation

Add this line to your application's Gemfile:

```
gem 'heroics'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install heroics
```

## Usage guide

The best place to start using the Heroku API is the [Platform API Reference](https://devcenter.heroku.com/articles/platform-api-reference).
It has detailed descriptions of the HTTP API, including general information
about authentication, caching, object identifiers, rate limits, etc.  It also
includes detailed information about each support resource and the actions
supported for those resources.

The table of contents includes a list of all the resources that are supported,
such as App, Add-on, Config Vars, Formation, etc.  Each resource includes
detailed information about the support actions.  For example, the [Formation](https://devcenter.heroku.com/articles/platform-api-reference#formation)
resource has [Info](https://devcenter.heroku.com/articles/platform-api-reference#formation-info), [List](https://devcenter.heroku.com/articles/platform-api-reference#formation-list), [Batch update](https://devcenter.heroku.com/articles/platform-api-reference#formation-batch-update), and [Update](https://devcenter.heroku.com/articles/platform-api-reference#formation-update) actions.

You can easily map any resource and its related action client methods.  The
formation actions above are accessed as `client.formation.info`,
`client.formation.list`, `client.formation.batch_update` and
`client.formation.update`.  When the URL for one of these actions includes
parameters they should be passed as arguments to the method.  When the request
expects a request payload it should be passed as a Ruby Hash in the final
argument to the method.

For example, to get information about the `web` formation on the `sushi` app
you'd invoke `client.formation.info('sushi', 'web')` and it would return a
Ruby object that matches the one given in the [response example](https://devcenter.heroku.com/articles/platform-api-reference#formation-info).

Once you get used to these basic patterns using the client is quite easy
because it's mapped directly from the documentation.  Below we'll go through
some more detailed examples to give a better idea about how it works.

### 

The first thing you need is a client that's setup with your username and API
token.

```ruby
require 'platform-api'

client = PlatformAPI.connect('username', 'token')
```

You can find your API token by clicking the *Show API Key* on your [account
page](https://dashboard.heroku.com/account).

## Contributing

1. [Fork the repository](https://github.com/heroku/platform-api/fork).
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create new pull request.
