class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def redirect_if_authenticated
    redirect_to root_path, alert: "You are already logged in." if current_user
  end

  def authenticate_user!
    redirect_to login_path unless current_user
  end
end
