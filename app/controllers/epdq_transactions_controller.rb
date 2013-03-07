class EpdqTransactionsController < ApplicationController

  before_filter :find_transaction

  def start

  end

  def confirm
    @calculation = calculate_total(@transaction, params[:transaction])
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

    def calculate_total(transaction, values)
      document_count = values[:document_count].to_i
      postage = values[:postage] == "yes"

      document_total = @transaction[:document_cost] * document_count
      postage_total = postage ? @transaction[:postage_cost] : 0
      total_cost = document_total + postage_total

      item_list = "#{document_count} #{"document".pluralize(document_count)}"
      item_list << ", plus postage," if postage

      return OpenStruct.new(:total_cost => total_cost, :item_list => item_list)
    end

end
