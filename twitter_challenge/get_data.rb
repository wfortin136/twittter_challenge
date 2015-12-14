require 'rubygems'
require 'tweetstream'

# save ruby object as json
def save_json(object, name)
  object_json = object.to_json
  File.open(name+".json", "w") do |f|
    f.write(object_json)
  end
end

time = ARGV[0].to_i
if ARGV[1]
  existing_file_count = ARGV[1]
  file = File.open(ARGV[1], "r+").read
  word_count = JSON.parse(file)    # parse json to ruby object
else
  word_count = Hash.new
end

safe_flag =false
if ARGV[2]
  if ARGV[2] == "safe"
    safe_flag = true
  else
    puts "Did not recognize #{ARGV[2]} command. Only accpetable command is 'safe' or leave empty"
  end
end

stop_words = File.open("stop-word-list.txt", "r").read

TweetStream.configure do |config|
    config.consumer_key       = 'PEF5yBs0mt99PrzgwTPr61Ahe'
    config.consumer_secret    = 'NGFIHSCf4Psdc6jKuoWEixcITcTAbAgdekdgJOdLqHCJEbtZYG'
    config.oauth_token        = '4475963182-hTAqeR4j19f1JcTZWJz6jrD0ILs30Yw4KnPCiK4'
    config.oauth_token_secret = 'Ot0fdCPlxLIChnFoJ7eLjss5wTgeJTaA2bNBgESgGtf3I'
    config.auth_method        = :oauth
end

client = TweetStream::Client.new
errors = []
tweets = []

client.on_error do |error|
  puts "#{error.text}"
  errors.push(error)
end

tweets_thr = Thread.new{

  #puts " Thread 2"
  client.sample do |tweet|
    tweets.push(tweet)
  end
}

parse_thr = Thread.new{
  #puts "Thread 3"
  while (tweets_thr.status || tweets.length>0)
    if tweets.length>0
      t = tweets.shift
      words = t.text.split
      words.each do |w|
        if !(stop_words.include? w.downcase)
          if word_count.key?(w)
            word_count[w] = word_count[w] + 1
          else
            word_count[w]= 1
          end
        end
      end
      if safe_flag
        save_json(word_count, "word_count_backup")
        system 'mv word_count_backup.json word_count.json'
      end
    end
  end
}

puts "Start"
for i in 1..time
  delim = 5
  count = (60/delim).to_i
  for x in 1..count
    sleep(delim)
    print "."
    #puts x*delim
  end
  puts " #{i} Minute(s)"
end

Thread.kill(tweets_thr)
parse_thr.join

save_json(word_count, "word_count")
count =0
word_count.sort_by{|word, count| count}.reverse.each do |w,c|
  count += 1
  puts "#{count}) #{c}: #{w} "
  if count==10
    break
  end
end

