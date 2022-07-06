class Award < ApplicationRecord
  belongs_to :filing
  belongs_to :receiver, class_name: "Organization"
end
