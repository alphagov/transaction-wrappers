require 'spec_helper'

describe Transaction do

  before do
    Transaction.file_path = Rails.root.join("spec/fixtures/transactions.yml")
  end

  describe "loads and memoizes the list of transactions" do
    it "loads the list of transactions" do
      Transaction.transaction_list.should == {
        "pay-for-gorilla-hire" => {
          "title" => "Pay for gorilla hire",
          "document_cost" => 120,
          "registration" => false
        }
      }
    end

    it "does not load the list of transactions more than once" do
      File.should_receive(:open).with(Transaction.file_path).once.and_return( File.open(Transaction.file_path) )

      Transaction.transaction_list
      Transaction.transaction_list
    end
  end

end
