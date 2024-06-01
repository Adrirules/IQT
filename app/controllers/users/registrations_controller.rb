class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted? && session[:guest_user_id]
        guest_user = GuestUser.find_by(id: session[:guest_user_id])
        if guest_user
          new_user = guest_user.convert_to_user(user_params)
          if new_user
            sign_in(resource, bypass: true)
            session[:guest_user_id] = nil  # Clear the session to avoid re-merge
          end
        end
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
