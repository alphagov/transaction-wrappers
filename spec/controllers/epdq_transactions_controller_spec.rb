require 'spec_helper'

describe EpdqTransactionsController do

  describe "start pages" do
    it "returns 404 status if slug is empty" do
      get :start, :slug => ""
      response.should be_not_found
    end

    context "given a valid transaction as the slug" do
      before do
        get :start, :slug => "pay-for-certificates-for-marriage"
      end

      it "is successful" do
        response.should be_success
      end

      it "renders the start template" do
        @controller.should render_template("start")
      end

      it "assigns the transaction details" do
        assigns(:transaction)[:title].should == "Pay for certificates for marriage"
        assigns(:transaction)[:slug].should == "pay-for-certificates-for-marriage"
        assigns(:transaction)[:document_cost].should == 65
        assigns(:transaction)[:registration].should be_false
      end
    end

  end

end
