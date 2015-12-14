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

> ruby get_data.rb 1\s\s
OR
> ruby get_data.rb 1 word_count.json\s\s
OR
> ruby get_data.rb 1 word_count.json safe\s\s

## Command Line Arguments
get_data.rb can take three arguments
* time_in_min: This is required and assumed to be in minutes for simplicity
* existing_filename.json: Not required, but if provided, continues count of words from current list. Must be json object of key-value pairs.
* safe: Not required. Provides safe mode for execution where the state of the word count is saved during execution

## General Summary of Functionality
