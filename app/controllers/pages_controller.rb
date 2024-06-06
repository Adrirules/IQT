class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :about, :contact, :mentions, :privacy, :terms]

  def home
  end

  def about
  end

  def contact
  end

  def mentions
  end

  def ptivacy
  end

  def terms
  end
end
