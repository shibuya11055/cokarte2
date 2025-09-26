class PagesController < ApplicationController
  # LPや法務系は公開（未ログインでも閲覧可）
  skip_before_action :authenticate_user!, only: %i[home pricing terms privacy legal guide]

  def home; end
  def pricing; end
  def terms; end
  def privacy; end
  def legal; end
  def guide; end
end
