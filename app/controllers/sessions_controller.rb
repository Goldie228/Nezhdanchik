class SessionsController < ApplicationController
  before_action :redirect_if_authenticated, only: [ :new, :create ]

  def new; end

  def create
    redirect_to root_path and return if current_user

    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.two_factor_enabled
        session[:prep_user_id] = user.id
        redirect_to two_factor_path, notice: "Введите код подтверждения"
        nil
      else
        session[:user_id] = user.id
        redirect_to root_path, notice: "С возвращением, #{user.first_name}!"
      end
    else
      flash.now[:alert] = "Неверный email или пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to root_path and return unless session[:user_id] || session[:prep_user_id]

    session.delete(:user_id)
    session.delete(:prep_user_id)
    session.delete(:two_factor_passed)

    redirect_to root_path, notice: "Вы вышли из системы"
  end
end
