module ApplicationHelper

  def format_money(value)
    case value.to_s
    when %r{\A[0-9]+\z} then value
    else
      "%0.2f" % value
    end
  end
end
