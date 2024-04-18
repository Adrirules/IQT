# app/models/response.rb
class Response < ApplicationRecord
  belongs_to :responder, polymorphic: true
  belongs_to :question
  belongs_to :option

end
