require 'rails_helper'

RSpec.describe "lives/edit", type: :view do
  before(:each) do
    @live = assign(:live, Live.create!(
      :name => "MyString",
      :place => "MyString"
    ))
  end

  it "renders the edit live form" do
    render

    assert_select "form[action=?][method=?]", live_path(@live), "post" do

      assert_select "input#live_name[name=?]", "live[name]"

      assert_select "input#live_place[name=?]", "live[place]"
    end
  end
end
