class User < ApplicationRecord
    before_save { self.email.downcase! }
    #self.email.downcase!は入力した文字を小文字に変換すること
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
    
  has_many :microposts
  
  #ここからお気に入りツイート
  has_many :favorites
  # 以下2つの1対多、及び多対多？のような定義は、間違いです。
  #has_many :user, through: :favorites, source: :micropost
  #has_many :micropost, through: :favorites, source: :user
  # UserモデルとFavoriteモデルの関係は、「多対多」
  # このファイルはUserクラス定義の内部なので、「投稿」に対する
  # [has_many ...through: ... ]の定義があれば十分
  # つまり、「favoritesテーブルを通じて、得られるお気に入り投稿」
  # has_many :favorite_microposts, through: :favorites, source: :micropost

  # through: の favoritesに、 `:` が抜けてましたねww
  has_many :favorite_microposts, through: :favorites, source: :micropost
  
  def follow_micropost(other_tweet)
    # そもそもself==... のように不一致条件が必要ないですね。
    # やりたいことは
    # 「ある投稿(=other_tweet)をお気入り化し(済みならそれを）、Favoriteインスタンスを返す」
    # selfはuser自体なので、user_idは既に分かっています
    # yukiなら、4といった具合に。ここは micropost_idを一致検索する
    # unless self == other_tweet　下記は間違い
    #   self.favorites.find_or_create_by(user_id: other_tweet.id)
    # end

    # 以下は、固定的！にuser#idが4のユーザにとっての
    # 投稿(micropost#idが1)をお気に入り化し(済みならそれを)返す処理です
    # other_tweet = Micropost.find(1)
    # User.find(4).favorites.find_or_create_by(micropost_id: other_tweet.id)
    # これだと、固定的で、変化性がないので、変動できるように変えます。
    self.favorites.find_or_create_by(micropost_id: other_tweet.id)
  end

  def unfollow_micropost(other_tweet)
    favorite = self.favorites.find_by(micropost_id: other_tweet.id)
    favorite.destroy if favorite
  end

  def already_favorited?(micropost)
    # 「お気に入り済みの投稿一覧」<=has_many throughで書いたもの>.include?
    self.favorite_microposts.include?(micropost)
  end
  
  #ここからフォロー・フォロワー
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
   def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
   end
   
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
    #has_many :followingsによって自動生成されるfollowing_ids
  end
end
