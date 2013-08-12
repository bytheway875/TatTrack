class User < ActiveRecord::Base
  acts_as_voter
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :location, :memorable_story
  
  # Establish relationships between models
  has_many :tattoos
  has_many :comments
  after_create :assign_tweets_to_tattoos

  def assign_tweets_to_tattoos
    if !Tweet.where(:handle => self.username).empty?
      Tweet.where(:handle => self.username).each do |tweet|
        
        hashtags = []
        tweet.hashtags.each do |hashtag|
          hashtag = "##{hashtag.text}" 
          hashtags << hashtag
        end
        hashtags = hashtags.join(' ')
        
        tweet.attached_photos.each do |photo|
          Tattoo.create(twitter_photo: photo.media_url, hashtags: hashtags)
        end
      end
    end
  end


  def self.from_omniauth(auth)
    where(auth.slice(:provider,:uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.username = auth.info.nickname
      user.avatar = auth.info.image
    end
  end 

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection:true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end 
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
end
