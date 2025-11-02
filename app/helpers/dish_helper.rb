module DishHelper
  def pretty_cooking_time(total_minutes)
    return "—" if total_minutes.nil?

    minutes = total_minutes.to_i
    return "менее 1 мин" if minutes.zero?

    hours = minutes / 60
    mins  = minutes % 60

    parts = []
    parts << "#{hours} ч" if hours.positive?
    parts << "#{mins} мин" if mins.positive?
    parts.join(" ")
  end

  def ingredients_count_badge(count)
    case count
    when 1..3 then "#{count}"
    when 4..6 then "#{count}"
    else "#{count}+"
    end
  end

  def pretty_cooking_time(minutes)
    if minutes >= 60
      hours = minutes / 60
      "#{hours.to_i} ч #{minutes % 60} мин"
    else
      "#{minutes} мин"
    end
  end

  def calculate_calories(nutrition)
    return 0 unless nutrition
    proteins = nutrition.proteins.to_f
    fats = nutrition.fats.to_f
    carbohydrates = nutrition.carbohydrates.to_f
    (proteins * 4) + (fats * 9) + (carbohydrates * 4)
  end

  def ingredients_count_badge(count)
    word = russian_pluralize(count, "ингредиент", "ингредиента", "ингредиентов")
    content_tag(:span, "#{count} #{word}", class: "badge badge-primary badge-md md:badge-lg")
  end

  private

  def russian_pluralize(number, one, few, many)
    return many if (11..14).include?(number % 100)

    case number % 10
    when 1 then one
    when 2..4 then few
    else many
    end
  end
end
