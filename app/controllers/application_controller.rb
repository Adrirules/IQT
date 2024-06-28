class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception # Ajout de la protection CSRF

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  include Pundit::Authorization
  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?


  private
  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end
  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def create_guest_user
    if user_signed_in?
      session[:guest_user_id] = nil  # Clear the session if a user is signed in
    elsif session[:guest_user_id].nil?
      guest_user = GuestUser.create!(session_id: session.id.to_s)
      session[:guest_user_id] = guest_user.id
    end
  end

  helper_method :current_or_guest_user

  def current_or_guest_user
    if current_user
      current_user
    else
      guest_user
    end
  end

  def guest_user
    @cached_guest_user ||= GuestUser.find_or_create_by_session(session.id.to_s)
  end
end
