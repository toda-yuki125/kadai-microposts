class User < ApplicationRecord
    before_save { self.email.downcase! }
    #self.email.downcase!は入力した文字を小文字に変換すること
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
    has_secure_password
end
