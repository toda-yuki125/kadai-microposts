module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end
end
#以下コードと同じ、書き方が違うだけ
#if @current_user
#  return @current_user
#else
#  @current_user = User.find_by(id: session[:user_id])
#  return @current_user
#end