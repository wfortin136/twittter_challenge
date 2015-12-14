require 'rubygems'
require 'tweetstream'

TweetStream.configure do |config|
    config.consumer_key       = 'PEF5yBs0mt99PrzgwTPr61Ahe'
    config.consumer_secret    = 'NGFIHSCf4Psdc6jKuoWEixcITcTAbAgdekdgJOdLqHCJEbtZYG'
    config.oauth_token        = '4475963182-hTAqeR4j19f1JcTZWJz6jrD0ILs30Yw4KnPCiK4'
    config.oauth_token_secret = 'Ot0fdCPlxLIChnFoJ7eLjss5wTgeJTaA2bNBgESgGtf3I'
    config.auth_method        = :oauth
end

client = TweetStream::Client.new
tweets = []
errors = []
word_count = Hash.new

client.on_error do |error|
  puts "#{error.text}"
  errors.push(error)
end

tweets_thr = Thread.new{

  puts " Thread 2"
  client.sample do |tweet|
    # The status object is a special Hash with
    # method access to its keys.
    #puts "#{status.text}"
    tweets.push(tweet)
  end
}

parse_thr = Thread.new{
  puts "Thread 3"
  while (tweets_thr.status || tweets.length>0)
    if tweets.length>0
      t = tweets.shift
      #puts "#{t.text}"
      words = t.text.split
      words.each do |w|
        if word_count.key?(w)
          word_count[w] = word_count[w] + 1
        else
          word_count[w]= 1
        end
      end
    end
  end
}
sleep(5)
Thread.kill(tweets_thr)
parse_thr.join

count =0
word_count.sort_by{|word, count| count}.reverse.each do |w,c|
  count += 1
  puts "#{count}) #{c}: #{w} "
  if count==10
    break
  end
end

