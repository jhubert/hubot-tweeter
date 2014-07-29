Twit = require "twit"
twitterText = require "twitter-text"

#
# Create an instance of 'Twit' which has the proper credentials.
#
authenticatedTwit = (config, username) ->
  new Twit
    consumer_key: config.consumer_key
    consumer_secret: config.consumer_secret
    access_token: config.accounts[username].access_token
    access_token_secret: config.accounts[username].access_token_secret

#
# Extract the tweet ID from a tweet ID or url.
#
extractTweetId = (tweetIdOrUrl) ->
  tweetIdMatch = tweetIdOrUrl.match(/(\d+)$/)
  if tweetIdMatch and tweetIdMatch[0]
    tweetIdMatch[0]
  else
    null

#
# Determine how much longer than 140 characters the tweet is.
#
tweetOverflow = (update) ->
  twitterText.getTweetLength(update) - 140

#
# Determine if the account is setup
#
accountIsSetup = (config, username) ->
  config.accounts[username]?

#
# Determine if the update is not empty.
#
tweetExists = (update) ->
  update? and update.length > 0

#
# The error message to return to the user when the API freaks out.
#
errorMessage = (err) ->
  "Gah! I can't do that: '#{err.message}' (returned a #{err.statusCode} status code)"

#
# The human-readable message sent to the chat client about the tweet action.
#
tweetActionMessage = (response, action) ->
  "#{response.tweeter()} just #{action}: ' #{response.tweet()} '."

#
# The message that the bot returns when a tweet has been deleted.
#
deletedTweetMessage = (response) ->
  tweetActionMessage(response, 'deleted')

#
# The message that the bot returns when a tweet has been posted.
#
tweetPostedMessage = (response) ->
  tweetActionMessage(response, 'tweeted')

#
# The message that the bot returns when a tweet has been retweeted.
#
tweetRetweetedMessage = (response) ->
  tweetActionMessage(response, 'retweeted')

#
# Create a new Response object
#
buildResponse = (resp) ->
  new Response(resp)

class Response
  constructor: (@reply) ->

  tweeter: ->
    @reply['user']['screen_name']

  exists: ->
    @tweet()?

  tweet: ->
    @reply['text']

  tweetId: ->
    @reply['id_str']

module.exports =
  authenticatedTwit:     authenticatedTwit,
  extractTweetId:        extractTweetId,
  tweetOverflow:         tweetOverflow,
  accountIsSetup:        accountIsSetup,
  tweetExists:           tweetExists,
  errorMessage:          errorMessage,
  buildResponse:         buildResponse,
  Response:              Response,
  deletedTweetMessage:   deletedTweetMessage,
  tweetPostedMessage:    tweetPostedMessage,
  tweetRetweetedMessage: tweetRetweetedMessage
