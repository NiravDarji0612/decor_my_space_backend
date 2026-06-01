class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email, :phone, :account_type,
             :username, :city, :bio, :avatar_url,
             :email_verified, :phone_verified, :created_at

  def email_verified
    object.email_verified_at.present?
  end

  def phone_verified
    object.phone_verified_at.present?
  end

  def created_at
    object.created_at.iso8601
  end
end
