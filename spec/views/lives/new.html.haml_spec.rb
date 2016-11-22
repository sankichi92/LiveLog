require 'rails_helper'

RSpec.describe "lives/new", type: :view do
  before(:each) do
    assign(:live, Live.new(
      :name => "MyString",
      :place => "MyString"
    ))
  end

  it "renders new live form" do
    render

    assert_select "form[action=?][method=?]", lives_path, "post" do

      assert_select "input#live_name[name=?]", "live[name]"

      assert_select "input#live_place[name=?]", "live[place]"
    end
  end
end
