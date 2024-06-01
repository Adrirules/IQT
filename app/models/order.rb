class Order < ApplicationRecord
  belongs_to :iqtest
  belongs_to :responder, polymorphic: true

  validates :iqtest_id, uniqueness: { scope: [:responder_id, :responder_type], message: "An order already exists for this test and user" }, unless: :pending_order?
  validates :checkout_session_id, uniqueness: true, allow_nil: true

  before_save :set_amount, if: :new_record?



  def pending_order?
    state == 'pending'
  end

  def set_amount
    self.amount_cents = iqtest.price_cents
  end

   def self.find_or_create_order(iqtest, responder)
    transaction do
      order = find_or_initialize_by(iqtest: iqtest, responder: responder)
      if order.new_record?
        order.state = 'pending'
        order.save!
      elsif order.state != 'paid'
        order.update!(state: 'pending')
      end
      order
    end
  end
end
