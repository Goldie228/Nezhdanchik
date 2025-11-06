class ManagerController < ApplicationController
  def dashboard
    # Тестовые данные активных заказов
    @active_orders = [
      {
        id: 1,
        order_number: "ORD-2024-006",
        table_numbers: [ 5, 6 ],  # Теперь поддерживаем несколько столов
        customer_name: "Иванов Иван",
        status: "new",
        status_text: "Новый заказ",
        created_at: "15 ноября 2024, 12:30",
        comment: "Клиент отметил, что это праздничный ужин",  # Комментарий к заказу
        items: [
          {
            dish_name: "Паста Карбонара",
            base_price: 25.00,
            total_price: 29.50,
            quantity: 1,
            modifications: {
              added: [
                { name: "Сыр Пармезан", price: 2.00, image: "parmesan.jpg" },
                { name: "Чеснок", price: 1.50, image: "garlic.jpg" },
                { name: "Грибы", price: 1.00, image: "mushrooms.jpg" }
              ],
              removed: [
                { name: "Бекон", image: "bacon.jpg" },
                { name: "Сливки", image: "cream.jpg" }
              ]
            },
            special_instructions: "Пожалуйста, сделать поострее"
          },
          {
            dish_name: "Салат Цезарь",
            base_price: 15.50,
            total_price: 18.00,
            quantity: 1,
            modifications: {
              added: [
                { name: "Куриная грудка", price: 2.50, image: "chicken.jpg" }
              ],
              removed: [
                { name: "Сухарики", image: "croutons.jpg" },
                { name: "Сыр Пармезан", image: "parmesan.jpg" }
              ]
            },
            special_instructions: "Заправку отдельно"
          }
        ],
        total: 47.50,
        preparation_time: 20
      },
      {
        id: 2,
        order_number: "ORD-2024-007",
        table_number: 3,  # Оставляем поддержку одного стола для обратной совместимости
        customer_name: "Петрова Анна",
        status: "preparing",
        status_text: "Готовится",
        created_at: "15 ноября 2024, 12:25",
        comment: nil,  # Комментарий может быть пустым
        items: [
          {
            dish_name: "Пицца Маргарита",
            base_price: 22.75,
            total_price: 25.25,
            quantity: 1,
            modifications: {
              added: [
                { name: "Пепперони", price: 2.50, image: "pepperoni.jpg" }
              ],
              removed: [
                { name: "Базилик", image: "basil.jpg" }
              ]
            },
            special_instructions: "Хорошо пропечь"
          }
        ],
        total: 25.25,
        preparation_time: 15
      },
      {
        id: 3,
        order_number: "ORD-2024-008",
        table_numbers: [ 8, 9, 10 ],  # Пример с тремя столами
        customer_name: "Сидоров Алексей",
        status: "ready",
        status_text: "Готов к подаче",
        created_at: "15 ноября 2024, 12:15",
        comment: "Большая компания, просили принести счета раздельно",
        items: [
          {
            dish_name: "Бургер Классический",
            base_price: 18.30,
            total_price: 21.80,
            quantity: 2,
            modifications: {
              added: [
                { name: "Бекон", price: 1.50, image: "bacon.jpg" },
                { name: "Сыр Чеддер", price: 1.00, image: "cheddar.jpg" },
                { name: "Яйцо", price: 1.00, image: "egg.jpg" }
              ],
              removed: [
                { name: "Лук", image: "onion.jpg" },
                { name: "Майонез", image: "mayo.jpg" }
              ]
            },
            special_instructions: "Бургеры разделить на две порции"
          },
          {
            dish_name: "Картофель фри",
            base_price: 7.00,
            total_price: 9.00,
            quantity: 1,
            modifications: {
              added: [
                { name: "Сырный соус", price: 2.00, image: "cheese_sauce.jpg" }
              ],
              removed: []
            },
            special_instructions: nil
          }
        ],
        total: 52.60,
        preparation_time: 12
      }
    ]

    @statuses = [
      { value: "new", text: "Новый заказ", color: "badge-info" },
      { value: "preparing", text: "Готовится", color: "badge-warning" },
      { value: "ready", text: "Готов к подаче", color: "badge-success" },
      { value: "served", text: "Подано", color: "badge-neutral" }
    ]
  end

  def update_status
    # В реальном приложении здесь был бы код обновления статуса в БД
    render json: { success: true, message: "Статус обновлен" }
  end

  def save_comment
    # В реальном приложении здесь был бы код сохранения комментария в БД
    render json: { success: true, message: "Комментарий сохранен" }
  end
end
