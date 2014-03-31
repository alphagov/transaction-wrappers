module ApplicationHelper

  def format_money(value)
    case value.to_s
    when %r{\A[0-9]+\z} then value
    else
      number_to_currency(value, :precision => 2, :unit => nil)
    end
  end
end
