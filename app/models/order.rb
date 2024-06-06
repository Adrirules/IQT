class Order < ApplicationRecord
  belongs_to :iqtest
  belongs_to :responder, polymorphic: true

  validates :iqtest_id, uniqueness: { scope: [:responder_id, :responder_type], message: "An order already exists for this test and user" }, unless: :pending_order?

  before_save :set_amount, if: :new_record?

  after_update :log_update

  def pending_order?
    state == 'pending'
  end

  def set_amount
    self.amount_cents = iqtest.price_cents
  end

  def log_update
    Rails.logger.info "Order #{self.id} updated: #{self.changes}"
  end

  def self.find_or_create_order(iqtest, responder)
    order = find_by(iqtest: iqtest, responder: responder)
    if order.nil?
      order = create!(iqtest: iqtest, responder: responder, state: 'pending')
    elsif order.state != 'paid'
      order.update(state: 'pending')
    end
    order
  end
end
