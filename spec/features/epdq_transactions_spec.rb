#coding: utf-8
require "spec_helper"

feature "epdq transactions" do

  describe "paying for a certificate for marriage" do
    it "renders the content and form" do
      visit "/pay-for-certificates-for-marriage"

      within(:css, "header.page-header") do
        page.should have_content("Pay for certificates for marriage")
      end

      within(:css, "article") do
        page.should have_content("How many documents do you require?")
        page.should have_content("Each document costs £65.")
      end
    end
  end

  it "renders a 404 error on for an invalid transaction slug" do
    visit "/pay-for-bunting"

    page.status_code.should == 404
  end

end
