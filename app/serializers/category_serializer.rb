class CategorySerializer < ActiveModel::Serializer
  attributes :id, :slug, :title, :icon_key, :tint_hex, :icon_color_hex,
             :cover_url, :design_count, :position
end
