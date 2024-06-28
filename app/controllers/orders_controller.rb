class OrdersController < ApplicationController
  before_action :set_iqtest, only: [:new, :create, :show]
  skip_before_action :authenticate_user!, only: [:create, :new, :show]

  def new
    @order = Order.new
    authorize @order
  end

  def create
    ActiveRecord::Base.transaction do
      iqtest = Iqtest.find(order_params[:iqtest_id])
      email = order_params[:email]

      # Trouver ou créer le GuestUser avec l'email collecté
      responder = current_user || GuestUser.find_or_initialize_by(session_id: session[:guest_user_session_id])
      responder.email = email
      responder.save!

      order = Order.new(iqtest_id: iqtest.id, responder: responder, email: email)
      authorize order

      if order.save
        Rails.logger.info "Order #{order.id} created with state #{order.state}"
        redirect_to new_order_payment_path(order)
      else
        flash[:alert] = "Unable to create order. Please try again."
        redirect_to iqtests_path
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "Validation failed: #{e.message}"
      redirect_to new_order_path
    end
  end





  def show
    @order = Order.find(params[:id])
    authorize @order
  end

  private

  def set_iqtest
    @iqtest = Iqtest.find(params[:iqtest_id] || order_params[:iqtest_id])
  end

  def order_params
    params.require(:order).permit(:email, :iqtest_id)
  end

def create_stripe_session(order, iqtest)
    # Assure-toi que l'utilisateur a un ID valide
    return unless order.responder&.id

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: iqtest.name,
            description: iqtest.description,
            images: [iqtest.image].compact
          },
          unit_amount: iqtest.price_cents
        },
        quantity: 1
      }],
      success_url: show_score_url(iqtest_id: iqtest.id, user_type: order.responder_type, user_id: order.responder_id),
      cancel_url: iqtest_url(iqtest)
    )

    order.update!(checkout_session_id: session.id)
  end
end
