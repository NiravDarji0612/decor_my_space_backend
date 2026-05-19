class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email, :phone, :account_type, :created_at

  def created_at
    object.created_at.iso8601
  end
end
