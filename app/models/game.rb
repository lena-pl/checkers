class Game < ActiveRecord::Base
  has_many :steps, through: :players, dependent: :destroy
  has_many :players, dependent: :destroy
end
