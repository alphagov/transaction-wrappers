#coding: utf-8
require "spec_helper"

feature "epdq transactions" do
  it "renders a 404 error on for an invalid transaction slug" do
    visit "/pay-for-bunting/start"

    page.status_code.should == 404
  end

  it "redirects GET requests to the /confirm page to the /start page" do
    visit "/pay-legalisation-post/confirm"
    page.should have_selector "h1", text: "Pay to legalise documents by post"
  end
end
