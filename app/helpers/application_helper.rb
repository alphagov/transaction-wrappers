module ApplicationHelper

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
