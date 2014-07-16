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