# app/policies/order_policy.rb
class OrderPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    new?
  end

  def show?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  private

  def user_is_responder?
    record.responder == user || (user.is_a?(GuestUser) && record.responder_type == 'GuestUser' && record.responder_id == user.id)
  end
end
