class PaymentsController < ApplicationController
  before_action :set_order, only: [:new, :create]
  before_action :authorize_order, only: [:new, :create]
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    Rails.logger.info "Displaying payment page for order #{@order.id}"
  end

  def create
    Rails.logger.info "Processing payment for order #{@order.id}"

    # Si l'utilisateur n'est pas connecté, met à jour l'email de l'ordre et du GuestUser
    unless user_signed_in?
      email = params[:email]
      Rails.logger.info "Email provided: #{email}"

      if email.blank?
        flash[:alert] = "Email is required."
        Rails.logger.error "No email provided for guest user."
        return redirect_to new_order_payment_path(@order)
      end

      if @order.update(email: email)
        Rails.logger.info "Order email updated to: #{email}"
      else
        Rails.logger.error "Failed to update order email."
      end

      if @order.responder_type == 'GuestUser'
        guest_user = GuestUser.find(@order.responder_id)
        if guest_user.email.blank? && guest_user.update(email: email)
          Rails.logger.info "GuestUser email updated to: #{email}"
        else
          Rails.logger.error "Failed to update GuestUser email."
        end
      end
    else
      # Si l'utilisateur est connecté, on met à jour l'email de l'ordre avec celui de l'utilisateur
      if @order.update(email: current_user.email)
        Rails.logger.info "Order email updated to current user email: #{current_user.email}"
      else
        Rails.logger.error "Failed to update order email for signed-in user."
      end
    end

    # Créer un Customer Stripe avec l'email de l'ordre
    customer = Stripe::Customer.create({
      email: @order.email,
      name: @order.email || "Customer #{@order.id}"
    })
    Rails.logger.info "Created Stripe customer with ID: #{customer.id}"

    # Créer la session Stripe
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      customer: customer.id, # Utilise l'ID du Customer Stripe
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: @order.iqtest.name,
            description: @order.iqtest.description,
            images: ['https://res.cloudinary.com/adrirules/image/upload/v1716276968/OIG1.e77.jpg']
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

    # Mise à jour de la commande avec l'ID de session de paiement Stripe
    if @order.update(checkout_session_id: session.id)
      Rails.logger.info "Updated order #{@order.id} with checkout_session_id #{session.id}"
    else
      Rails.logger.error "Failed to update order with checkout_session_id"
    end

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
