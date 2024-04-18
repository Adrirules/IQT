class UsersController < ApplicationController
  def create
    # Utilisez la session pour retrouver le GuestUser
    session_id = session.id.to_s
    @guest_user = GuestUser.find_by(session_id: session_id)

    if @guest_user
      @user = @guest_user.convert_to_user(user_params)

      if @user.save
        sign_in(@user) # Connectez automatiquement le nouvel utilisateur
        redirect_to root_path, notice: 'Account created successfully!'
      else
        render :new
      end
    else
      # Gérer le cas où aucun GuestUser n'est trouvé
      redirect_to new_user_registration_path, alert: "No guest user found."
    end
  end

  private

  def user_params
    # Définissez ici les paramètres autorisés pour la création d'un utilisateur
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
