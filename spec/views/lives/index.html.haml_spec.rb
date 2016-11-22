require 'rails_helper'

RSpec.describe "lives/index", type: :view do
  before(:each) do
    assign(:lives, [
      Live.create!(
        :name => "Name",
        :place => "Place"
      ),
      Live.create!(
        :name => "Name",
        :place => "Place"
      )
    ])
  end

  it "renders a list of lives" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Place".to_s, :count => 2
  end
end
