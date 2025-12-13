class UsersController < ApplicationController
  before_action :redirect_if_authenticated, only: [ :new, :create ]
  before_action :authenticate_user!, only: [ :show, :update, :change_email, :change_password ]
  before_action :set_user, only: [ :show, :update ]

  def new
    redirect_to root_path and return if current_user
    @user = User.new
  end

  def show
    redirect_to root_path unless current_user
    @user = current_user
  end

  def create
    redirect_to root_path and return if current_user

    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Добро пожаловать, #{@user.first_name}!"
      redirect_to root_path
    else
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

  def change_email
    flash[:notice] = "Инструкция по изменению email отправлена на вашу почту"
    redirect_to profile_path
  end

  def change_password
    flash[:notice] = "Инструкция по изменению пароля отправлена на вашу почту"
    redirect_to profile_path
  end

  def destroy
    if current_user.destroy
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
    permitted[:phone] = normalize_phone(permitted[:phone])
    permitted
  end

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

  def normalize_phone(raw)
    return "" if raw.blank?

    digits = raw.gsub(/\D/, "")

    if digits.start_with?("375")
      digits = digits.sub(/^375/, "")
    end

    digits.length >= 9 ? digits[-9, 9] : ""
  end
end
