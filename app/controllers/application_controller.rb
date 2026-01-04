
class ApplicationController < ActionController::Base
  # Ограничивает поддержку браузеров современными версиями (улучшает безопасность и CSS-совместимость)
  allow_browser versions: :modern

  # Делает методы доступными в представлениях (Views)
  helper_method :current_user, :logged_in?

  # Получает текущего пользователя из сессии (мемоизация через ||=)
  # Это позволяет избежать повторных запросов к БД в рамках одного запроса
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Вспомогательный метод для проверки авторизации в контроллерах и вьюхах
  def logged_in?
    current_user.present?
  end

  # Защита от повторной авторизации (например, при попытке зайти на /login уже залогиненным пользователем)
  def redirect_if_authenticated
    redirect_to root_path, alert: "You are already logged in." if current_user
  end

  # Блокировка доступа к неавторизованным пользователям (используется как before_action)
  def authenticate_user!
    redirect_to login_path unless current_user
  end
end
