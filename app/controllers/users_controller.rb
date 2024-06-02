class UsersController < ApplicationController
  def create
    session_id = session.id.to_s
    @guest_user = GuestUser.find_by(session_id: session_id)

    if @guest_user
      @user = @guest_user.convert_to_user(user_params)

      if @user.persisted?
        sign_in(@user)

        # Rediriger vers l'URL stockée dans la session ou la page de paiement par défaut
        redirect_to(session.delete(:redirect_to_after_signup) || new_order_payment_path(@order), notice: 'Account created successfully! Please complete the payment to view your IQ test results.')
      else
        render :new
      end
    else
      redirect_to new_user_registration_path, alert: "No guest user found."
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
