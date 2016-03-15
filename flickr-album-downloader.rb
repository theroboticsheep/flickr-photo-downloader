#!/usr/bin/env ruby
# Filename: flick-album-downloader.rb
# Description: Easily download all the photos from a flickr album

require 'rubygems'
require 'bundler'
require 'fileutils'
require 'optparse'
Bundler.require
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = nil

# Get your API Key: https://secure.flickr.com/services/apps/create/apply
FlickRaw.api_key       = "... Your API key ..."
FlickRaw.shared_secret = "... Your shared secret ..."

# Get your access_token & access_secret with flick_auth.rb
flickr.access_token    = "... Your access token ..."
flickr.access_secret   = "... Your access secret ..."

begin
  login = flickr.test.login
  puts "You are now authenticated as #{login.username}"
rescue FlickRaw::FailedResponse => e
  puts "Authentication failed : #{e.msg}"
end

options = { :album_id => [], :directory => ENV["HOME"] + "/Pictures"}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage:  #{File.basename(__FILE__)} [OPTIONS] OTHER_ARGS"

  opts.separator ""
  opts.separator "Specific Options:"

  opts.on("-d", "--directory DIRECTORY",
          "Directory to save pictures") do |dir|
    options[:directory] = dir
  end

  opts.separator "Common Options:"

  opts.on("-h", "--help",
          "Show this message." ) do
    puts opts
    exit
  end
end

begin
  optparse.parse!
  options[:album_id] = ARGV
rescue
  puts optparse
  exit
end

album_id    = options[:album_id]
$directory   = options[:directory]
$album_title = "New Album"

def save_image(photo_list)
  concurrency = 8

  puts "Downloading #{photo_list.count} photos from flickr with concurrency=#{concurrency} ..."
  FileUtils.mkdir_p($directory)

  photo_list.each_slice(concurrency).each do |group|
    threads = []
    group.each do |photo|
      threads << Thread.new {
        begin
          url = photo["url_o"]
          file = Mechanize.new.get(url)
          extension = File.basename(file.uri.to_s.split('.').last)
          filename = photo["photo_index"].to_s + ' ' + photo["title"]
          if filename.split('.').last != "jpg"
            filename += '.' if filename.split('').last != '.'
            filename += extension
          end
          filename.gsub! '/', '-'
          $album_title.gsub! '/', '-'

          if File.exists?("#{$directory}/#{$album_title}/#{filename}") and Mechanize.new.head(url)["content-length"].to_i === File.stat("#{directory}/#{$album_title}/#{filename}").size.to_i
            puts "Already have #{filename}"
          else
            puts "Saving photo #{filename}"
            file.save_as("#{$directory}/#{$album_title}/#{filename}")
          end

        rescue Mechanize::ResponseCodeError
          puts "Error getting file, #{$!}"
        end
      }
    end
    threads.each{|t| t.join }
  end
end

f_photoset       = flickr.photosets.getInfo(:photoset_id => album_id.first)
f_photoset_id    = f_photoset["id"]
f_photoset_count = f_photoset["photos"]
f_page_count     = (f_photoset_count.to_i / 500.0).ceil
f_current_page   = 1

$album_title = f_photoset["title"]
photo_index = 1

while f_current_page <= f_page_count
  FlickRaw_list = flickr.photosets.getPhotos(:photoset_id => f_photoset_id,
                                          :extras => "url_o",
                                          :page => f_current_page,
                                          :per_page => "500")

  FlickRaw_list = FlickRaw_list["photo"]
  photo_list = []

  FlickRaw_list.each do |photo|
    photo_list.push({"url_o"=>photo["url_o"], "title"=>photo["title"], "photo_index"=>photo_index})
    photo_index += 1
  end

  save_image(photo_list)
  f_current_page += 1

end

puts "Done."
