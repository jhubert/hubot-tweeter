chai   = require 'chai'
expect = chai.expect
Helpers = require '../src/tweeter-helpers'

describe 'Helpers', ->
  describe 'extractTweetId' ->
    it 'extracts the tweet id from a raw ID' ->
      tweetId = '1289838934'
      expect(Helpers.extractTweetId(tweetId)).to.equal tweetId
