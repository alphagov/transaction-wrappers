class TransactionCalculator
  attr_reader :item_list

  def initialize(transaction)
    @transaction = transaction
  end

  def calculate(values)
    document_count = values[:document_count].to_i
    postage = values[:postage] == "yes"
    document_type = values[:document_type]

    item_list = []

    document_total = @transaction.document_cost * document_count
    postage_total = postage ? @transaction.postage_cost : 0
    total_cost = document_total + postage_total

    if @transaction.registration
      registration_count = values[:registration_count].to_i
      registration_total = @transaction.registration_cost * registration_count
      total_cost += registration_total

      item_list << "#{registration_count} " + pluralize_document_type_label(registration_count, "#{@transaction.registration_type} registration") + " and "
      document_type_label = "#{@transaction.registration_type} certificate"
    end

    if @transaction.document_types.present?
      if document_type.present?
        document_type_label = @transaction.document_types[document_type]
      end
      raise Transaction::InvalidDocumentType unless document_type_label
    end

    item_list << "#{document_count} " + pluralize_document_type_label(document_count, document_type_label || "document")
    item_list << ", plus postage," if postage

    return OpenStruct.new(:total_cost => total_cost, :item_list => item_list.join(''))
  end

  private

  def pluralize_document_type_label(quantity, label)
    return label if quantity == 1

    case label
    when /\Acertificate/i then label.sub(/\A([cC])ertificate/i, '\1ertificates')
    when "Nulla osta" then "Nulla ostas" # pluralize thinks this is already plural
    else
      label.pluralize(quantity)
    end
  end
end
