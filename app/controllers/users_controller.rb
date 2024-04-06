class UsersController < ApplicationController
  def create
    @guest_user = GuestUser.find(params[:guest_user_id])
    @user = @guest_user.convert_to_user(user_params)

    if @user.save
      sign_in(@user) # Connectez automatiquement le nouvel utilisateur
      redirect_to root_path, notice: 'Account created successfully!'
    else
      render :new
    end
  end

  private

  def user_params
    # Définissez ici les paramètres autorisés pour la création d'un utilisateur
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
