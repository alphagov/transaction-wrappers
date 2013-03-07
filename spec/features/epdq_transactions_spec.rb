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
        page.should have_content("How many documents do you require?")
        page.should have_content("Each document costs £65.")
        page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

        page.should have_content("Do you require postage? This costs £10.")
        page.should have_select("transaction_postage", :options => ["Yes", "No"])

        page.should have_button("Calculate total")
      end
    end

    it "calculates a total given correct data" do
      visit "/pay-for-certificates-for-marriage"

      within(:css, "form") do
        select "3", :from => "How many documents do you require?"
        select "Yes", :from => "Do you require postage?"
      end

      click_on "Calculate total"

      page.should have_content("£205")
    end
  end

  it "renders a 404 error on for an invalid transaction slug" do
    visit "/pay-for-bunting"

    page.status_code.should == 404
  end

end
