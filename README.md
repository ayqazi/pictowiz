# Description

An app for storing, retrieving, and converting images

# Requirements

Must have ImageMagick command line tools installed and available in the path

# Running

```
$ bundle install
$ bundle exec rspec
$ bin/server

$ curl -vv -X POST --data-binary @spec/fixtures/images/testimage.png -H 'Content-Type: image/png' http://localhost:4567/images
# Then open the URLs in the JSON response in a browser
```
