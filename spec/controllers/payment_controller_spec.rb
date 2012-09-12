require 'spec_helper'

describe PaymentController do

  describe "GET 'checkout'" do
    it "should be successful" do
      get 'checkout'
      response.should be_success
    end
  end

  describe "GET 'confirm'" do
    it "should be successful" do
      get 'confirm'
      response.should be_success
    end
  end

  describe "GET 'complete'" do
    it "should be successful" do
      get 'complete'
      response.should be_success
    end
  end

end
