class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { message: 'Invalid payload' }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      render json: { message: 'Invalid signature' }, status: 401 and return
    end

    case event['type']
    when 'payment_intent.succeeded'
      payment_intent = event['data']['object']
      order = Order.find_by(payment_intent_id: payment_intent.id)
      if order.present?
        order.update(state: 'paid')
        OrderMailer.payment_success(order).deliver_now
      else
        Rails.logger.error "Order not found for payment intent id: #{payment_intent.id}"
      end
    when 'charge.succeeded'
      charge = event['data']['object']
      order = Order.find_by(payment_intent_id: charge.payment_intent)
      if order.present?
        order.update(state: 'paid')
        OrderMailer.payment_success(order).deliver_now
      else
        Rails.logger.error "Order not found for charge payment intent id: #{charge.payment_intent}"
      end
    else
      puts "Unhandled event type: #{event['type']}"
    end

    render json: { message: 'Success' }
  end
end
