# Hub Applicatif

This is the main ITG app which embed "Bureau Consultant", "Fiches Services" and
"goxygene" engines as submodules.

## Setup

This app can be run using Ruby 2.6.3.

It needs PostgreSQL, Redis and Memcache.

If you're running MacOS you can get it from [Brew](https://brew.sh):

``` sh
brew install postgresql redis memcached
```

and run it:

``` sh
pg_ctl -D /usr/local/var/postgres start
redis-server /usr/local/etc/redis.conf
/usr/local/opt/memcached/bin/memcached
```

### Dependencies

First you should get Ruby dependencies, some are privately hosted so you need to
supply an environment variable to be able to authenticate:

``` sh
BUNDLE_GEMS__ITG__FR=XXXXX bundle install
```

`XXXXX` has to be replaced by your personal access token to the private gems
repository.

You can then get submodules needed by the app:

``` sh
git submodule init
git submodule update
```

Be sure to use the right branch for each submodule:

- `vendor/engines/bureau_consultant/`: `bureau_goxygene`
- `vendor/engines/fiches_services`: `develop`
- `vendor/engines/goxygene`: `develop`

### Databases

You can now create setup databases in `config/database.yml` with something like:

``` yaml
default: &default
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  encoding: unicode

development:
  <<: *default
  adapter: postgresql
  encoding: unicode
  database: goxygene_development

cms_development:
  <<: *default
  adapter: postgresql
  encoding: unicode
  database: services_development 

test:
  <<: *default
  database: goxygene_test 

cms_test:
  <<: *default
  adapter: postgresql
  encoding: unicode
  database: services_test

```

As you can see we'll be using two databases at once. One for `goxygene` and the
other one for `fiches_services`.

It's now time to create databases:

``` sh
bin/rake db:create
```

To be able to start using the app you'll need to feed databases with dumps. You
can get it from [Plan.io documents](https://itg.plan.io/documents/9). You'll
need to retrieve `goxygene_production-20201102_0133.sql.bz2 ` and
`fiches_services.sql.bz2`.

Once you got it you can import data in your databases:

``` sh
bunzip2 < goxygene_production-20201102_0133.sql.bz2 | psql goxygene_development
bunzip2 < fiches_services.sql.bz2 | psql services_test
```

## Running the app

The first thing you should do is to take back control of an existing user in
database:

``` sh
bin/rails c
```

``` ruby
CasAuthentication.find_by(login: "conseil@itg.fr").update(password: "password")
```

Thanks to this you'll be able to log in with "conseil@itg.fr" / "password"
credentials. This user can go pretty much anywhere and even impersonates
consultant user of you choice.

Now run the app:

``` sh
bin/rails c
```

and you'll be able to access the app through your browser at
`http://localhost:3000`.

Don't forget to also run the [CAS
app](https://github.com/ITGCONSEIL/oxygene-cas/tree/develop) or you won't be
able to log in.

## How to run the test suite

~~~~
RAILS_ENV=test bundle exec rake db:structure:load
RAILS_ENV=test bundle exec rake db:fixtures:load
RAILS_ENV=test bundle exec rake test
~~~~

### How to run a single file from the test suite

~~~~
RAILS_ENV=test bundle exec rake test TEST=test/controllers/xyz.rb
~~~~

### How to run a single test file from a test file


~~~~
RAILS_ENV=test bundle exec rake test TEST=test/controllers/xyz.rb TESTOPTS='-n "/test name/"'
~~~~

=======

