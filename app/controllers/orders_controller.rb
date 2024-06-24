# app/controllers/orders_controller.rb
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
      responder = current_user || GuestUser.find_or_create_by(email: email)

      order = Order.find_or_initialize_by(iqtest_id: iqtest.id, responder: responder)
      order.email = email # Assigner l'email récupéré du formulaire à l'order

      authorize order


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
            price_data: {
              currency: 'usd',
              product_data: {
                name: iqtest.name,
                description: iqtest.description,
                images: [iqtest.image].compact # Utilisez l'URL de l'image si disponible
              },
              unit_amount: iqtest.price_cents
            },
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
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error "Stripe error: #{e.message}"
    flash[:alert] = "Une erreur est survenue avec Stripe: #{e.message}. Veuillez réessayer."
    redirect_to iqtests_path
  end

  def show
    @order = current_user.orders.find(params[:id])
    authorize @order
  end

  private

  def set_iqtest
  @iqtest = Iqtest.find(params[:iqtest_id] || order_params[:iqtest_id])
  end

  def order_params
    params.require(:order).permit(:email, :iqtest_id) # Ajout de l'iqtest_id ici
  end
end
