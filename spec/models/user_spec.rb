# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it 'is valid with all attributes' do
    expect(user).to be_valid
  end

  it 'requires full_name' do
    user.full_name = ''
    expect(user).not_to be_valid
    expect(user.errors[:full_name]).to include("can't be blank")
  end

  it 'requires valid email' do
    user.email = 'notanemail'
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include('must be a valid email address')
  end

  it 'requires unique email' do
    create(:user, email: user.email)
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'requires password minimum 8 characters' do
    user.password = 'short'
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
  end

  it 'requires accepted_terms' do
    user.accepted_terms = false
    expect(user).not_to be_valid
    expect(user.errors[:accepted_terms]).to include('must be accepted')
  end

  it 'normalizes email to lowercase' do
    user.email = '  USER@Example.COM  '
    expect(user.email).to eq('user@example.com')
  end

  it 'supports account_type enum' do
    user.account_type = 'vendor'
    expect(user).to be_vendor
    user.account_type = 'customer'
    expect(user).to be_customer
  end
end
