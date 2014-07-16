# Description:
#   Allows users to post a tweet to Twitter using common shared
#   Twitter accounts.
#
#   Requires a Twitter consumer key and secret, which you can get by
#   creating an application here: https://dev.twitter.com/apps
#
#   Based on KevinTraver's twitter.coffee script: http://git.io/iCQPyA
#
#   HUBOT_TWEETER_ACCOUNTS should be a string that parses to a JSON
#   object that contains access_token and access_token_secret for each
#   twitter screen name you want to allow people to use.
#
#   For example:
#   {
#     "hubot" : { "access_token" : "", "access_token_secret" : ""},
#     "github" : { "access_token" : "", "access_token_secret" : ""}
#   }
#
# Commands:
#   hubot tweet@<screen_name> <update> - posts <update> to Twitter as <screen_name>
#   hubot untweet@<screen_name> <tweet_url_or_id> - deletes <tweet_url_or_id> from Twitter
#   hubot retweet@<screen_name> <tweet_url_or_id> - <screen_name> retweets <tweet_url_or_id>. Alias: rt@<screen_name>
#
# Dependencies:
#   "twit": "1.1.8"
#   "twitter-text": "1.7.x"
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#   HUBOT_TWEETER_ACCOUNTS
#
# Author:
#   jhubert
#
# Repository:
#   https://github.com/jhubert/hubot-tweeter

Helpers = require './tweeter-helpers'

config =
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET
  accounts_json: process.env.HUBOT_TWEETER_ACCOUNTS

unless config.consumer_key
  console.log "Please set the HUBOT_TWITTER_CONSUMER_KEY environment variable."
unless config.consumer_secret
  console.log "Please set the HUBOT_TWITTER_CONSUMER_SECRET environment variable."
unless config.accounts_json
  console.log "Please set the HUBOT_TWEETER_ACCOUNTS environment variable."

config.accounts = JSON.parse(config.accounts_json || "{}")

module.exports = (robot) ->
  robot.respond /tweet\@([^\s]+)$/i, (msg) ->
    msg.reply "You can't very well tweet an empty status, can ya?"
    return

  robot.respond /tweet\@([^\s]+)\s(.+)$/i, (msg) ->

    username = msg.match[1].toLowerCase()

    unless Helpers.accountIsSetup(config, username)
      msg.reply "I'm not setup to send tweets on behalf of #{username}. Sorry."
      return

    update   = msg.match[2].trim()

    unless Helpers.tweetExists(update)
      msg.reply "You can't very well tweet an empty status, can ya?"
      return

    if (tweetOverflow = Helpers.tweetOverflow(update)) > 0
      msg.reply "Your tweet is #{tweetOverflow} characters too long. Twitter users can't read that many characters!"
      return

    Helpers.authenticated_twit(config, username).post "statuses/update",
      status: update
    , (err, reply) ->
      if err
        msg.reply Helpers.errorMessage(err)
        return
      if reply['text']
        message = "#{reply['user']['screen_name']} just tweeted: #{reply['text']}."
        message += " Delete it with '#{robot.alias} untweet@#{username} #{reply['id_str']}'."
        return msg.send message
      else
        return msg.reply "Hmmm. I'm not sure if the tweet posted. Check the account: http://twitter.com/#{username}"

  robot.respond /untweet\@([^\s]+)\s(.*)/i, (msg) ->
    username        = msg.match[1]
    tweet_url_or_id = msg.match[2]

    tweet_id        = Helpers.extractTweetId(tweet_url_or_id)
    unless tweet_id
      msg.reply "Sorry, '#{tweet_url_or_id}' doesn't contain a valid id. Make sure it's a valid tweet URL or ID."
      return

    authenticated_twit(username).post "statuses/destroy/#{tweet_id}", {}, (err, reply) ->
      if err
        msg.reply Helpers.errorMessage(err)
        return
      if reply['text']
        return msg.send "#{reply['user']['screen_name']} just deleted tweet: '#{reply['text']}'."
      else
        return msg.reply "Hmmm. I'm not sure if the tweet was deleted. Check the account: http://twitter.com/#{username}"

  robot.respond /r(etwee)?t\@([^\s]+)\s(.*)/i, (msg) ->
    username        = msg.match[1]
    tweet_url_or_id = msg.match[2]

    tweet_id        = Helpers.extractTweetId(tweet_url_or_id)
    unless tweet_id
      msg.reply "Sorry, '#{tweet_url_or_id}' doesn't contain a valid id. Make sure it's a valid tweet URL or ID."
      return

    Helpers.authenticated_twit(username).post "statuses/retweet/#{tweet_id}", (err, reply) ->
      if err
        msg.reply Helpers.errorMessage(err)
        return
      if reply['text']
        return msg.send "#{reply['user']['screen_name']} just tweeted: #{reply['text']}"
      else
        return msg.reply "Hmmm. I'm not sure if that retweet posted. Check the account: http://twitter.com/#{username}"
