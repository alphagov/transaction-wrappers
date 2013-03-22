class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  private

  def error_404; error 404; end

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def root_url
    if Rails.env.development?
      super
    else
      "#{Plek.current.find("www")}/"
    end
  end

  def set_expiry(duration = 30.minutes)
    unless Rails.env.development?
      expires_in(duration, :public => true)
    end
  end
end
