require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      menu_item = build(:menu_item)
      expect(menu_item).to be_valid
    end

    it 'is not valid without a name' do
      menu_item = build(:menu_item, name: nil)
      expect(menu_item).not_to be_valid
      expect(menu_item.errors[:name]).to include("ne peut pas être vide")
    end

    it 'is not valid without a price' do
      menu_item = build(:menu_item, price: nil)
      expect(menu_item).not_to be_valid
      expect(menu_item.errors[:price]).to include("ne peut pas être vide")
    end

    it 'is not valid with negative price' do
      menu_item = build(:menu_item, price: -5)
      expect(menu_item).not_to be_valid
      expect(menu_item.errors[:price]).to include("doit être supérieur à 0")
    end

    it 'is not valid without a position' do
      menu_item = build(:menu_item, position: nil)
      expect(menu_item).not_to be_valid
      expect(menu_item.errors[:position]).to include("ne peut pas être vide")
    end
  end

  describe 'callbacks' do
    it 'sets position before validation if not present' do
      create(:menu_item, position: 1)
      menu_item = build(:menu_item, position: nil)
      menu_item.valid?
      expect(menu_item.position).to eq(2)
    end

    it 'broadcasts updates after save' do
      expect(ActionCable.server).to receive(:broadcast).with(
        'menu_channel',
        hash_including(action: 'update')
      )
      create(:menu_item)
    end

    it 'broadcasts deletion after destroy' do
      menu_item = create(:menu_item)
      expect(ActionCable.server).to receive(:broadcast).with(
        'menu_channel',
        hash_including(action: 'delete', id: menu_item.id)
      )
      menu_item.destroy
    end
  end

  describe 'scopes' do
    before do
      create(:menu_item, available: true, position: 2)
      create(:menu_item, available: false, position: 1)
      create(:menu_item, available: true, position: 3)
    end

    it 'returns only available items' do
      expect(MenuItem.available.count).to eq(2)
    end

    it 'orders by position' do
      items = MenuItem.ordered
      expect(items.first.position).to eq(1)
      expect(items.last.position).to eq(3)
    end
  end
end