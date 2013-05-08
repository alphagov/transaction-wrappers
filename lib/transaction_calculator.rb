class TransactionCalculator
  attr_reader :item_list

  def initialize(transaction)
    @transaction = transaction
  end

  def calculate(values)
    document_count = values[:document_count].to_i

    raise Transaction::InvalidDocumentCount unless document_count > 0

    postage = values[:postage] == "yes"
    document_type = values[:document_type]
    postage_option = values[:postage_option]

    item_list = Hash.new("")
    document_total = @transaction.document_cost * document_count

    if @transaction.postage_options.present?
      if postage_option.present?
        postage_method = @transaction.postage_options[postage_option]
      end
      raise Transaction::InvalidPostageOption unless postage_method

      postage_total = postage_method['cost']
      item_list[:postage] = " plus #{postage_method['label']} postage"
    elsif postage
      postage_total = @transaction.postage_cost
      item_list[:postage] = " plus postage"
    end
    total_cost = document_total + (postage_total || 0)

    if @transaction.registration
      registration_count = values[:registration_count].to_i

      registration_total = @transaction.registration_cost * registration_count
      total_cost += registration_total

      item_list[:registration] = "#{registration_count} " + pluralize_document_type_label(registration_count, "#{@transaction.registration_type} registration") + " and "
      document_type_label = "#{@transaction.registration_type} certificate"
    end

    if @transaction.document_types.present?
      if document_type.present?
        document_type_label = @transaction.document_types[document_type]
      end
      raise Transaction::InvalidDocumentType unless document_type_label
    elsif @transaction.document_type.present?
      document_type_label = @transaction.document_type
    end
    item_list[:document] = "#{document_count} " + pluralize_document_type_label(document_count, document_type_label || "document")

    item_list_order = [:registration, :document, :postage]
    return OpenStruct.new(
      :total_cost => total_cost,
      :item_list => item_list_order.map {|key| item_list[key] }.join(""),
      :postage_option => postage_option,
      :postage_option_label => postage_method.nil? ? "" : postage_method['label'],
      :document_count => document_count,
      :postage => postage,
      :document_type => document_type,
      :registration_count => registration_count
    )
  end

  private

  def pluralize_document_type_label(quantity, label)
    return label if quantity == 1

    case label
    when /\Acertificate/i then label.sub(/\A([cC])ertificate/i, '\1ertificates')
    when "Nulla Osta" then "Nulla Ostas" # pluralize thinks this is already plural
    else
      label.pluralize(quantity)
    end
  end
end
