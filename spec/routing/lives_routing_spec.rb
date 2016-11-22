require "rails_helper"

RSpec.describe LivesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/lives").to route_to("lives#index")
    end

    it "routes to #new" do
      expect(:get => "/lives/new").to route_to("lives#new")
    end

    it "routes to #show" do
      expect(:get => "/lives/1").to route_to("lives#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/lives/1/edit").to route_to("lives#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/lives").to route_to("lives#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/lives/1").to route_to("lives#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/lives/1").to route_to("lives#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/lives/1").to route_to("lives#destroy", :id => "1")
    end

  end
end
