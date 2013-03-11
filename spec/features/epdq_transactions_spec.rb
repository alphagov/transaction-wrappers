#coding: utf-8
require "spec_helper"

feature "epdq transactions" do

  describe "paying for a certificate for marriage" do
    it "renders the content and form" do
      visit "/pay-for-certificates-for-marriage"

      within(:css, "header.page-header") do
        page.should have_content("Pay for certificates for marriage")
      end

      within(:css, "form") do
        page.should have_no_content("How many birth registrations do you need to register?")

        page.should have_content("What type of document do you require?")
        page.should have_unchecked_field("Certificate of no impediment")
        page.should have_unchecked_field("Nulla osta")
        page.should have_unchecked_field("Certificate of custom law")

        page.should have_content("How many documents do you require?")
        page.should have_content("Each document costs £65.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("Do you require postage? This costs £10.")
        page.should have_select("transaction_postage", :options => ["Yes", "No"])

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/pay-for-certificates-for-marriage"

        within(:css, "form") do
          choose "Certificate of custom law"
          select "3", :from => "How many documents do you require?"
          select "Yes", :from => "Do you require postage?"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("The cost for 3 Certificates of custom law, plus postage, is £205")
      end

      it "generates an EPDQ form" do
        page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

        within(:css, "form.epdq-submit") do
          page.should have_selector("input[name='ORDERID']")
          page.should have_selector("input[name='PSPID']")
          page.should have_selector("input[name='SHASIGN']")

          page.should have_selector("input[name='AMOUNT'][value='20500']")
          page.should have_selector("input[name='CURRENCY'][value='GBP']")
          page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-for-certificates-for-marriage/done']")

          page.should have_button("Pay")
        end
      end
    end

    it "displays an error and renders the form given incorrect data" do
      visit "/pay-for-certificates-for-marriage"

      within(:css, "form") do
        select "3", :from => "How many documents do you require?"
        select "Yes", :from => "Do you require postage?"
      end

      click_on "Calculate total"

      page.should have_selector("p.error-message", :text => "Please choose a document type")
      page.should have_content("What type of document do you require?")
    end

    describe "visiting the done page" do
      context "given valid payment details" do
        before do
          visit "/pay-for-certificates-for-marriage/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MR+MICKEY+MOUSE&TRXDATE=03%2F11%2F13&PAYID=12345678&NCERROR=0&BRAND=VISA&SHASIGN=6ACE8B0C8E0B427137F6D7FF86272AA570255003"
        end

        it "should display the done page content" do
          within(:css, "header.page-header") do
            page.should have_content("Pay for certificates for marriage")
          end

          page.should have_content("Your payment to the Foreign & Commonwealth Office is complete.")
        end

        it "should display the order number" do
          page.should have_content("12345678")
        end
      end

      context "invalid payment details" do
        before do
          visit "/pay-for-certificates-for-marriage/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MISS+MINNIE+MOUSE&SHASIGN=yarrrrr"
        end

        it "should display the error page content" do
          within(:css, "header.page-header") do
            page.should have_content("Pay for certificates for marriage")
          end

          page.should have_content("There was a problem making your payment to the Foreign & Commonwealth Office.")
        end
      end
    end
  end

  describe "paying to register a birth abroad" do
    it "renders the content and form" do
      visit "/pay-to-register-birth-abroad"

      within(:css, "header.page-header") do
        page.should have_content("Pay to register a birth abroad in the UK")
      end

      within(:css, "form") do
        page.should have_content("How many birth registrations do you need to register?")
        page.should have_content("Each registration costs £105.")
        page.should have_select("transaction_registration_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("How many birth certificates do you require?")
        page.should have_content("Each certificate costs £65.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("Do you require postage? This costs £10.")
        page.should have_select("transaction_postage", :options => ["Yes", "No"])

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/pay-to-register-birth-abroad"

        within(:css, "form") do
          select "2", :from => "How many birth registrations do you need to register?"
          select "3", :from => "How many birth certificates do you require?"
          select "Yes", :from => "Do you require postage?"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("The cost for 2 birth registrations and 3 birth certificates, plus postage, is £415")
      end

      it "generates an EPDQ form" do
        page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

        within(:css, "form.epdq-submit") do
          page.should have_selector("input[name='ORDERID']")
          page.should have_selector("input[name='PSPID']")
          page.should have_selector("input[name='SHASIGN']")

          page.should have_selector("input[name='AMOUNT'][value='41500']")
          page.should have_selector("input[name='CURRENCY'][value='GBP']")
          page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-to-register-birth-abroad/done']")

          page.should have_button("Pay")
        end
      end
    end
  end

  it "renders a 404 error on for an invalid transaction slug" do
    visit "/pay-for-bunting"

    page.status_code.should == 404
  end

end
