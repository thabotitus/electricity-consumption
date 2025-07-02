class TopUp < ApplicationRecord
  monetize :amount_cents
end
