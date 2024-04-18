class GuestUserPolicy < ApplicationPolicy
  class Scope < Scope

    def show_score?
      true
    end

  end
end
