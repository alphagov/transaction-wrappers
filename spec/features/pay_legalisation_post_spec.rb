# encoding: utf-8
require 'spec_helper'

describe "paying to get a document legalised by post" do
  it "renders the content and form" do
    visit "/pay-legalisation-post/start"

    within(:css, "header.page-header") do
      page.should have_content("Pay to legalise documents by post")
    end

    within(:css, "form") do
      page.should have_content("How many documents do you want legalised?")

      page.should have_content("Each document costs £30.")
      page.should have_field("transaction_document_count")

      page.should have_content("How would you like your documents sent back to you?")
      page.should have_unchecked_field("Prepaid envelope that you provide (UK only) - £0")
      page.should have_unchecked_field("Tracked courier service to the UK or British Forces Post Office including Isle of Man and Channel Islands - £4.50")
      page.should have_unchecked_field("Tracked courier service to Europe (excluding Albania, Armenia, Azerbaijan, Belarus, Bosnia & Herzegovina, Georgia, Liechtenstein, Kazakhstan, Macedonia, Moldova, Montenegro, Russia, Serbia, Turkey, Ukraine) - £12.50")
      page.should have_unchecked_field("Tracked courier service to the rest of the world - £22")

      page.should have_button("Calculate total")
    end
  end

  context "given correct data" do
    before do
      visit "/pay-legalisation-post/start"

      within(:css, "form") do
        fill_in "transaction_document_count", :with => "1"
        choose "Tracked courier service to the rest of the world - £22"
      end

      click_on "Calculate total"
    end

    it "calculates a total" do
      page.should have_content("It costs £52 for 1 document plus Tracked courier service to the rest of the world postage")
    end

    it "generates an EPDQ form" do
      page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

      within(:css, "form.epdq-submit") do
        page.should have_selector("input[name='ORDERID']")
        page.should have_selector("input[name='PSPID']")
        page.should have_selector("input[name='SHASIGN']")

        page.should have_selector("input[name='AMOUNT'][value='5200']")
        page.should have_selector("input[name='CURRENCY'][value='GBP']")
        page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
        page.should have_selector("input[name='ACCEPTURL'][value='http://www.dev.gov.uk/pay-legalisation-post/done']")

        page.should have_button("Pay")
      end
    end
  end

  it "should allow selecting zero documents" do
    # Necessary when people haven't paid for the correct postage the first time round

    visit "/pay-legalisation-post/start"

    within(:css, "form") do
      fill_in "transaction_document_count", :with => "0"
      choose "Tracked courier service to the UK or British Forces Post Office including Isle of Man and Channel Islands - £4.50"
    end

    click_on "Calculate total"

    page.should have_content("It costs £4.5 for 0 documents plus Tracked courier service to the UK or British Forces Post Office including Isle of Man and Channel Islands")
  end

  it "displays an error and renders the form given incorrect data" do
    visit "/pay-legalisation-post/start"

    within(:css, "form") do
      fill_in "transaction_document_count", :with => "3"
    end

    click_on "Calculate total"

    page.should have_selector("p.error-message", :text => "Please choose a postage option")
    page.should have_content("How would you like your documents sent back to you?")
  end

  it "returns an error if document count is not an integer" do
    visit "/pay-legalisation-drop-off/start"

    fill_in "transaction_document_count", :with => "definitely not a number"
    click_on "Calculate total"

    page.should have_selector("p.error-message", :text => "Document count must be a number")
    page.should_not have_button "Pay"
  end
end
