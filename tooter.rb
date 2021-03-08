#!/usr/bin/env ruby

require 'twitter'
require 'mastodon'
require 'redis'

twitter = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV["TWITTER_KEY"]
  config.consumer_secret = ENV["TWITTER_SECRET"]
  config.bearer_token = ENV["TWITTER_TOKEN"]
end

mastodon = Mastodon::REST::Client.new(
  base_url: ENV["MASTODON_INSTANCE"],
  bearer_token: ENV["MASTODON_TOKEN"]
)

redis = Redis.new(host: ENV["REDIS"] || "localhost")

puts "Syncing Twitter -> Mastodon"
last = redis.get("LAST_TWEET")
puts "  Last tweet was: #{last}"

puts "Getting tweets..."
tweets = twitter.user_timeline(ENV['TWITTER_USER'])

if last.nil?
  puts "  Setting last tweet to first since this is first run: #{tweets.first.uri}"
  redis.set("LAST_TWEET", tweets.first.uri)
  exit
end

new_tweets = tweets.take_while { |t| t.uri.to_s != last }.reverse

if new_tweets.any?
  puts "Posting tweets to mastodon!"
  new_tweets.each do |t|
    puts "  Tooting #{t.uri}"
    status = mastodon.create_status(
      t.full_text,
      spoiler_text: "From My Twitter",
      visibility: "public"
    )
    puts "  Created status: #{status.uri}"

    redis.set("LAST_TWEET", t.uri)
  end
else
  puts "  No new tweets."
end
