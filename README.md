# Shorthanded

Automatically deploy an app to Heroku and add a CNAME for it in DNSimple. Go
from zero to `http//dry-pine.mysite.com` in under a minute.

This is part of a larger project to make it easy to automatically deploy one
application for multiple people, each of whom gets a unique URL for their
deployment of the application.

## What's the API?

`POST /apps`

Required header: `Accept: application/vnd.shorthanded+json; version=1`

Returns JSON.

#### Success

Status code: 201 Created

```json
{
  "url": "http://dry-pine.mysite.com"
}
```

#### Failure

Status code: 502 Bad Gateway

Failure is directly from Heroku's create action, because that's the only thing
that should fail, and even that is unlikely:

```json
{
  "id": "invalid_params",
  "message": "Name is already taken"
}
```

## OK, how do I deploy this?

You can push it to Heroku like any other app. Most of the functionality is
controlled by environment variables:

| Name | Meaning | Example |
|---|---|---|---|---|
| `HEROKU_APP_NAME_PREFIX` | A short (<= 7 characters) string that will be used as the prefix of each Heroku app to make autogenerated apps easy to find in the Heroku console. If  you want a longer prefix, change how long a SecureRandom string gets generated in HerokuAppNameGenerator. | shorty- |
| `HEROKU_OAUTH_TOKEN` | Get one using instructions in [their docs]. | aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa |
| `URL_OF_TAR_GZ_TO_DEPLOY` | Heroku has an API to take in .tar.gz of apps with an [app.json](https://devcenter.heroku.com/articles/app-json-schema) in the root. If you add an `app.json` to your app on GitHub, GitHub will gladly generate a .tar.gz for you on the fly using a URL like `https://github.com/gabebw/shorthanded/tarball/master` | https://github.com/gabebw/shorthanded/tarball/branch-name |
| `DNSIMPLE_DOMAIN` | The domain name (WITHOUT a scheme like `http://`) to add a subdomain for. Must have DNS controlled by DNSimple. |  `example.com` |
| `DNSIMPLE_DOMAIN_TOKEN` | DNSimple has a couple different ways to authenticate against [their API]. Shorthanded uses the domain token because it gives the least access to a user's account. You can find it under the "settings" for a specific domain on DNSimple's website. | 3125f1af24979e2f821ef829bc8040a5 |

[their docs]: https://github.com/heroku/platform-api#a-real-world-example
[their API]: http://developer.dnsimple.com/overview/

## Local development

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

After setting up, you can run the application using [foreman]:

    % foreman start

If you don't have `foreman`, see [Foreman's install instructions][foreman]. It
is [purposefully excluded from the project's `Gemfile`][exclude].

[foreman]: https://github.com/ddollar/foreman
[exclude]: https://github.com/ddollar/foreman/pull/437#issuecomment-41110407

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)

## Deploying

If you have previously run the `./bin/setup` script,
you can deploy to staging and production with:

    $ ./bin/deploy staging
    $ ./bin/deploy production
