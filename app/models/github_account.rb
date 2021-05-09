class GithubAccount < ApplicationRecord
  has_many :repositories, dependent: :destroy
  has_one :bill, dependent: :destroy
end
