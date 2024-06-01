class StripeCheckoutSessionService
  def call(event)
    session = event.data.object

    order = Order.find_by(checkout_session_id: session.id)
    if order.present?
      order.update(state: 'paid')
      Rails.logger.info "Order #{order.id} marked as paid"
    else
      Rails.logger.error "Order not found for checkout_session_id: #{session.id}"
    end
  end
end
