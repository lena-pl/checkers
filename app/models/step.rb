class Step < ActiveRecord::Base
  belongs_to :player

  enum kind: [:simple, :jump]

  validates :kind, :player, presence: true
end
