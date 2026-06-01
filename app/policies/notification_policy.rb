class NotificationPolicy < ApplicationPolicy
  def index?;   true; end
  def destroy?; record.user_id == user.id; end
  def read_all?; true; end

  class Scope < ApplicationPolicy::Scope
    def resolve; scope.where(user_id: user.id); end
  end
end
