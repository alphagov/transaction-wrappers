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
  end

  it "renders a 404 error on for an invalid transaction slug" do
    visit "/pay-for-bunting"

    page.status_code.should == 404
  end

end
