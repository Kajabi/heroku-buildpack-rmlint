# heroku-buildpack-rmlint

Add support for running [`rmlint`](https://rmlint.readthedocs.io) during build to reduce slug size.

It is strongly encouraged that you understand the ramifications of running `rmlint`. See [Cautions (or why it’s hard to write a dupefinder)](https://rmlint.readthedocs.io/en/latest/cautions.html) for how things can go wrong.

## Usage

This buildpack is not meant to be used on its own, and instead should be in used in combination with Heroku's [multiple buildpack support](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app).

Include a script that calls `rmlint` (and probably `./rmlint.sh`) in `.heroku/rmlint.sh`.

```sh
# Including hidden files is usually okay, Heroku doesn't include the .git
# directory in the build directory
--hidden

# Use byte-for-byte comparison instead of hashing
--paranoid

# We don't want to delete anything, but hardlinking when possible should reduce
# the slug size
-c sh:hardlink
```

The buildpack should come after any buildpacks that you want to remove duplicates in.

```sh
$ heroku buildpacks:add https://github.com/Kajabi/heroku-buildpack-rmlint
```

Removing duplicates is disabled by default. To enable actually running the removal script, set the `RMLINT_RUN_SCRIPT` config var:

```
$ heroku config:set RMLINT_RUN_SCRIPT=1
```

It can be useful to not set this config var initially so that you can check the results or run a test on a one-off dyno.

If you override the `sh` output, the script will not be run. E.g.

```
# This will output the sh file into tmp but the buildpack will not run it,
# though it could be then run in a release phase, for instance.
-o sh:tmp/rmlint.sh
```

## License

MIT
