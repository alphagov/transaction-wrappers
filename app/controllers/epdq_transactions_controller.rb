class EpdqTransactionsController < ApplicationController

  before_filter :find_transaction, :except => :index
  rescue_from Transaction::TransactionNotFound, :with => :error_404

  def index
  end

  def show
    redirect_to transaction_path(@transaction.slug)
  end

  def start
  end

  def confirm
    @calculation = @transaction.calculate_total(params[:transaction])
    @epdq_request = build_epdq_request(@transaction, @calculation.total_cost)
  rescue Transaction::InvalidDocumentType
    @errors = [:document_type]
    render :action => "start"
  rescue Transaction::InvalidPostageOption
    @errors = [:postage_option]
    render :action => "start"
  end

  def done
    @epdq_response = EPDQ::Response.new(request.query_string, @transaction.account)

    if @epdq_response.valid_shasign?
      render "done"
    else
      render "payment_error"
    end
  end

private
  def find_transaction
    @transaction = Transaction.find(params[:slug])
  end

  def build_epdq_request(transaction, total_cost_in_gbp)
    @epdq_request = EPDQ::Request.new(
      :account => transaction.account,
      :orderid => SecureRandom.hex(15),
      :amount => (total_cost_in_gbp * 100).round,
      :currency => "GBP",
      :language => "en_GB",
      :accepturl => root_url + "#{transaction.slug}/done"
    )
  end

end
