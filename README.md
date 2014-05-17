# Platform API

Ruby HTTP client for the Heroku API.

## Installation

Add this line to your application's Gemfile:

```
gem 'platform-api'
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install platform-api
```

## API documentation

Jump right to the [API documentation](http://heroku.github.io/platform-api/)
for the nitty gritty details.

## Usage guide

The best place to start using the Heroku API is the [Platform API Reference](https://devcenter.heroku.com/articles/platform-api-reference).
It has detailed descriptions of the HTTP API, including general information
about authentication, caching, object identifiers, rate limits, etc.  It also
includes detailed information about each supported resource and the actions
available for them.

The table of contents lists all the resources that are supported, such as App,
Add-on, Config Vars, Formation, etc.  Each resource includes detailed
information about the support actions.  For example, the [Formation](https://devcenter.heroku.com/articles/platform-api-reference#formation)
resource has [Info](https://devcenter.heroku.com/articles/platform-api-reference#formation-info), [List](https://devcenter.heroku.com/articles/platform-api-reference#formation-list), [Batch update](https://devcenter.heroku.com/articles/platform-api-reference#formation-batch-update), and [Update](https://devcenter.heroku.com/articles/platform-api-reference#formation-update) actions.

Resources and their related actions are available as methods on the client.
When the URL for an action includes parameters they're passed as arguments to
the method.  When the request expects a request payload it's passed as a Hash
in the final argument to the method.

For example, to get information about the `web` formation on the `sushi` app
you'd invoke `heroku.formation.info('sushi', 'web')` and it would return a
Ruby object that matches the one given in the [response example](https://devcenter.heroku.com/articles/platform-api-reference#formation-info).

The [API documentation] contains a description of all available resources and
methods.

### Handling errors

The client uses [Excon](https://github.com/geemus/excon) under the hood and
raises `Excon::Error` exceptions when errors occur.  You can catch specific
[Excon error types](https://github.com/geemus/excon/blob/master/lib/excon/errors.rb) if you want.

### A real world example

Let's go through an example of creating an app and using the API to work with
it.  The first thing you need is a client setup with an OAuth token.  You can
create an OAuth token using the `heroku-oauth` toolbelt plugin:

```bash
$ heroku plugins:install git@github.com:heroku/heroku-oauth.git
$ heroku authorizations:create -d "Platform API example token"
Created OAuth authorization.
  ID:          2f01aac0-e9d3-4773-af4e-3e510aa006ca
  Description: Platform API example token
  Scope:       global
  Token:       e7dd6ad7-3c6a-411e-a2be-c9fe52ac7ed2
```

Use the `Token` value when instantiating a client:

```ruby
require 'platform-api'
heroku = PlatformAPI.connect_oauth('e7dd6ad7-3c6a-411e-a2be-c9fe52ac7ed2')
```

The [OAuth article]()https://devcenter.heroku.com/articles/oauth has more information about OAuth tokens, including how to
create tokens with specific scopes.

Now let's create an app:

```ruby
heroku.app.create
=> {"id"=>22979756,
    "name"=>"floating-retreat-4255",
    "dynos"=>0,
    "workers"=>0,
    "repo_size"=>nil,
    "slug_size"=>nil,
    "stack"=>"cedar",
    "requested_stack"=>nil,
    "create_status"=>"complete",
    "repo_migrate_status"=>"complete",
    "owner_delinquent"=>false,
    "owner_email"=>"jkakar@heroku.com",
    "owner_name"=>nil,
    "domain_name"=>
     {"id"=>nil,
      "app_id"=>22979756,
      "domain"=>"floating-retreat-4255.herokuapp.com",
      "base_domain"=>"herokuapp.com",
      "created_at"=>nil,
      "default"=>true,
      "updated_at"=>nil},
    "web_url"=>"http://floating-retreat-4255.herokuapp.com/",
    "git_url"=>"git@heroku.com:floating-retreat-4255.git",
    "buildpack_provided_description"=>nil,
    "region"=>"us",
    "created_at"=>"2014/03/12 16:44:09 -0700",
    "archived_at"=>nil,
    "released_at"=>"2014/03/12 16:44:10 -0700",
    "updated_at"=>"2014/03/12 16:44:10 -0700"}
```

We can read the same information back with the `info` method.

```ruby
heroku.app.info('floating-retreat-4255')
=> {"id"=>22979756,
    "name"=>"floating-retreat-4255",
    "dynos"=>0,
    "workers"=>0,
    "repo_size"=>nil,
    "slug_size"=>nil,
    "stack"=>"cedar",
    "requested_stack"=>nil,
    "create_status"=>"complete",
    "repo_migrate_status"=>"complete",
    "owner_delinquent"=>false,
    "owner_email"=>"jkakar@heroku.com",
    "owner_name"=>nil,
    "domain_name"=>
     {"id"=>nil,
      "app_id"=>22979756,
      "domain"=>"floating-retreat-4255.herokuapp.com",
      "base_domain"=>"herokuapp.com",
      "created_at"=>nil,
      "default"=>true,
      "updated_at"=>nil},
    "web_url"=>"http://floating-retreat-4255.herokuapp.com/",
    "git_url"=>"git@heroku.com:floating-retreat-4255.git",
    "buildpack_provided_description"=>nil,
    "region"=>"us",
    "created_at"=>"2014/03/12 16:44:09 -0700",
    "archived_at"=>nil,
    "released_at"=>"2014/03/12 16:44:12 -0700",
    "updated_at"=>"2014/03/12 16:44:12 -0700"}
```

Let's add a Heroku PostgreSQL database to our app now:

```ruby
heroku.addon.create('floating-retreat-4255', {'plan' => 'heroku-postgresql:dev'})
=> {"config_vars"=>["HEROKU_POSTGRESQL_COBALT_URL"],
    "created_at"=>"2014-03-13T00:28:55Z",
    "id"=>"79a0c826-06be-4dcd-8bb5-f2c1b1bc2beb",
    "name"=>"heroku-postgresql-cobalt",
    "plan"=>
     {"id"=>"95a1ce4c-c651-45dc-aaee-79b4603e76b7",
      "name"=>"heroku-postgresql:dev"},
    "provider_id"=>"resource5924903@heroku.com",
    "updated_at"=>"2014-03-13T00:28:55Z"}
```

Excellent!  That will have added a config var which we can now see:

```ruby
heroku.config_var.info('floating-retreat-4255')
=> {"HEROKU_POSTGRESQL_COBALT_URL"=>"postgres://<redacted>"}
```

And there we go, we have the config var.  Let's set an additional config var,
which will also demonstrate how to make a request that needs a payload:

```ruby
heroku.config_var.update('floating-retreat-4255', {'MYAPP' => 'ROCKS'})
=> {"HEROKU_POSTGRESQL_COBALT_URL"=>"postgres://<redacted>",
    "MYAPP"=>"ROCKS"}
```

As you can see, any action that needs a request body takes it as a plain Ruby
object, as the final parameter of the method call.

Let's continue by deploying a sample app.  We'll use the
[Geosockets](https://github.com/heroku-examples/geosockets) example app:

```bash
$ git clone https://github.com/heroku-examples/geosockets.git
Cloning into 'geosockets'...
remote: Reusing existing pack: 489, done.
remote: Total 489 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (489/489), 1.95 MiB | 1.14 MiB/s, done.
Resolving deltas: 100% (244/244), done.
Checking connectivity... done.
$ cd geosockets
$ git remote add heroku git@heroku.com:floating-retreat-4255.git
$ heroku labs:enable websockets
$ heroku addons:add openredis:micro # $10/month
Adding openredis:micro on floating-retreat-4255... done, v10 ($10/mo)
Use `heroku addons:docs openredis` to view documentation.
$ git push heroku master
Initializing repository, done.
Counting objects: 489, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (229/229), done.
Writing objects: 100% (489/489), 1.95 MiB | 243.00 KiB/s, done.
Total 489 (delta 244), reused 489 (delta 244)
8< snip 8<
```

We can now use the API to see our `web` process running:

```ruby
heroku.formation.list('floating-retreat-4255')
=> [{"command"=>"coffee index.coffee",
     "created_at"=>"2014-03-13T04:13:37Z",
     "id"=>"f682b260-8089-4e18-b792-688cc02bf923",
     "type"=>"web",
     "quantity"=>1,
     "size"=>"1X",
     "updated_at"=>"2014-03-13T04:13:37Z"}]
```

Let's change `web` process to run on a 2X dyno:

```ruby
heroku.formation.batch_update('floating-retreat-4255',
                              {"updates" => [{"process" => "web",
                                              "quantity" => 1,
                                              "size" => "2X"}]})
=> [{"command"=>"coffee index.coffee",
     "created_at"=>"2014-03-13T04:13:37Z",
     "id"=>"f682b260-8089-4e18-b792-688cc02bf923",
     "type"=>"web",
     "quantity"=>1,
     "size"=>"2X",
     "updated_at"=>"2014-03-13T04:22:15Z"}]
```

We could have included a number of different kinds of processes in the last
command.  We can use the singular update action to modify a single formation
type:

```ruby
heroku.formation.update('floating-retreat-4255', 'web', {"size" => "1X"})
=> {"command"=>"coffee index.coffee",
    "created_at"=>"2014-03-13T04:13:37Z",
    "id"=>"f682b260-8089-4e18-b792-688cc02bf923",
    "type"=>"web",
    "quantity"=>1,
    "size"=>"1X",
    "updated_at"=>"2014-03-13T04:24:46Z"}
```

Hopefully this has given you a taste of how the client works.  If you have
questions please feel free to file issues.

### Building API documentation

Build documentation with:

```
rake yard
```

And then visit `docs/index.html` to read it.  Alternaltely, build and publish
it to Github Pages in one step with:

```
rake publish
```

### Debugging

Sometimes it helps to see more information about the requests flying by.  You
can start your program or an `irb` session with the `EXCON_DEBUG=1`
environment variable to cause request and response data to be written to
`STDERR`.

### Passing custom headers

The various `connect` methods take an options hash that you can use to include
custom headers to include with every request:

```ruby
client = PlatformAPI.connect('my-api-key', default_headers: {'Foo' => 'Bar'})
```

### Using a custom cache

By default, the `platform-api` will cache data in `~/.heroics/platform-api`.
Use a different caching by passing in the [Moneta](https://github.com/minad/moneta)
instance you want to use:

```ruby
client = PlatformAPI.connect('my-api-key', cache: Moneta.new(:Memory))
```

### Connecting to a different host

Connect to a different host by passing a host option:

```ruby
client = PlatformAPI.connect('my-api-key', host: 'api.example.com')
```

Connections are always made using HTTPS and certificates verification is
always enabled.

## Generating from Heroics

The platform API client can be re-generated from a raw schema with [Heroics](https://github.com/interagent/heroics):

```
$ curl -o schema.json -H "Accept: application/vnd.heroku+json; version=3" https://api.heroku.com/schema
$ bin/heroics-generate -H "Accept: application/vnd.heroku+json; version=3" -c "#{Dir.home}/.heroics/platform-api" PlatformAPI schema.json https://api.heroku.com > lib/platform-api/client.rb
```

## Contributing

1. [Fork the repository](https://github.com/heroku/platform-api/fork).
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create new pull request.
