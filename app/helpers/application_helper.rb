
module ApplicationHelper
  # Возвращает текущую тему из куки или тему по умолчанию
  def current_site_theme
    cookies[:site_theme].presence || "coffee"
  end

  # Форматирует строку телефона в стандартный вид (+375 (XX) XXX-XX-XX).
  # Обрабатывает как короткие (9 цифр), так и полные (12 цифр) форматы.
  def format_phone_number(phone)
    return if phone.blank?

    # Удаляем все нечисловые символы (пробелы, скобки, дефисы)
    cleaned_phone = phone.gsub(/\D/, "")

    if cleaned_phone.length == 9
      # Формат для локального кода (без 375)
      "+375 (#{cleaned_phone[0..1]}) #{cleaned_phone[2..4]}-#{cleaned_phone[5..6]}-#{cleaned_phone[7..8]}"
    elsif cleaned_phone.length == 12 && cleaned_phone.start_with?("375")
      # Формат для полного международного номера
      "+#{cleaned_phone[0..2]} (#{cleaned_phone[3..4]}) #{cleaned_phone[5..7]}-#{cleaned_phone[8..9]}-#{cleaned_phone[10..11]}"
    else
      # Возвращаем оригинал, если формат не распознан
      phone
    end
  end

  # Преобразует секунды в формат времени MM:SS (например, для таймера приготовления)
  def format_time(seconds)
    return if seconds.nil?
    minutes = seconds / 60
    seconds = seconds % 60
    # rjust(2, '0') добавляет ведущий ноль (например, "05")
    "#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end

  # Кастомный форматтер валюты. Используется вместо встроенного number_to_currency
  # для точного контроля отображения (например, "10.00 BYN").
  def number_to_currency(amount, options = {})
    unit = options[:unit] || "BYN"
    format = options[:format] || "%n %u"
    number = number_with_precision(amount, precision: 2)
    format.gsub("%n", number).gsub("%u", unit)
  end

  # Округляет число до указанного количества знаков после запятой.
  def number_with_precision(number, options = {})
    precision = options[:precision] || 0
    "%.#{precision}f" % number
  end

  # Возвращает текущий год для копирайта в подвале сайта.
  def current_year
    Time.current.year
  end

  # Вспомогательный метод для согласования числительных с существительными в русском языке.
  # Пример: 1 блюдо, 2 блюда, 5 блюд.
  def russian_pluralize(number, one, few, many)
    last_digit = number % 10
    last_two_digits = number % 100

    if last_digit == 1 && last_two_digits != 11
      one
    elsif [ 2, 3, 4 ].include?(last_digit) && ![ 12, 13, 14 ].include?(last_two_digits)
      few
    else
      many
    end
  end

  # Генерирует URL для подтверждения смены email.
  # Важно: в production здесь должен использоваться реальный домен, а не localhost.
  def email_change_confirmation_url(token)
    "http://localhost:3000/email/confirm/#{token}"
  end

  # Возвращает корзину текущего пользователя (создает, если не существует).
  # Кэширование (@current_cart) предотвращает повторные запросы к БД в рамках одного рендеринга.
  def current_cart
    @current_cart ||= Cart.for_user!(current_user) if current_user
  end

  # Возвращает общее количество товаров в корзине для отображения в UI (бейдж на иконке).
  def cart_items_count
    current_cart&.total_items_count || 0
  end

  # Генерирует ссылку для сортировки списка с переключением направления (asc <-> desc).
  # Сохраняет текущие параметры фильтрации, меняя только sort и direction.
  def sort_link(column, title = nil)
    title ||= column.titleize
    # Переключаем направление при повторном клике на ту же колонку
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    icon = params[:sort] == column ? (direction == "asc" ? "▲" : "▼") : ""

    link_to manager_bookings_path(request.query_parameters.merge(sort: column, direction: direction, page: nil)), class: "flex items-center gap-1" do
      concat(title)
      if icon.present?
        content_tag(:span, icon, class: "text-xs")
      end
    end
  end
end
