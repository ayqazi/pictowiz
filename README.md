# Description

An app for storing, retrieving, and converting images.

This prototype takes any image of a type supported by GraphicsMagick
and converts it to a JPEG and a PNG, returning the URLs for the new
images.

# Requirements

Must have GraphicsMagick command line tools installed and available in
the path, e.g. like this:

```
apt install graphicsmagick
```

# Running

```
$ bundle install
$ bundle exec rspec
$ bin/server

$ curl -vv -X POST --data-binary @spec/fixtures/images/testimage.png -H 'Content-Type: image/png' http://localhost:4567/images
# Then open the URLs in the JSON response in a browser
```
