require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      admin = build(:admin)
      expect(admin).to be_valid
    end

    it 'is not valid without an email' do
      admin = build(:admin, email: nil)
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("ne peut pas être vide")
    end

    it 'is not valid with duplicate email' do
      create(:admin, email: 'test@labonnecuisine.fr')
      admin = build(:admin, email: 'test@labonnecuisine.fr')
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("a déjà été pris")
    end

    it 'is not valid with invalid email format' do
      admin = build(:admin, email: 'invalid-email')
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("n'est pas valide")
    end

    it 'is not valid without a password' do
      admin = Admin.new(email: 'test@labonnecuisine.fr', password: nil)
      expect(admin).not_to be_valid
    end

    it 'is not valid with short password' do
      admin = build(:admin, password: '123', password_confirmation: '123')
      expect(admin).not_to be_valid
      expect(admin.errors[:password]).to include("est trop court (minimum 6 caractères)")
    end
  end

  describe 'authentication' do
    let(:admin) { create(:admin, password: 'password123') }

    it 'authenticates with correct password' do
      expect(admin.authenticate('password123')).to eq(admin)
    end

    it 'does not authenticate with incorrect password' do
      expect(admin.authenticate('wrong')).to be_falsey
    end
  end
end