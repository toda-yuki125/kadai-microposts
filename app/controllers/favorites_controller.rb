class FavoritesController < ApplicationController
 before_action :require_user_logged_in
 
 def create
    like = Micropost.find(params[:micropost_id])
    current_user.follow_micropost(like)
    flash[:success] = 'お気に入り追加しました.'
    redirect_to current_user
    
 end

  def destroy
    like = Micropost.find(params[:micropost_id])
    current_user.unfollow_micropost(like)
    flash[:success] = 'お気に入りを解除しました。'
    redirect_to current_user
  end
end
