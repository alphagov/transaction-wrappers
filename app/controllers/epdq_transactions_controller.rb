class EpdqTransactionsController < ApplicationController

  before_filter :find_transaction, :except => :index
  rescue_from Transaction::TransactionNotFound, :with => :error_404

  class InvalidDocumentType < Exception; end

  def index
  end

  def start

  end

  def confirm
    @calculation = calculate_total(@transaction, params[:transaction])
    @epdq_request = build_epdq_request(@transaction, @calculation.total_cost)
  rescue InvalidDocumentType
    @errors = [:document_type]
    render :action => "start"
  end

  def done
    @epdq_response = EPDQ::Response.new(request.query_string)

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

  def calculate_total(transaction, values)
    document_count = values[:document_count].to_i
    postage = values[:postage] == "yes"
    document_type = values[:document_type]

    item_list = []

    document_total = transaction.document_cost * document_count
    postage_total = postage ? transaction.postage_cost : 0
    total_cost = document_total + postage_total

    if transaction.registration
      registration_count = values[:registration_count].to_i
      registration_total = transaction.registration_cost * registration_count
      total_cost += registration_total

      item_list << "#{registration_count} " + pluralize_document_type_label(registration_count, "#{transaction.registration_type} registration") + " and "
      document_type_label = "#{transaction.registration_type} certificate"
    end

    if transaction.document_types.present?
      if document_type.present?
        document_type_label = transaction.document_types[document_type]
      end
      raise InvalidDocumentType unless document_type_label
    end

    item_list << "#{document_count} " + pluralize_document_type_label(document_count, document_type_label || "document")
    item_list << ", plus postage," if postage

    return OpenStruct.new(:total_cost => total_cost, :item_list => item_list.join(''))
  end

  def build_epdq_request(transaction, total_cost_in_gbp)
    @epdq_request = EPDQ::Request.new(
      :orderid => SecureRandom.hex(15),
      :amount => (total_cost_in_gbp * 100).round,
      :currency => "GBP",
      :language => "en_GB",
      :accepturl => root_url + "#{transaction.slug}/done"
    )
  end

end
