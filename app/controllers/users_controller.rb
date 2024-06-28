class UsersController < ApplicationController
  def create
    @guest_user = guest_user # Utilise la méthode définie dans ApplicationController

    if @guest_user
      @user = @guest_user.convert_to_user(user_params)

      if @user.persisted?
        sign_in(@user)
        reassociate_orders(@guest_user, @user)
        redirect_to session.delete(:redirect_to_after_signup) || new_order_payment_path(@order), notice: 'Account created successfully! Please complete the payment to view your IQ test results.'
      else
        render :new
      end
    else
      redirect_to new_user_registration_path, alert: "No guest user found."
    end
  end

private

  def reassociate_orders(guest_user, user)
    Order.where(responder: guest_user).each do |order|
      order.update(responder: user)
    end
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
