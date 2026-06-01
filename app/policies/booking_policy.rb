class BookingPolicy < ApplicationPolicy
  def index?;  true; end
  def show?;   record.user_id == user.id; end
  def create?; true; end
  def cancel?; record.user_id == user.id; end
  def review?; record.user_id == user.id; end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
