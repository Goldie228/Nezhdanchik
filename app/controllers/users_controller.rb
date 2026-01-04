
class UsersController < ApplicationController
  # Не позволяем авторизованным пользователям видеть формы регистрации/входа
  before_action :redirect_if_authenticated, only: [ :new, :create ]
  # Требуем авторизацию для действий внутри профиля
  before_action :authenticate_user!, only: [ :show, :update, :change_email, :change_password ]
  # Извлекаем текущего пользователя для методов отображения и редактирования
  before_action :set_user, only: [ :show, :update ]

  def new
    # Дополнительная проверка безопасности (хотя before_action уже перекрывает это)
    redirect_to root_path and return if current_user
    @user = User.new
  end

  def show
    # Если пользователя нет в сессии, редиректим на главную
    redirect_to root_path unless current_user
    @user = current_user
  end

  def create
    # Защита от повторной регистрации уже залогиненного пользователя
    redirect_to root_path and return if current_user

    @user = User.new(user_params)

    if @user.save
      # Сразу авторизуем нового пользователя, сохраняя его ID в сессию
      session[:user_id] = @user.id
      flash[:notice] = "Добро пожаловать, #{@user.first_name}!"
      redirect_to root_path
    else
      # Выводим ошибки валидации, если создать пользователя не удалось
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(profile_params)
      flash[:notice] = "Ваш профиль успешно обновлен"
      redirect_to profile_path
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  # Уведомляет пользователя о том, что инструкция по смене email отправлена
  def change_email
    flash[:notice] = "Инструкция по изменению email отправлена на вашу почту"
    redirect_to profile_path
  end

  # Уведомляет пользователя о том, что инструкция по смене пароля отправлена
  def change_password
    flash[:notice] = "Инструкция по изменению пароля отправлена на вашу почту"
    redirect_to profile_path
  end

  # Удаление аккаунта и полной очистки сессии
  def destroy
    if current_user.destroy
      # reset_session генерирует новый ID сессии, предотвращая фиксацию атаки (session hijacking)
      reset_session
      flash[:notice] = "Ваш аккаунт успешно удален"
      redirect_to root_path
    else
      flash[:alert] = "Не удалось удалить аккаунт"
      redirect_to profile_path
    end
  end

  private

  def set_user
    @user = current_user
  end

  # Разрешенные параметры при создании пользователя
  def user_params
    permitted = params.require(:user).permit(
      :first_name,
      :last_name,
      :middle_name,
      :phone,
      :email,
      :password,
      :password_confirmation
    )
    # Нормализуем номер телефона к единому формату для хранения
    permitted[:phone] = normalize_phone(permitted[:phone])
    permitted
  end

  # Разрешенные параметры при обновлении профиля (без пароля)
  def profile_params
    permitted = params.require(:user).permit(
      :first_name,
      :last_name,
      :middle_name,
      :phone
    )
    permitted[:phone] = normalize_phone(permitted[:phone])
    permitted
  end

  # Приводит номер телефона к формату из 9 цифр (без кода страны 375).
  # Это упрощает поиск и валидацию, так как все номера хранятся в едином локальном формате.
  def normalize_phone(raw)
    return "" if raw.blank?

    digits = raw.gsub(/\D/, "")

    # Удаляем код страны "375", если пользователь ввел полный номер
    if digits.start_with?("375")
      digits = digits.sub(/^375/, "")
    end

    # Возвращаем последние 9 цифр (код оператора + номер абонента)
    digits.length >= 9 ? digits[-9, 9] : ""
  end
end
