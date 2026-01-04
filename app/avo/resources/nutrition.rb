
class Avo::Resources::Nutrition < Avo::BaseResource
  # Используем ID как заголовок, так как запись не имеет уникального читаемого имени
  self.title = :id

  def fields
    field :id, as: :id

    # Белки (основной строительный материал)
    field :proteins, as: :number, translation_key: "avo.field_translations.proteins"

    # Жиры (источник энергии)
    field :fats, as: :number, translation_key: "avo.field_translations.fats"

    # Углеводы (энергетический ресурс)
    field :carbohydrates, as: :number, translation_key: "avo.field_translations.carbohydrates"
  end
end
