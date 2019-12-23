module V1
  module Entities
    class NormWithProduct < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :stock
      expose :sale
      expose :price do |instance, options|
        instance.price.to_f / 100
      end
      expose :product, using: V1::Entities:: Product
      expose :spec_attrs
      expose :spec_attr_names
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end