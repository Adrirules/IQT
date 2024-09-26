class UserMailer < ApplicationMailer
  def test_email(email)
    mail(to: email, subject: "Test Email", body: "This is a test email.")
  end

    # Email de réinitialisation de mot de passe
  def reset_password_instructions(user, token, opts = {})
    @user = user
    @token = token
    mail(to: @user.email, subject: "Reset your password", **opts)
  end


  # Email de confirmation d'inscription
  def confirmation_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Confirm your registration")
  end

  # Email pour changement de mot de passe
  def password_change(user)
    @user = user
    mail(to: @user.email, subject: "Your password has been changed")
  end
end
