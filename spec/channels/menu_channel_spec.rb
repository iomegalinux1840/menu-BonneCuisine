require 'rails_helper'

RSpec.describe MenuChannel, type: :channel do
  let(:menu_item) { create(:menu_item) }

  before do
    stub_connection
  end

  it "subscribes to the channel" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("menu_channel")
  end

  describe "broadcasting updates" do
    before { subscribe }

    it "broadcasts when a menu item is created" do
      expect {
        create(:menu_item, name: "New Item")
      }.to have_broadcasted_to("menu_channel").with(hash_including(
        action: 'update',
        html: String
      ))
    end

    it "broadcasts when a menu item is updated" do
      menu_item = create(:menu_item)
      expect {
        menu_item.update(name: "Updated Name")
      }.to have_broadcasted_to("menu_channel").with(hash_including(
        action: 'update'
      ))
    end

    it "broadcasts when a menu item is destroyed" do
      menu_item = create(:menu_item)
      expect {
        menu_item.destroy
      }.to have_broadcasted_to("menu_channel").with(hash_including(
        action: 'delete',
        id: menu_item.id
      ))
    end

    it "broadcasts when availability is toggled" do
      menu_item = create(:menu_item, available: true)
      expect {
        menu_item.update(available: false)
      }.to have_broadcasted_to("menu_channel")
    end
  end
end