class Compra < ApplicationRecord
    belongs_to :cliente
    belongs_to :producto
end
