class PaymentMethodPolicy < ApplicationPolicy
  def index?;   true; end
  def create?;  true; end
  def destroy?; owned?; end
  def default?; owned?; end

  private def owned?; record.user_id == user.id; end

  class Scope < ApplicationPolicy::Scope
    def resolve; scope.where(user_id: user.id); end
  end
end
