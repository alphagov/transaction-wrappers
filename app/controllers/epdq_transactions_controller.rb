class EpdqTransactionsController < ApplicationController

  before_filter :find_transaction

  def start

  end

  private
    def find_transaction
      @transaction_list ||= YAML.load( File.open( Rails.root.join("lib", "epdq_transactions.yml") ) )
      @transaction = @transaction_list[params[:slug]]

      unless @transaction.present?
        error_404
        return
      end

      @transaction.symbolize_keys!
      @transaction[:slug] = params[:slug]
    end

end
