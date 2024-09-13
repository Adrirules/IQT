class OrderMailer < ApplicationMailer
   default from: 'hello@iqtestbrain.com'

  def payment_success(order)
    @order = order
    @user = @order.responder

    mail(to: @user.email, subject: 'Payment Confirmation')
  end
end

