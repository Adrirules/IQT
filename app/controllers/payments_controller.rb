class PaymentsController < ApplicationController
  before_action :set_order, only: [:new, :create]
  before_action :authorize_order, only: [:new, :create]
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    Rails.logger.info "Displaying payment page for order #{@order.id}"
  end

  def create
    Rails.logger.info "Processing payment for order #{@order.id}"

    # Si l'utilisateur n'est pas connecté, met à jour l'email de l'order et du GuestUser
    unless user_signed_in?
      email = params[:email]
      if email.blank?
        flash[:alert] = "Email is required."
        return redirect_to new_order_payment_path(@order)
      end

      @order.update(email: email)
      if @order.responder_type == 'GuestUser'
        guest_user = GuestUser.find(@order.responder_id)
        guest_user.update(email: email) if guest_user.email.blank?
      end
    end

    # Créer la session Stripe
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: @order.iqtest.name,
            description: @order.iqtest.description,
            images: [@order.iqtest.image.attached? ? url_for(@order.iqtest.image) : nil].compact
          },
          unit_amount: @order.amount_cents,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: show_score_url(iqtest_id: @order.iqtest.id, user_type: @order.responder_type, user_id: @order.responder_id),
      cancel_url: new_order_payment_url(@order),
      locale: 'en'
    )

    @order.update(checkout_session_id: session.id)
    Rails.logger.info "Updated order #{@order.id} with checkout_session_id #{session.id}"
    redirect_to session.url, allow_other_host: true
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error "Stripe error: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
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
