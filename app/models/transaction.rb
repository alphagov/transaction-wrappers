class Transaction
  attr_reader :title, :slug, :document_cost, :postage_cost, :registration_cost, :registration_type, :document_types, :registration
  cattr_writer :file_path, :transaction_list


  def initialize(atts)
    @title = atts['title']
    @slug = atts['slug']
    @document_cost = atts['document_cost']
    @postage_cost = atts['postage_cost']
    @registration_cost = atts['registration_cost']
    @registration_type = atts['registration_type']
    @document_types = atts['document_types']
    @registration = atts['registration']
  end
  class TransactionNotFound < StandardError; end
  class InvalidDocumentType < StandardError; end

  def calculate_total(values)
    calculator = TransactionCalculator.new(self)
    calculator.calculate(values)
  end

  def self.find(id)
    if transaction = self.transaction_list[id]
      Transaction.new(transaction.merge('slug' => id))
    else
      raise TransactionNotFound
    end
  end

  def self.file_path
    @@file_path || Rails.root.join("lib/transactions.yml")
  end

  def self.transaction_list
    @@transaction_list ||= self.load_transaction_list
  end

  private

  def self.load_transaction_list
    YAML.load( File.open( self.file_path ) )
  end
end
