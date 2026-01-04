
class AdminConstraint
  # Проверяет, имеет ли текущий пользователь права администратора
  # Используется в routes.rb для защиты маршрутов админ-панели (Avo)
  def matches?(request)
    user_id = request.session[:user_id]
    user = User.find_by(id: user_id)

    # Возвращает true только если пользователь найден и его роль — admin
    user&.admin?
  end
end
