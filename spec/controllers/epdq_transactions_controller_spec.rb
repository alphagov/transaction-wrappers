require 'spec_helper'

describe EpdqTransactionsController do

  describe "redirection to start page" do
    it "returns 404 status if slug is empty" do
      get :show, :slug => ""
      response.should be_not_found
    end

    it "returns 404 status if slug is not found" do
      get :show, :slug => "pay-for-all-the-things"
      response.should be_not_found
    end

    it "redirects to the start page for a valid slug" do
      get :show, :slug => "pay-foreign-marriage-certificates"
      response.should redirect_to("/pay-foreign-marriage-certificates/start")
    end
  end

  describe "start pages" do
    it "returns 404 status if slug is empty" do
      get :start, :slug => ""
      response.should be_not_found
    end

    it "returns 404 status if slug is not found" do
      get :start, :slug => "pay-for-all-the-things"
      response.should be_not_found
    end

    context "given a valid transaction as the slug" do
      before do
        get :start, :slug => "pay-foreign-marriage-certificates"
      end

      it "is successful" do
        response.should be_success
      end

      it "renders the start template" do
        @controller.should render_template("start")
      end

      it "assigns the transaction details" do
        assigns(:transaction).title.should == "Payment for certificates to get married abroad"
        assigns(:transaction).slug.should == "pay-foreign-marriage-certificates"
        assigns(:transaction).document_cost.should == 65
        assigns(:transaction).registration.should be_false
      end
    end
  end

  describe "confirm pages" do
    it "returns 404 status if slug is empty" do
      post :confirm, :slug => ""
      response.should be_not_found
    end

    it "builds an epdq request with the correct account" do
      EPDQ::Request.should_receive(:new).with(hash_including(:account => "legalisation-drop-off"))

      post :confirm, :slug => "pay-legalisation-drop-off", :transaction => { :document_count => "5" }
    end

    describe "with multiple document types" do
      context "given valid values" do
        before do
          post :confirm, :slug => "pay-foreign-marriage-certificates", :transaction => {
            :document_count => "5",
            :postage => "yes",
            :document_type => "nulla-osta"
          }
        end

        it "should calculate the correct total cost" do
          assigns(:calculation).total_cost.should == 335
          assigns(:calculation).item_list.should == "5 Nulla Ostas plus postage"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the confirm template" do
          @controller.should render_template("confirm")
        end

        it "assigns the transaction details" do
          assigns(:transaction).title.should == "Payment for certificates to get married abroad"
          assigns(:transaction).slug.should == "pay-foreign-marriage-certificates"
        end

        it "assigns an EPDQ request with the correct amount" do
          assigns(:epdq_request).parameters[:orderid].should_not be_blank
          assigns(:epdq_request).parameters[:amount].should == 33500
          assigns(:epdq_request).parameters[:accepturl].should == "http://www.dev.gov.uk/pay-foreign-marriage-certificates/done"
        end
      end

      context "given no document type" do
        before do
          post :confirm, :slug => "pay-foreign-marriage-certificates", :transaction => {
            :document_count => "5",
            :postage => "yes",
          }
        end

        it "renders the start template" do
          @controller.should render_template("start")
        end

        it "assigns an error message" do
          assigns(:errors).should =~ [:document_type]
        end
      end

      context "given an invalid document type" do
        before do
          post :confirm, :slug => "pay-foreign-marriage-certificates", :transaction => {
            :document_count => "5",
            :postage => "yes",
            :document_type => "nyan"
          }
        end

        it "renders the start template" do
          @controller.should render_template("start")
        end

        it "assigns an error message" do
          assigns(:errors).should =~ [:document_type]
        end
      end
    end

    describe "with registration count" do
      context "given valid values" do
        before do
          post :confirm, :slug => "pay-register-birth-abroad", :transaction => {
            :registration_count => "5",
            :document_count => "5",
            :postage => "yes"
          }
        end

        it "should calculate the correct total cost" do
          assigns(:calculation).total_cost.should == 860
          assigns(:calculation).item_list.should == "5 birth registrations and 5 birth certificates plus postage"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the confirm template" do
          @controller.should render_template("confirm")
        end

        it "assigns the transaction details" do
          assigns(:transaction).title.should == "Payment to register a birth abroad"
          assigns(:transaction).slug.should == "pay-register-birth-abroad"
        end

        it "assigns an EPDQ request with the correct amount" do
          assigns(:epdq_request).parameters[:orderid].should_not be_blank
          assigns(:epdq_request).parameters[:amount].should == 86000
          assigns(:epdq_request).parameters[:accepturl].should == "http://www.dev.gov.uk/pay-register-birth-abroad/done"
        end
      end
    end

    describe "without multiple document types" do
      context "given valid values" do
        before do
          post :confirm, :slug => "deposit-foreign-marriage", :transaction => {
            :document_count => "3",
            :postage => "no"
          }
        end

        it "should calculate the correct total cost" do
          assigns(:calculation).total_cost.should == 105
          assigns(:calculation).item_list.should == "3 documents"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the confirm template" do
          @controller.should render_template("confirm")
        end
      end
    end
  end

  describe "done pages" do
    it "returns 404 status if slug is empty" do
      post :confirm, :slug => ""
      response.should be_not_found
    end

    it "should build an EPDQ response for the correct account" do
      response_stub = stub(:valid_shasign? => true)
      EPDQ::Response.should_receive(:new).with(anything(), "birth-death-marriage", Transaction::PARAMPLUS_KEYS)
        .and_return(response_stub)

      get :done, :slug => "deposit-foreign-marriage"
    end

    describe "for a standard transaction" do
      context "given valid parameters" do
        before do
          get :done, :slug => "deposit-foreign-marriage",
            "orderID" => "test",
            "currency" => "GBP",
            "amount" => 45,
            "PM" => "CreditCard",
            "ACCEPTANCE" => "test123",
            "STATUS" => 5,
            "CARDNO" => "XXXXXXXXXXXX1111",
            "CN" => "MR MICKEY MOUSE",
            "TRXDATE" => "03/11/13",
            "PAYID" => 12345678,
            "NCERROR" => 0,
            "BRAND" => "VISA",
            "SHASIGN" => "6ACE8B0C8E0B427137F6D7FF86272AA570255003",
            "document_count" => "3",
            "postage" => "yes"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the done template" do
          @controller.should render_template("done")
        end

        it "assigns the transaction details" do
          assigns(:transaction).title.should == "Deposit foreign marriage or civil partnership certificates"
          assigns(:transaction).slug.should == "deposit-foreign-marriage"
        end

        it "assigns the epdq response" do
          assigns(:epdq_response).parameters[:payid].should == "12345678"
          assigns(:epdq_response).parameters[:orderid].should == "test"

          assigns(:epdq_response).parameters[:document_count].should == "3"
          assigns(:epdq_response).parameters[:postage].should == "yes"
        end
      end

      context "given invalid parameters" do
        before do
          get :done, :slug => "deposit-foreign-marriage",
            "orderID" => "test",
            "currency" => "GBP",
            "amount" => 45,
            "PM" => "CreditCard",
            "ACCEPTANCE" => "test123",
            "STATUS" => 5,
            "CARDNO" => "XXXXXXXXXXXX1111",
            "CN" => "MR MICKEY MOUSE",
            "TRXDATE" => "03/11/13",
            "PAYID" => 12345678,
            "NCERROR" => 0,
            "BRAND" => "VISA",
            "SHASIGN" => "something which is not correct"
        end

        it "should be successful" do
          response.should be_success
        end

        it "should render the error template" do
          @controller.should render_template("error")
        end
      end

    end
  end

end
