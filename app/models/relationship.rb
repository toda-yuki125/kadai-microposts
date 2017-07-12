class Relationship < ApplicationRecord
  belongs_to :user
  belongs_to :follow, class_name: 'User' #followテーブルは存在しないので、Userモデルを指定する
  
  validates :user_id, presence: true
  validates :follow_id, presence: true
end
