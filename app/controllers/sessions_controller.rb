
class SessionsController < ApplicationController
  # Не позволяем авторизованным пользователям видеть форму входа
  before_action :redirect_if_authenticated, only: [ :new, :create ]

  def new
    # Отображает форму входа
  end

  def create
    # Если пользователь уже вошел (через middleware и т.д.), редиректим
    redirect_to root_path and return if current_user

    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      if user.two_factor_enabled
        # Если включена 2FA, сохраняем ID временно и запрашиваем код
        session[:prep_user_id] = user.id
        redirect_to two_factor_path, notice: "Введите код подтверждения"
        nil
      else
        # Успешная авторизация без 2FA
        session[:user_id] = user.id
        redirect_to root_path, notice: "С возвращением, #{user.first_name}!"
      end
    else
      # Неверные данные — рендерим форму с ошибкой
      flash.now[:alert] = "Неверный email или пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # Если сессии нет, просто редиректим (защита от повторного logout)
    redirect_to root_path and return unless session[:user_id] || session[:prep_user_id]

    # Полная очистка сессии: основной пользователь, временный и флаг 2FA
    session.delete(:user_id)
    session.delete(:prep_user_id)
    session.delete(:two_factor_passed)

    redirect_to root_path, notice: "Вы вышли из системы"
  end
end
