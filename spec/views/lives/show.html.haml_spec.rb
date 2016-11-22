require 'rails_helper'

RSpec.describe "lives/show", type: :view do
  before(:each) do
    @live = assign(:live, Live.create!(
      :name => "Name",
      :place => "Place"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Place/)
  end
end
