# encoding: utf-8
require 'spec_helper'

describe "paying to register a birth abroad" do
  it "renders the content and form" do
    visit "/pay-register-birth-abroad/start"

    within(:css, "header.page-header") do
      page.should have_content("Payment to register a birth abroad")
    end

    within(:css, "form") do
      page.should have_content("Pay the Foreign & Commonwealth Office (FCO) to register the birth of a British national abroad. You must be back in the UK to use this service.")
      page.should have_content("How many registrations do you need to pay for? Each one costs £105.")
      page.should have_select("transaction_registration_count", :options => ["1","2","3","4","5","6","7","8","9"])

      page.should have_content("How many birth certificates do you need?")
      page.should have_content("Each one costs £65.")
      page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

      page.should have_content("Do you require postage? This costs £10.")
      page.should have_select("transaction_postage", :options => ["Yes", "No"])

      page.should have_content("You must be back in the UK to use this service.")
      
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
