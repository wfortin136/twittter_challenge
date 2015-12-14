# Twitter Challenge for Avant
*Billy Fortin*
*wjf136@gmail.com*

## Requirements and Environment
* Developed with Ruby 2.2
* Requires TweetStream gem: https://github.com/tweetstream/tweetstream
* Run on local Unix Machine (OSX 10.11)

## Instructions to Run
From command line:

> ruby get_data.rb [time_in_min] [existing_filename.json] [safe]

Examples below
> ruby get_data.rb 1

OR
> ruby get_data.rb 1 word_count.json

OR
> ruby get_data.rb 1 word_count.json safe

## Command Line Arguments
get_data.rb can take three arguments
* time_in_min: This is required and assumed to be in minutes for simplicity
* existing_filename.json: Not required, but if provided, continues count of words from current list. Must be json object of key-value pairs.
* safe: Not required. Provides safe mode for execution where the state of the word count is saved during execution

## General Summary of Functionality
Initially, I create a connection to the TwitterStream  API using TweetStream. Initially I was going to directly oauth-ruby gem (https://github.com/intridea/oauth2), but the TweetStream is fairly robust and provides a very clean interface to the API.

Once I obtain the connection, I spawn two different threads. The first thread constantly gets tweet samples and populates an array which stores all all tweet objects. The second thread concurrently evaluates the same tweet array pulling tweet objects from the front. The main thread sleeps for the defined amount of minutes given by user.

Once the timer is up, the main thread kills execution of the first thread. The main thread then halts while the second thread finishes evaluating all tweets in the array. Once the second thread completes, the main thread continues, saves a final version of the word count to a json file and prints out the top 10 words.

For part B, I added the safe run option which saves the state of the word count after each tweet is evaluated. It noticibly slows down run-time, so I made it as an optional configuration. I was torn between a controlled user intitialized stop that could save state within the program, or any execution stop, including unexpected or user initiated. With the latter, the state would not be able to be saved which seemed like the more common occurence, so I designed for this implementation.
