# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :set_iqtest, only: [:create, :show]

  def create
    ActiveRecord::Base.transaction do
      iqtest = Iqtest.find(params[:iqtest_id])
      responder = current_user || GuestUser.find_or_create_by(session_id: session.id.to_s)

      # Rechercher un ordre existant ou en créer un nouveau
      order = Order.find_or_initialize_by(iqtest_id: iqtest.id, responder: responder)
      if order.new_record? && Order.where(iqtest_id: iqtest.id, responder: responder, state: 'pending').none?
        order.state = 'pending'
        order.save!
        Rails.logger.info "Order #{order.id} created with state #{order.state}"
      else
        Rails.logger.info "Order already exists with ID #{order.id} and state #{order.state}"
      end

      if order.checkout_session_id.blank?
        session = Stripe::Checkout::Session.create(
          payment_method_types: ['card'],
          line_items: [{
            name: iqtest.name,
            images: [iqtest.image].compact, # S'assurer que l'image existe
            amount: iqtest.price_cents,
            currency: 'usd',
            quantity: 1
          }],
          success_url: order_url(order),
          cancel_url: order_url(order)
        )
        order.update!(checkout_session_id: session.id)
      end
    end

    redirect_to new_order_payment_path(order)
  rescue ActiveRecord::RecordInvalid => e
    # Gérer l'erreur, par exemple en affichant un message à l'utilisateur
    flash[:alert] = "Une erreur est survenue lors de la création de votre commande. Veuillez réessayer."
    redirect_to iqtests_path
  end

  def show
    @order = current_user.order.find(params[:id])
  end

  private

  def set_iqtest
    @iqtest = Iqtest.find(params[:iqtest_id])
  end
end
