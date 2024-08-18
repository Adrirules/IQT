class StripeCheckoutSessionService
  def call(event)
    Rails.logger.info "Processing Stripe event: #{event.inspect}"

    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']

      # Trouver la commande associée à la session de paiement
      order = Order.find_by(checkout_session_id: session['id'])

      if order.present?
        order.update(state: 'paid')
        Rails.logger.info "Order updated to 'paid' for session id: #{session['id']}"

        # Envoyer l'e-mail de confirmation
        OrderMailer.payment_success(order).deliver_now
      else
        Rails.logger.error "Order not found for session id: #{session['id']}"
      end
    else
      Rails.logger.info "Unhandled event type: #{event['type']}"
    end
  end
end
