require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_user_attributes) do
    {
      first_name: 'Иван',
      last_name: 'Иванов',
      email: 'ivan.ivanov@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      phone: '291234567'
    }
  end

  let(:valid_profile_attributes) do
    {
      first_name: 'Петр',
      last_name: 'Петров',
      middle_name: 'Сергеевич',
      phone: '+375 (29) 123-45-67'
    }
  end

  let(:user) { User.create!(valid_user_attributes) }

  context 'when user is not authenticated' do
    describe 'GET #new' do
      it 'returns a success response' do
        get :new
        expect(response).to be_successful
      end

      it 'assigns a new user to @user' do
        get :new
        expect(assigns(:user)).to be_a_new(User)
      end
    end

    describe 'POST #create' do
      context 'with valid parameters' do
        it 'creates a new User' do
          expect {
            post :create, params: { user: valid_user_attributes }
          }.to change(User, :count).by(1)
        end

        it 'sets a session for the created user' do
          post :create, params: { user: valid_user_attributes }
          expect(session[:user_id]).to eq(User.last.id)
        end

        it 'sets a notice flash message' do
          post :create, params: { user: valid_user_attributes }
          expect(flash[:notice]).to eq('Добро пожаловать, Иван!')
        end

        it 'redirects to the root path' do
          post :create, params: { user: valid_user_attributes }
          expect(response).to redirect_to(root_path)
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new User' do
          expect {
            post :create, params: { user: { email: 'invalid' } }
          }.not_to change(User, :count)
        end

        it 'sets an alert flash message' do
          post :create, params: { user: { email: 'invalid' } }
          expect(flash.now[:alert]).to be_present
        end
      end
    end

    describe 'GET #show' do
      it 'redirects to root path' do
        get :show, params: { id: user.to_param }
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'PATCH #update' do
      it 'redirects to root path' do
        patch :update, params: { id: user.to_param, user: valid_profile_attributes }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'when user is authenticated' do
    before do
      session[:user_id] = user.id
    end

    describe 'GET #new' do
      it 'redirects to root path' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'POST #create' do
      it 'redirects to root path' do
        post :create, params: { user: valid_user_attributes }
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: user.to_param }
        expect(response).to be_successful
      end

      it 'assigns the current_user to @user' do
        get :show, params: { id: user.to_param }
        expect(assigns(:user)).to eq(user)
      end
    end

    describe 'PATCH #update' do
      context 'with valid parameters' do
        it 'updates the user profile' do
          patch :update, params: { id: user.to_param, user: valid_profile_attributes }
          user.reload
          expect(user.first_name).to eq('Петр')
          expect(user.last_name).to eq('Петров')
        end

        it 'normalizes the phone number' do
          patch :update, params: { id: user.to_param, user: valid_profile_attributes }
          user.reload
          expect(user.phone).to eq('291234567')
        end

        it 'sets a notice flash message' do
          patch :update, params: { id: user.to_param, user: valid_profile_attributes }
          expect(flash[:notice]).to eq('Ваш профиль успешно обновлен')
        end

        it 'redirects to the profile path' do
          patch :update, params: { id: user.to_param, user: valid_profile_attributes }
          expect(response).to redirect_to(profile_path)
        end
      end

      context 'with invalid parameters' do
        it 'does not update the user' do
          original_name = user.first_name
          patch :update, params: { id: user.to_param, user: { first_name: '' } }
          user.reload
          expect(user.first_name).to eq(original_name)
        end

        it 'sets an alert flash message' do
          patch :update, params: { id: user.to_param, user: { first_name: '' } }
          expect(flash.now[:alert]).to be_present
        end
      end
    end

    describe 'GET #change_email' do
      it 'sets a notice flash message' do
        get :change_email
        expect(flash[:notice]).to eq('Инструкция по изменению email отправлена на вашу почту')
      end

      it 'redirects to the profile path' do
        get :change_email
        expect(response).to redirect_to(profile_path)
      end
    end

    describe 'GET #change_password' do
      it 'sets a notice flash message' do
        get :change_password
        expect(flash[:notice]).to eq('Инструкция по изменению пароля отправлена на вашу почту')
      end

      it 'redirects to the profile path' do
        get :change_password
        expect(response).to redirect_to(profile_path)
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the current_user' do
        expect {
          delete :destroy
        }.to change(User, :count).by(-1)
      end

      it 'resets the session' do
        expect(controller).to receive(:reset_session)
        delete :destroy
      end

      it 'sets a notice flash message' do
        delete :destroy
        expect(flash[:notice]).to eq('Ваш аккаунт успешно удален')
      end

      it 'redirects to the root path' do
        delete :destroy
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
