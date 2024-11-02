class Cliente < ApplicationRecord
    has_many :compras
    has_many :productos, through: :compras
end
