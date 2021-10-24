# Renzu

Renzu is a basic (but dangerous) tool that can be used to expose a set of scripts and programs as API endpoints over network connections. It bears resemblance to older tools like PyJOJO that was exposing an entire set of shell scripts as API endpoints.

Using it, you can expose something like `mailq` under `/api/mailq`, a cache cleaning script under `/api/cache/clean` or deploy a new version as `/api/deploy/:revision`.

## Installation

At the time being, you need to build Renzu yourself in order to install it.

```
git clone $REPO
cd $REPO
crystal build src/renzu.cr
```

## Usage

You need to either create `actions.yml` or copy the existing `actions.yml.sample` and edit accordingly. By default, `renzu` listens on `127.0.0.1:8192` and searches for `action.yml` in the current directory.

The structure of `actions.yml` is an array of route/actions pairs. Per any route, one or many actions can be defined. Furthermore, any route can define `:segments` such as `/say/:greeting/to/:user`, and the values picked up from the `:segments` can then be used in the action that will be run, with that data passed as a parameter, if you need.

Eg:

```yml
- route: /say/:greeting/to/:user
  actions:
    - echo :greeting :user
    - echo goodbye :user
```
If you hit that endpoint as `/say/hello/to/john`, the remote system is going to run the 2 commands and you should see the following output:

```shell
# curl http://localhost:8192/say/hello/to/john
hello john
goodbye john
```

Renzu is further configurable using the following ENV variables:

- `PORT` - listens to `TCP:8192` by default
- `HOST_BINDING` - binds to `127.0.0.1` by default
- `CONFIG` - reads routes & actions from `actions.yml` in local directory by default

## Warning

If, for some reason, you decide you want to shoot yourself in the foot with a powerful gun, you'll still need the following:
  - a supervisor like supervisord to babysit and log output for future reference
  - a web server like apache, nginx, caddy with some form of authentication (basic auth / Oauth2) that proxies to renzu
  - SSL certificates to encrypt the connection (caddy does this out of the box)
  - even better, some VPN from you to the machine hosting renzu


## Development

```shell
git clone $REPO
cd $REPO
copy actions.yml.sample actions.yml
# ...edit actions.yml to have some basic config
crystal run dev/sentry.cr   # simulate something akin to hot autoreload
# ...hack away at it
```

## Contributing

1. Fork it (<https://github.com/kiinoda/renzu/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [George R. NICA](https://github.com/kiinoda) - creator and maintainer
