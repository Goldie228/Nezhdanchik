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
end
