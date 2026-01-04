# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  slug        :string           not null
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Category < ApplicationRecord
  # Связь с блюдами, принадлежащими этой категории
  has_many :dishes

  # Использование ActiveStorage для хранения одного файла (изображения категории)
  has_one_attached :photo

  # Валидация имени: обязательное поле и ограничение по длине
  validates :name, presence: true, length: { maximum: 255 }

  # Валидация slug: обязательное поле, уникальность критична для URL, ограничение длины
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }

  # Описание опционально, но имеет лимит длины
  validates :description, length: { maximum: 2000 }, allow_blank: true

  # Валидация прикрепленного файла: разрешены только картинки (png/jpeg), ограничение размера 5 МБ
  validates :photo,
    content_type: [ "image/png", "image/jpeg" ],
    size: { less_than: 5.megabytes }

  # Scope для получения только активных категорий (используется в публичной части сайта)
  scope :active, -> { where(active: true) }
end
