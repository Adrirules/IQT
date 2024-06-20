class Order < ApplicationRecord
  belongs_to :iqtest
  belongs_to :responder, polymorphic: true

  validates :iqtest_id, uniqueness: { scope: [:responder_id, :responder_type], message: "An order already exists for this test and user" }

  before_save :set_amount, if: :new_record?

  after_create :log_creation
  after_update :log_update


  def pending_order?
    state == 'pending'
  end

  def set_amount
    self.amount_cents = iqtest.price_cents
  end


  def log_creation
    Rails.logger.info "Order #{self.id} created with session ID #{self.checkout_session_id}"
  end

  def log_update
    Rails.logger.info "Order #{self.id} updated: #{self.changes}"
  end

  def self.find_or_create_order(iqtest, responder)
    order = find_or_initialize_by(iqtest: iqtest, responder: responder)
    if order.new_record?
      order.state = 'pending'
      order.save!
    end
    order
  end
end
