module ApplicationHelper
  def format_phone_number(phone)
    return if phone.blank?

    cleaned_phone = phone.gsub(/\D/, "")

    if cleaned_phone.length == 9
      "+375 (#{cleaned_phone[0..1]}) #{cleaned_phone[2..4]}-#{cleaned_phone[5..6]}-#{cleaned_phone[7..8]}"
    elsif cleaned_phone.length == 12 && cleaned_phone.start_with?("375")
      "+#{cleaned_phone[0..2]} (#{cleaned_phone[3..4]}) #{cleaned_phone[5..7]}-#{cleaned_phone[8..9]}-#{cleaned_phone[10..11]}"
    else
      phone
    end
  end

  def format_time(seconds)
    return if seconds.nil?
    minutes = seconds / 60
    seconds = seconds % 60
    "#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end

  def number_to_currency(amount, options = {})
    unit = options[:unit] || "BYN"
    format = options[:format] || "%n %u"
    number = number_with_precision(amount, precision: 2)
    format.gsub("%n", number).gsub("%u", unit)
  end

  def number_with_precision(number, options = {})
    precision = options[:precision] || 0
    "%.#{precision}f" % number
  end

  def current_year
    Time.current.year
  end

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

  def email_change_confirmation_url(token)
    "http://localhost:3000/email/confirm/#{token}"
  end

  def current_cart
    @current_cart ||= Cart.for_user!(current_user) if current_user
  end

  def cart_items_count
    current_cart&.total_items_count || 0
  end

  def sort_link(column, title = nil)
    title ||= column.titleize
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
