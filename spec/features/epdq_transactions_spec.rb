#coding: utf-8
require "spec_helper"

feature "epdq transactions" do
  it "renders a 404 error on for an invalid transaction slug" do
    visit "/pay-for-bunting/start"

    page.status_code.should == 404
  end
end
