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
