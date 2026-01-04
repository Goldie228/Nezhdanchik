
module DishHelper
  # Форматирует время приготовления в читаемый вид (часы и минуты).
  # Использует "—" как заглушку, если время не указано.
  def pretty_cooking_time(total_minutes)
    return "—" if total_minutes.nil?

    minutes = total_minutes.to_i
    return "менее 1 мин" if minutes.zero?

    hours = minutes / 60
    mins  = minutes % 60

    parts = []
    # Добавляем часы только если они есть
    parts << "#{hours} ч" if hours.positive?
    parts << "#{mins} мин" if mins.positive?
    parts.join(" ")
  end

  # Обертка для счетчика ингредиентов с визуальным оформлением (Badge).
  # Использует вспомогательный метод russian_pluralize для согласования слов.
  def ingredients_count_badge(count)
    word = russian_pluralize(count, "ингредиент", "ингредиента", "ингредиентов")
    # Возвращает HTML-элемент с классами DaisyUI для стилизации
    content_tag(:span, "#{count} #{word}", class: "badge badge-primary badge-md md:badge-lg")
  end

  # Альтернативный метод форматирования времени (упрощенная логика).
  # (Примечание: В коде присутствует дублирование с first method, этот метод перезаписывает первый).
  def pretty_cooking_time(minutes)
    if minutes >= 60
      hours = minutes / 60
      "#{hours.to_i} ч #{minutes % 60} мин"
    else
      "#{minutes} мин"
    end
  end

  # Рассчитывает калорийность продукта по формуле: Б*4 + Ж*9 + У*4
  def calculate_calories(nutrition)
    return 0 unless nutrition

    proteins = nutrition.proteins.to_f
    fats = nutrition.fats.to_f
    carbohydrates = nutrition.carbohydrates.to_f

    (proteins * 4) + (fats * 9) + (carbohydrates * 4)
  end

  private

  # Вспомогательный метод для склонения русских слов (числительные + существительные).
  # Учитывает исключения для чисел от 11 до 14.
  def russian_pluralize(number, one, few, many)
    return many if (11..14).include?(number % 100)

    case number % 10
    when 1 then one
    when 2..4 then few
    else many
    end
  end
end
