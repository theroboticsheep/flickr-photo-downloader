Flickr Photo Downloader
=======================

Ruby script to download all the photos from a flickr album

Usage
-----

Checkout the code:

    git clone git://github.com/theroboticsheep/flickr-photo-downloader.git
    cd flickr-photo-downloader

Install bundler:

    gem install bundler
    bundle install

Change `FlickRaw.api_key` and `FlickRaw.shared_secret` value with your
[API key and shared secret](https://secure.flickr.com/services/apps/create/apply)

    FlickRaw.api_key        = "... Your API key ..."
    FlickRaw.shared_secret  = "... Your shared secret ..."

Change `flickr.access_token` and `flickr.access_secret` value with your
`access_token` and `access_secret` (you can get it with
[flickr_auth.rb](flickr_auth.rb))

    # Get your access_token & access_secret with flick_auth.rb
    flickr.access_token    = "... Your access token ..."
    flickr.access_secret   = "... Your access secret ..."

Run the script, specifying your album as the argument:

    ruby flickr-album-downloader.rb <album_id>

By default, album will be saved in folder `Pictures` on `user directory`
(eg /home/username/Pictures). If you want them to be saved to a
different directory, you can pass its name as an optional `-d` argument:

    ruby flickr-album-downloader.rb <album_id> -d ~/Pictures/My_Album


Enjoy!



License
-------

Source code released under an [MIT license](http://en.wikipedia.org/wiki/MIT_License)



Authors
-------

* **Dương Tiến Thuận** ([@mrtuxhdb](https://github.com/mrtuxhdb))
* **Nate Gallinger** ([@theroboticsheep](https://github.com/theroboticsheep))

