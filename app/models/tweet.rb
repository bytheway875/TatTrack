class Tweet < ActiveRecord::Base
  attr_accessible :text, :pulled_tweet_id, :attached_photos
  
  has_many :tattoos
  serialize :attached_photos

  def self.pull_tweets
    Twitter.search("#hashtat").results.map do|tweet|
     create!(pulled_tweet_id: tweet.id.to_s,
      text: tweet.text,
      attached_photos: tweet.media)
    end
  end
end