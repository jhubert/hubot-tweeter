Twit = require "twit"
twitterText = require "twitter-text"

module.exports =
  #
  # Create an instance of 'Twit' which has the proper credentials.
  #
  authenticated_twit = (config, username) ->
    new Twit
      consumer_key: config.consumer_key
      consumer_secret: config.consumer_secret
      access_token: config.accounts[username].access_token
      access_token_secret: config.accounts[username].access_token_secret

  #
  # Extract the tweet ID from a tweet ID or url.
  #
  extractTweetId = (tweet_id_or_url) ->
    tweet_id_match = tweet_url_or_id.match(/(\d+)$/)
    tweet_id_match[0] if tweet_id_match and tweet_id_match[0]

  #
  # Determine how much longer than 140 characters the tweet is.
  #
  tweetOverflow = (update) ->
    twitterText.getTweetLength(update) - 140

  #
  # Determine if the account is setup
  #
  accountIsSetup = (config, username) ->
    config.accounts[username]

  #
  # Determine if the update is not empty.
  #
  tweetExists = (update) ->
    update and update.length > 0

  #
  # The error message
  #
  errorMessage = (err) ->
    "Gah! I can't do that: '#{err.message}' (returned a #{err.statusCode} status code)"
