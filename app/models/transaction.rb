class Transaction
  cattr_writer :file_path, :transaction_list

  def self.file_path
    @@file_path || Rails.root.join("lib/transactions.yml")
  end

  def self.transaction_list
    @@transaction_list || self.load_transaction_list
  end

  private

  def self.load_transaction_list
    @@transaction_list = YAML.load( File.open( self.file_path ) )
  end
end
