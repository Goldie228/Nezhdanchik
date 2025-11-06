class PagesController < ApplicationController
  def home
  end

  def privacy_policy
    @last_updated = "15 ноября 2024 года"
  end

  def terms_of_use
    @last_updated = "15 ноября 2024 года"
  end
end
