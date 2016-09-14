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
    update   = msg.match[2].trim()

    goTweet(msg, username, update)
    .then (res) ->
      msg.send res
    .catch (err) ->
      msg.reply err

  robot.respond /untweet\@([^\s]+)\s(.*)/i, (msg) ->
    username        = msg.match[1]
    tweet_url_or_id = msg.match[2]

    tweet_id = Helpers.extractTweetId(tweet_url_or_id)
    unless tweet_id
      msg.reply "Sorry, '#{tweet_url_or_id}' doesn't contain a valid id. Make sure it's a valid tweet URL or ID."
      return

    Helpers.authenticatedTwit(config, username).post "statuses/destroy/#{tweet_id}", {}, (err, reply) ->
      if err
        msg.reply Helpers.errorMessage(err)
        return
      if (response = Helpers.buildResponse(reply)).exists()
        return msg.send Helpers.deletedTweetMessage(response)
      else
        return msg.reply "Hmmm. I'm not sure if the tweet was deleted. Check the account: http://twitter.com/#{username}"

  robot.respond /r(etwee)?t\@([^\s]+)\s(.*)/i, (msg) ->
    username        = msg.match[2]
    tweet_url_or_id = msg.match[3]

    tweet_id = Helpers.extractTweetId(tweet_url_or_id)
    unless tweet_id
      msg.reply "Sorry, '#{tweet_url_or_id}' doesn't contain a valid id. Make sure it's a valid tweet URL or ID."
      return

    Helpers.authenticatedTwit(config, username).post "statuses/retweet/#{tweet_id}", (err, reply) ->
      if err
        msg.reply Helpers.errorMessage(err)
        return
      if (response = Helpers.buildResponse(reply)).exists()
        return msg.send Helpers.tweetRetweetedMessage(response)
      else
        return msg.reply "Hmmm. I'm not sure if that retweet posted. Check the account: http://twitter.com/#{username}"

  # Cross scripting for tweeting.
  # payload = {
  #   msg: for responding to chat room
  #   username: username (twitter handle)
  #   tweet: tweet
  # }
  robot.on 'hubot-tweeter.tweet', (payload) ->
    msg       = payload.msg
    username  = payload.username
    tweet     = payload.tweet

    goTweet(msg, username, tweet)
    .then (res) ->
      msg.send res
    .catch (err) ->
      console.log err

  # Tweets on behalf of username with tweet supplied.
  # msg - message object for hubot to reply, send, etc
  # username - twitter username
  # tweet - what will be posted
  # returns a promise
  goTweet = (msg, username, tweet) ->
    return new Promise (resolve, reject) ->
      unless Helpers.accountIsSetup(config, username)
        return reject "I'm not setup to send tweets on behalf of #{username}. Sorry."

      unless Helpers.tweetExists(tweet)
        return reject "You can't very well tweet an empty status, can ya?"

      if (tweetOverflow = Helpers.tweetOverflow(tweet)) > 0
        return reject "Your tweet is #{tweetOverflow} characters too long. Twitter users can't read that many characters!"

      Helpers.authenticatedTwit(config, username).post "statuses/update",
        status: tweet
      , (err, reply) ->
        if err
          return reject Helpers.errorMessage(err)
        if (response = Helpers.buildResponse(reply)).exists()
          message = Helpers.tweetPostedMessage(response)
          message += " Delete it with '#{robot.alias} untweet@#{response.tweeter()} #{response.tweetId()}'."
          return resolve message
        else
          return reject "Hmmm. I'm not sure if the tweet posted. Check the account: http://twitter.com/#{username}"
