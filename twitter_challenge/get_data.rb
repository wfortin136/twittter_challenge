require 'rubygems'
require 'tweetstream'

TweetStream.configure do |config|
    config.consumer_key       = 'PEF5yBs0mt99PrzgwTPr61Ahe'
    config.consumer_secret    = 'NGFIHSCf4Psdc6jKuoWEixcITcTAbAgdekdgJOdLqHCJEbtZYG'
    config.oauth_token        = '4475963182-hTAqeR4j19f1JcTZWJz6jrD0ILs30Yw4KnPCiK4'
    config.oauth_token_secret = 'Ot0fdCPlxLIChnFoJ7eLjss5wTgeJTaA2bNBgESgGtf3I'
    config.auth_method        = :oauth
end

puts "Test"

TweetStream::Client.new.track('the') do |status|
  # The status object is a special Hash with
  # method access to its keys.
  puts "#{status.text}"
end
