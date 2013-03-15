require 'spec_helper'

describe TransactionCalculator do

  describe "given a transaction without document types or registration costs" do
    before do
      @transaction = OpenStruct.new(
        :document_cost => 20,
        :postage_cost => 5,
        :registration => false)
      @calculator = TransactionCalculator.new(@transaction)
    end

    it "calculates the cost for a single document" do
      @calculator.calculate(:document_count => 1).total_cost.should == 20
    end

    it "calculates the cost for multiple documents" do
      @calculator.calculate(:document_count => 3).total_cost.should == 60
    end

    it "calculates the cost with postage" do
      @calculator.calculate(:document_count => 3, :postage => "yes").total_cost.should == 65
    end

    it "builds an item list for a single document" do
      @calculator.calculate(:document_count => 1).item_list.should == "1 document"
    end

    it "builds an item list for multiple documents without postage" do
      @calculator.calculate(:document_count => 5, :postage => "no").item_list.should == "5 documents"
    end

    it "builds an item list with postage" do
      @calculator.calculate(:document_count => 5, :postage => "yes").item_list.should == "5 documents, plus postage,"
    end
  end

  describe "given a transaction with multiple document types" do
    before do
      @transaction = OpenStruct.new(
        :document_cost => 20,
        :postage_cost => 5,
        :registration => false,
        :document_types => {
          "certificate-of-biscuit-quality" => "Certificate of biscuit quality",
          "tea-assurance-document" => "Tea assurance document"
        })
      @calculator = TransactionCalculator.new(@transaction)
    end

    it "raises an exception if no document type specified" do
      expect{ @calculator.calculate(:document_count => 1) }.to raise_error(Transaction::InvalidDocumentType)
    end

    it "builds an item list for a single document" do
      @calculator.calculate(:document_count => 1, :document_type => "tea-assurance-document").item_list.should == "1 Tea assurance document"
    end

    it "builds an item list for multiple documents" do
      @calculator.calculate(:document_count => 2, :document_type => "tea-assurance-document").item_list.should == "2 Tea assurance documents"
    end

    it "builds an item list for multiple documents, plus postage" do
      @calculator.calculate(:document_count => 2, :document_type => "tea-assurance-document", :postage => "yes").item_list.should == "2 Tea assurance documents, plus postage,"
    end

    it "builds an item list for a single certificate" do
      @calculator.calculate(:document_count => 1, :document_type => "certificate-of-biscuit-quality").item_list.should == "1 Certificate of biscuit quality"
    end

    it "builds an item list for multiple certificates" do
      @calculator.calculate(:document_count => 2, :document_type => "certificate-of-biscuit-quality").item_list.should == "2 Certificates of biscuit quality"
    end
  end

  describe "given a transaction with registration costs" do
    before do
      @transaction = OpenStruct.new(
        :document_cost => 20,
        :postage_cost => 5,
        :registration => true,
        :registration_cost => 50,
        :registration_type => "tea")
      @calculator = TransactionCalculator.new(@transaction)
    end

    it "calculates the cost for a registration" do
      @calculator.calculate(:registration_count => 1).total_cost.should == 50
    end

    it "calculates the cost for multiple registrations" do
      @calculator.calculate(:registration_count => 5).total_cost.should == 250
    end

    it "calculates the costs of documents and registrations" do
      @calculator.calculate(:registration_count => 2, :document_count => 3).total_cost.should == 160
    end

    it "calculates the costs of documents and registrations, with postage" do
      @calculator.calculate(:registration_count => 2, :document_count => 3, :postage => "yes").total_cost.should == 165
    end

    it "builds an item list for a single registration" do
      @calculator.calculate(:registration_count => 1).item_list.should == "1 tea registration and 0 tea certificates"
    end

    it "builds an item list for multiple registrations and documents" do
      @calculator.calculate(:registration_count => 1, :document_count => 4).item_list.should == "1 tea registration and 4 tea certificates"
    end

    it "builds an item list for multiple registrations and documents, with postage" do
      @calculator.calculate(:registration_count => 1, :document_count => 4, :postage => "yes").item_list.should == "1 tea registration and 4 tea certificates, plus postage,"
    end
  end

end
