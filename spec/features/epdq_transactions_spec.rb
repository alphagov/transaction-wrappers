#coding: utf-8
require "spec_helper"

feature "epdq transactions" do

  describe "paying for a certificate for marriage" do
    it "redirects to the start page" do
      visit "/pay-foreign-marriage-certificates"

      within(:css, ".inner") do
        page.should have_content("Pay for documents you need from the Foreign & Commonwealth Office (FCO) to prove you’re allowed to get married abroad.")
        current_path.should == "/pay-foreign-marriage-certificates/start"
      end
    end

    it "renders the content and form" do
      visit "/pay-foreign-marriage-certificates/start"

      within(:css, "header.page-header") do
        page.should have_content("Payment for certificates to get married abroad")
      end

      within(:css, "form") do
        page.should have_content("Pay for documents you need from the Foreign & Commonwealth Office (FCO) to prove you’re allowed to get married abroad.")
        page.should have_unchecked_field("Certificate of no impediment")
        page.should have_unchecked_field("Nulla Osta")
        page.should have_unchecked_field("Certificate of custom law")

        page.should have_content("Each certificate costs £65.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("Do you want to pay the £10 postage fee to have your documents returned?")
        page.should have_select("transaction_postage", :options => ["Yes", "No"])

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/pay-foreign-marriage-certificates/start"

        within(:css, "form") do
          choose "Certificate of custom law"
          select "3", :from => "transaction_document_count"
          select "Yes", :from => "transaction_postage"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("The cost of 3 Certificates of custom law plus postage is £205")
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
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-foreign-marriage-certificates/done']")
          page.should have_selector("input[name='PARAMPLUS'][value='document_count=3&postage=yes']")

          page.should have_button("Pay")
        end
      end
    end

    it "displays an error and renders the form given incorrect data" do
      visit "/pay-foreign-marriage-certificates/start"

      within(:css, "form") do
        select "3", :from => "transaction_document_count"
        select "Yes", :from => "transaction_postage"
      end

      click_on "Calculate total"

      page.should have_selector("p.error-message", :text => "Please choose a document type")
      page.should have_content("Which type of certificate do you need?")
    end

    describe "visiting the done page" do
      context "given valid payment details" do
        before do
          visit "/pay-foreign-marriage-certificates/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MR+MICKEY+MOUSE&TRXDATE=03%2F11%2F13&PAYID=12345678&NCERROR=0&BRAND=VISA&SHASIGN=6ACE8B0C8E0B427137F6D7FF86272AA570255003&document_count=5&postage=yes"
        end

        it "should display the done page content" do
          within(:css, "header.page-header") do
            page.should have_content("Payment for certificates to get married abroad")
          end

          page.should have_content("Your payment reference is")
        end

        it "should display the order number" do
          page.should have_content("12345678")
        end

        it "should display the number of documents ordered" do
          page.should have_content("You have paid for 5 certificates plus postage.")
        end
      end

      context "given valid payment details and additional parameters" do
        before do
          visit "/pay-foreign-marriage-certificates/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MR+MICKEY+MOUSE&TRXDATE=03%2F11%2F13&PAYID=12345678&NCERROR=0&BRAND=VISA&SHASIGN=6ACE8B0C8E0B427137F6D7FF86272AA570255003&registration_count=1&document_count=4"
        end

        it "should display the number of documents ordered" do
          page.should have_content("You have paid for 1 registration and 4 certificates.")
        end
      end

      context "invalid payment details" do
        before do
          visit "/pay-foreign-marriage-certificates/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MISS+MINNIE+MOUSE&SHASIGN=yarrrrr"
        end

        it "should display the error page content" do
          within(:css, "header.page-header") do
            page.should have_content("Payment for certificates to get married abroad")
          end

          page.should have_content("There was a problem making your payment to the Foreign & Commonwealth Office.")
        end
      end
    end
  end

  describe "paying to register a birth abroad" do
    it "renders the content and form" do
      visit "/pay-register-birth-abroad/start"

      within(:css, "header.page-header") do
        page.should have_content("Payment to register a birth abroad")
      end

      within(:css, "form") do
        page.should have_content("How many registrations do you need to pay for? Each one costs £105.")
        page.should have_select("transaction_registration_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("How many birth certificates do you need?")
        page.should have_content("Each one costs £65.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("Do you require postage? This costs £10.")
        page.should have_select("transaction_postage", :options => ["Yes", "No"])

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/pay-register-birth-abroad/start"

        within(:css, "form") do
          select "2", :from => "transaction_registration_count"
          select "3", :from => "transaction_document_count"
          select "Yes", :from => "Do you require postage?"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("The cost for 2 registrations and 3 certificates is £415")
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
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-register-birth-abroad/done']")

          page.should have_button("Pay")
        end
      end
    end
  end

  describe "paying to register a death abroad" do
    it "renders the content and form" do
      visit "/pay-register-death-abroad/start"

      within(:css, "header.page-header") do
        page.should have_content("Payment to register a death abroad")
      end

      within(:css, "form") do
        page.should have_content("Pay the Foreign & Commonwealth Office (FCO) to register the death of a British national abroad.")
        page.should have_content("Each one costs £105.")
        page.should have_select("transaction_registration_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("How many death certificates do you need?")
        page.should have_content("Each one costs £65.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("Do you want to pay the £10 postage fee to have your documents returned?")
        page.should have_select("transaction_postage", :options => ["Yes", "No"])

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/pay-register-death-abroad/start"

        within(:css, "form") do
          select "5", :from => "transaction_registration_count"
          select "1", :from => "transaction_document_count"
          select "Yes", :from => "transaction_postage"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("The cost for 5 registrations and 1 certificate plus postage is £600")
      end

      it "generates an EPDQ form" do
        page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

        within(:css, "form.epdq-submit") do
          page.should have_selector("input[name='ORDERID']")
          page.should have_selector("input[name='PSPID']")
          page.should have_selector("input[name='SHASIGN']")

          page.should have_selector("input[name='AMOUNT'][value='60000']")
          page.should have_selector("input[name='CURRENCY'][value='GBP']")
          page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-register-death-abroad/done']")

          page.should have_button("Pay")
        end
      end
    end
  end

  describe "paying to deposit marriage and civil partnership documents" do
    it "renders the content and form" do
      visit "/deposit-foreign-marriage/start"

      within(:css, "header.page-header") do
        page.should have_content("Deposit foreign marriage or civil partnership certificates")
      end

      within(:css, "form") do
        page.should have_content("Deposit your marriage or civil partnership certificate at the General Register Office (GRO) for safe-keeping if you got married aboard and you’re resident in the UK.")

        page.should have_content("Each one costs £35.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("Do you want to pay the £10 postage fee to have your documents returned?")
        page.should have_select("transaction_postage", :options => ["Yes", "No"])

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/deposit-foreign-marriage/start"

        within(:css, "form") do
          select "1", :from => "transaction_document_count"
          select "Yes", :from => "transaction_postage"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("The cost to deposit 1 certificate plus postage is £45")
      end

      it "generates an EPDQ form" do
        page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

        within(:css, "form.epdq-submit") do
          page.should have_selector("input[name='ORDERID']")
          page.should have_selector("input[name='PSPID']")
          page.should have_selector("input[name='SHASIGN']")

          page.should have_selector("input[name='AMOUNT'][value='4500']")
          page.should have_selector("input[name='CURRENCY'][value='GBP']")
          page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/deposit-foreign-marriage/done']")

          page.should have_button("Pay")
        end
      end
    end
  end

  describe "paying to get a document legalised by post" do
    it "renders the content and form" do
      visit "/pay-legalisation-post/start"

      within(:css, "header.page-header") do
        page.should have_content("Pay to legalise documents by post")
      end

      within(:css, "form") do
        page.should have_content("How many documents do you want legalised?")

        page.should have_content("Each document costs £30.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("How would you like your documents sent back to you?")
        page.should have_unchecked_field("Courier or prepaid envelope - £0")
        page.should have_unchecked_field("Delivery to the United Kingdom or British Forces Post Office - £6")
        page.should have_unchecked_field("Delivery to the United Kingdom or British Forces Post Office, with insurance - £12")
        page.should have_unchecked_field("Europe (excluding Russia, Turkey, Bosnia, Croatia, Albania, Belarus, Macedonia, Moldova, Montenegro, Ukraine) - £14.50")
        page.should have_unchecked_field("Rest of the World - £25")

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/pay-legalisation-post/start"

        within(:css, "form") do
          select "1", :from => "transaction_document_count"
          choose "Rest of the World - £25"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("It costs £55 for 1 document plus Rest of the World postage")
      end

      it "generates an EPDQ form" do
        page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

        within(:css, "form.epdq-submit") do
          page.should have_selector("input[name='ORDERID']")
          page.should have_selector("input[name='PSPID']")
          page.should have_selector("input[name='SHASIGN']")

          page.should have_selector("input[name='AMOUNT'][value='5500']")
          page.should have_selector("input[name='CURRENCY'][value='GBP']")
          page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-legalisation-post/done']")

          page.should have_button("Pay")
        end
      end
    end

    it "displays an error and renders the form given incorrect data" do
      visit "/pay-legalisation-post/start"

      within(:css, "form") do
        select "3", :from => "transaction_document_count"
      end

      click_on "Calculate total"

      page.should have_selector("p.error-message", :text => "Please choose a postage option")
      page.should have_content("How would you like your documents sent back to you?")
    end
  end

  describe "paying to get a document legalised using the drop-off service" do
    it "renders the content and form" do
      visit "/pay-legalisation-drop-off/start"

      within(:css, "header.page-header") do
        page.should have_content("Pay to legalise documents using the drop-off service")
      end

      within(:css, "form") do
        page.should have_content("How many documents do you want legalised?")

        page.should have_content("Each document costs £75.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_no_content("Which postage method do you require?")
        page.should have_no_content("Do you require postage?")
        page.should have_no_select("transaction_postage")

        page.should have_button("Calculate total")
      end
    end

    context "given correct data" do
      before do
        visit "/pay-legalisation-drop-off/start"

        within(:css, "form") do
          select "5", :from => "transaction_document_count"
        end

        click_on "Calculate total"
      end

      it "calculates a total" do
        page.should have_content("It costs £375 for 5 documents")
      end

      it "generates an EPDQ form" do
        page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

        within(:css, "form.epdq-submit") do
          page.should have_selector("input[name='ORDERID']")
          page.should have_selector("input[name='PSPID']")
          page.should have_selector("input[name='SHASIGN']")

          page.should have_selector("input[name='AMOUNT'][value='37500']")
          page.should have_selector("input[name='CURRENCY'][value='GBP']")
          page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
          page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-legalisation-drop-off/done']")

          page.should have_button("Pay")
        end
      end
    end
  end

  it "renders a 404 error on for an invalid transaction slug" do
    visit "/pay-for-bunting/start"

    page.status_code.should == 404
  end

end
