# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  before_action :set_order, only: [:new, :create]
  before_action :authorize_order, only: [:new, :create]

  def new
    Rails.logger.info "Displaying payment page for order #{@order.id}"
  end

  def create
    Rails.logger.info "Processing payment for order #{@order.id}"

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: @order.iqtest.name,
          },
          unit_amount: @order.amount_cents,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: show_score_url(iqtest_id: @order.iqtest.id, user_type: @order.responder_type, user_id: @order.responder_id),
      cancel_url: new_order_payment_url(@order)
    )

    @order.update(checkout_session_id: session.id)
    Rails.logger.info "Updated order #{@order.id} with checkout_session_id #{session.id}"
    redirect_to session.url, allow_other_host: true
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
    Rails.logger.info "Loaded order #{@order.id} in set_order"
  end

  def authorize_order
    authorize @order, :new?
  end
end
