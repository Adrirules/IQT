# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :set_iqtest, only: [:create, :show]

  def create
    iqtest = Iqtest.find(params[:iqtest_id])
    responder = current_user || GuestUser.find_or_create_by(session_id: session.id.to_s)
    order = Order.create!(iqtest: iqtest, responder: responder, state: 'pending')

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        name: iqtest.sku,
        images: [iqtest.photo_url],
        amount: iqtest.price_cents,
        currency: 'usd',
        quantity: 1
      }],
      success_url: order_url(order),
      cancel_url: order_url(order)
    )

    order.update(checkout_session_id: session.id)
    Rails.logger.info "Created Stripe checkout session for order #{order.id} with session id #{session.id}"
    redirect_to new_order_payment_path(order)
  end

  def show
    @order = current_user.order.find(params[:id])
  end

  private

  def set_iqtest
    @iqtest = Iqtest.find(params[:iqtest_id])
  end
end
