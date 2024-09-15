class StripeCheckoutSessionService
  def call(event)
    Rails.logger.info "Processing Stripe event: #{event.inspect}"

    case event['type']
    when 'checkout.session.completed'
      handle_checkout_session_completed(event)
    when 'payment_intent.succeeded'
      handle_payment_intent_succeeded(event)
    else
      Rails.logger.info "Unhandled event type: #{event['type']}"
    end
  end

  private

  def handle_checkout_session_completed(event)
    session = event['data']['object']
    order = Order.find_by(checkout_session_id: session['id'])

    if order.present?
      order.update(state: 'paid')
      Rails.logger.info "Order updated to 'paid' for session id: #{session['id']}"

      # Envoyer l'e-mail de confirmation
      OrderMailer.payment_success(order).deliver_now
    else
      Rails.logger.error "Order not found for session id: #{session['id']}"
    end
  end

  def handle_payment_intent_succeeded(event)
    payment_intent = event['data']['object']
    Rails.logger.info "PaymentIntent succeeded for id: #{payment_intent['id']}"

    # Si tu veux lier cela à une commande, tu devrais avoir un identifiant pour le faire
    # par exemple via metadata ou autre
  end
end
