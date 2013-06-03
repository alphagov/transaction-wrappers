module EpdqTransactionsHelper

  def epdq_params
    @epdq_response.parameters
  end

  def postage?
    epdq_params.has_key?(:postage) and epdq_params[:postage] == "yes"
  end

  def registrations_and_certificates
    [].tap do |ary|
      ary << pluralize(registration_count, 'registration') if registrations?
      ary << pluralize(document_count, 'certificate') if documents?
    end.join(" and ")
  end

  private

  def document_count
    epdq_params.has_key?(:document_count) ? epdq_params[:document_count].to_i : 0
  end

  def documents?
    document_count > 0
  end

  def registration_count
    epdq_params.has_key?(:registration_count) ? epdq_params[:registration_count].to_i : 0
  end

  def registrations?
    registration_count > 0
  end

end
