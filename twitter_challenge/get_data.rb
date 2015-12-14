require 'rubygems'
require 'tweetstream'

#########################################################
##################Ruby Methods###########################
# get the itme value from command line
def get_time(args)
  # get time window for collecting tweets, in minutes
  if args[0]
    return time = args[0].to_i
  else
    puts "Missing time windw for data collection"
  end
   
end

# get existing file from command line as input by user
def get_existing_file(args)
  # get word count json file to continue counting if input by user
  if args[1]
    file = File.open(args[1], "r+").read # read/write from json file
    return JSON.parse(file)        # parse json to ruby object
  else
    return Hash.new                # no file, create new hash
  end
end

# safe_run directs the program to make intermediate saves of the word_count during execution
# as a backup in case of unexpected process ending or closure. Dramtically reduces speed
def safe_run(args)
  $safe_flag =false
  if args[2] # if the value is given by user
    if args[2] == "safe"  # value must be the word 'safe'
      return true
    else
      puts "Did not recognize #{args[2]} command. Only accpetable command is 'safe' or leave empty"
      return false
    end
  end
end

# save ruby object as json
def save_json(object, name)
  object_json = object.to_json
  File.open(name+".json", "w") do |f|
    f.write(object_json)
  end
end


# parse and count tweets
def tweet_eval
  # We want to keep looping through tweets array as long tweets_thr is still
  # collecting or we still have tweets to evaluate
  while ($tweets_thr.status || $tweets.length>0)
    if $tweets.length>0
      t = $tweets.shift                          # get and remove first element of array
      words = t.text.split                      # get text of tweets and break into array of words    
      words.each do |w|
        if !($stop_words.include?(w.downcase))    # determine if word is included in stop list set
          if $word_count.key?(w)                 # if word is already in word count
            $word_count[w] = $word_count[w] + 1   # increment count
          else
            $word_count[w]= 1                    # if new word, add to hash with value of 1
          end
        end
      end
      if $safe_flag                                        # if safe is designated by user
        # need to save to an intermediate file (word_count_backup.json) then rename
        # to new file word_count.json. This ensures we don't lose data if we end execution
        # during the write portion of save_js. The worst we lose is the count updates of the
        # latest tweet, but not previous word_count tweets
        save_json($word_count, "word_count_backup")         # save to intermediate file
        system 'mv word_count_backup.json word_count.json' # rename to final file
      end
    end
  end

end

# timer for tweet runtime
# input time is assumed to be in minutes
def run_timer(time)
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
end

# Print top number of values by count in descending order.
# lim is an integer that will take the top lim values
def print_top(lim)
  count=0
  # sort hash by count value and reverse order for descending
  $word_count.sort_by{|word, count| count}.reverse.each do |w,c|
    count += 1
    puts "#{count}) #{c}: #{w} "
    if count==lim #top number of values
      break
    end
  end
end
#############################################################

## Get command line arguments

time = get_time(ARGV)
$word_count = get_existing_file(ARGV)
$safe_flag = safe_run(ARGV)

# get list of stop arrays
# save as set for better performance during parse and compare 
$stop_words = Set.new(File.open("stop-word-list.txt", "r").read.split)

# Use tweetstream gem to make OAuth connection to twitter api
# Values are unique for each user account and app
TweetStream.configure do |config|
    config.consumer_key       = 'PEF5yBs0mt99PrzgwTPr61Ahe'
    config.consumer_secret    = 'NGFIHSCf4Psdc6jKuoWEixcITcTAbAgdekdgJOdLqHCJEbtZYG'
    config.oauth_token        = '4475963182-hTAqeR4j19f1JcTZWJz6jrD0ILs30Yw4KnPCiK4'
    config.oauth_token_secret = 'Ot0fdCPlxLIChnFoJ7eLjss5wTgeJTaA2bNBgESgGtf3I'
    config.auth_method        = :oauth
end

# new client
client = TweetStream::Client.new
errors = []
$tweets = [] #tweets will be treated as a FIFO queue using push and shift

# show and record any errors during connection
client.on_error do |error|
  puts "#{error.text}"
  errors.push(error)
end

# spawn new thread that collects tweets and stores them as twitter objects in array
$tweets_thr = Thread.new{
  #puts " Thread 2"
  
  # get some randomized sample of tweets from twitter (statuses/sample)
  client.sample do |tweet|
    $tweets.push(tweet) # push each tweet to end of array
  end
}

# spawn new thread that evaluates tweets and makes word count
parse_thr = Thread.new{
  #puts "Thread 3"
  tweet_eval
}

#execute run timer from time given at command line. Time is assumed to be in minutes
run_timer(time)

# timer is up, kill sollection thread
Thread.kill($tweets_thr)

# hold current thread till parse thread finishes word_count of tweets. Once parse_thr
# completes execution, current thread will resume
parse_thr.join

#save word_count
save_json($word_count, "word_count")

# output top 10
print_top(10)
