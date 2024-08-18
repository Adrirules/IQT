class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET_KEY']

    Rails.logger.info "Payload: #{payload}"
    Rails.logger.info "Signature Header: #{sig_header}"
    Rails.logger.info "Endpoint Secret: #{endpoint_secret}"

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid payload: #{e.message}"
      render json: { message: 'Invalid payload' }, status: :bad_request and return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Invalid signature: #{e.message}"
      render json: { message: 'Invalid signature' }, status: :unauthorized and return
    end

    handle_event(event)
    render json: { message: 'Success' }
  end

  private

  def handle_event(event)
    case event['type']
    when 'payment_intent.succeeded'
      handle_payment_intent_succeeded(event['data']['object'])
    when 'charge.succeeded'
      handle_charge_succeeded(event['data']['object'])
    else
      Rails.logger.info "Unhandled event type: #{event['type']}"
    end
  end

  def handle_payment_intent_succeeded(payment_intent)
    order = Order.find_by(payment_intent_id: payment_intent['id'])
    if order
      if order.state != 'paid'
        order.update(state: 'paid')
        OrderMailer.payment_success(order).deliver_now
      else
        Rails.logger.info "Order already paid. Order ID: #{order.id}"
      end
    else
      Rails.logger.error "Order not found for payment intent id: #{payment_intent['id']}. Payload: #{payment_intent}"
    end
  end

  def handle_charge_succeeded(charge)
    order = Order.find_by(payment_intent_id: charge['payment_intent'])
    if order
      if order.state != 'paid'
        order.update(state: 'paid')
        OrderMailer.payment_success(order).deliver_now
      else
        Rails.logger.info "Order already paid. Order ID: #{order.id}"
      end
    else
      Rails.logger.error "Order not found for charge payment intent id: #{charge['payment_intent']}. Payload: #{charge}"
    end
  end
end
