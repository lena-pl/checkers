class Player < ActiveRecord::Base
  belongs_to :game
  has_many :steps, dependent: :destroy

  enum colour: [:red, :white]

  validates :game, presence: true
end
