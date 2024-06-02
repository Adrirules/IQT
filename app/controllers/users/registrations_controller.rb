class Users::RegistrationsController < Devise::RegistrationsController
  after_action :transfer_guest_user_data, only: :create

  protected

  def after_sign_up_path_for(resource)
    session[:redirect_to_after_signup] || root_path
  end

  private

  def transfer_guest_user_data
    return unless resource.persisted? && session[:guest_user_id]

    guest_user = GuestUser.find_by(id: session[:guest_user_id])
    if guest_user
      Rails.logger.info "Transferring data from guest user #{guest_user.id} to user #{resource.id}"

      guest_user.orders.update_all(responder_type: 'User', responder_id: resource.id)
      guest_user.responses.update_all(responder_type: 'User', responder_id: resource.id)
      guest_user.user_test_scores.update_all(responder_type: 'User', responder_id: resource.id)

      guest_user.destroy
      session.delete(:guest_user_id)

      Rails.logger.info "Data successfully transferred from guest user #{guest_user.id} to user #{resource.id}"
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error "Error transferring data: #{e.message}"
  end
end
