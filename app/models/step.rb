class Step < ActiveRecord::Base
  SQUARE_RANGE = 1..32

  belongs_to :player

  enum kind: [:simple, :jump]

  validates :from, :to, inclusion: {in: SQUARE_RANGE}
  validates :kind, :player, presence: true
end
