require 'mocha'
chai   = require 'chai'
expect = chai.expect
Helpers = require '../src/tweeter-helpers'

describe 'Helpers', ->

  describe 'extractTweetId', ->
    it 'extracts the tweet id from a raw ID', ->
      tweetId = '1289838934'
      expect(Helpers.extractTweetId(tweetId)).to.equal tweetId

    it 'extracts the tweet id from a twitter status url', ->
      tweetId = '1289838934'
      tweetUrl = "https://twitter.com/mattr-/status/#{tweetId}"
      expect(Helpers.extractTweetId(tweetUrl)).to.equal tweetId

    it 'returns nothing if no valid id is there', ->
      tweetUrl = "https://gist.github.com/parkr/cf27484fd03ea65f0c4d"
      expect(Helpers.extractTweetId(tweetUrl)).to.equal null

  describe 'tweetOverflow', ->
    it 'counts the chars over 140', ->
      tweet = 'Hey guys, so I have an idea for a new app that I want built.'
      tweet += ' I don\'t have the time, so... can one of you please build it?'
      tweet += ' Please... I\'ll pretend to pay you money and give you admiration!'
      expect(Helpers.tweetOverflow(tweet)).to.equal 46

    it 'returns a negative number if the tweet is less than 140 chars', ->
      tweet = 'Ohai guys.'
      expect(Helpers.tweetOverflow(tweet)).to.equal -130

    it 'accounts for urls', ->
      tweet = 'Hey, check this out! https://gist.github.com/parkr/cf27484fd03ea65f0c4d'
      expect(Helpers.tweetOverflow(tweet)).to.equal -96
      expect(Helpers.tweetOverflow(tweet)).not.to.equal tweet.length-140

  describe 'accountIsSetup', ->
    it 'returns true if the username is registered', ->
      config =
        accounts:
          jekyllrb:
            something: 'there'
      username = 'jekyllrb'
      expect(Helpers.accountIsSetup(config, username)).to.be.true

    it 'returns false if the username is not registered', ->
      config =
        accounts:
          parkr:
            something: 'else'
      username = 'jekyllrb'
      expect(Helpers.accountIsSetup(config, username)).to.be.false

  describe 'tweetExists', ->
    it 'returns true if tweet is non-empty', ->
      expect(Helpers.tweetExists('hi')).to.be.true
    it 'returns false if tweet is null', ->
      expect(Helpers.tweetExists(null)).to.be.false
    it 'returns false if tweet is undefined', ->
      expect(Helpers.tweetExists()).to.be.false
    it 'returns false if tweet is empty', ->
      expect(Helpers.tweetExists('')).to.be.false

  describe 'errorMessage', ->
    err =
      statusCode: 500,
      message: 'some-message'
    it 'builds a nice human-readable msg', ->
      expect(Helpers.errorMessage(err)).to.equal(
        "Gah! I can't do that: 'some-message' (returned a 500 status code)"
      )

  describe 'buildResponse', ->
    it 'returns a Response object', ->
      expect(Helpers.buildResponse({})).to.be.an.instanceof Helpers.Response

  describe 'Response', ->
    reply =
      user:
        screen_name: 'jekyllrb'
      text: 'Look ma, a tweet!'
      id_str: '89358923589723589'
    response = new Helpers.Response(reply)

    it 'knows who conducted the action', ->
      expect(response.tweeter()).to.equal 'jekyllrb'

    it 'knows whether the tweet exists', ->
      expect(response.exists()).to.be.true

    it 'knows the content of the tweet', ->
      expect(response.tweet()).to.equal 'Look ma, a tweet!'

    it 'knows the tweet ID', ->
      expect(response.tweetId()).to.equal '89358923589723589'
