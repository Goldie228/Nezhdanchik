class OrdersController < ApplicationController
  def history
    # Тестовые данные заказов
    @orders = [
      {
        id: 1,
        order_number: "ORD-2024-001",
        date: "15 ноября 2024",
        status: "completed",
        status_text: "Выполнен",
        total: 45.50,
        items: [
          { name: "Паста Карбонара", quantity: 1, price: 25.00, image: "pasta.jpg" },
          { name: "Салат Цезарь", quantity: 1, price: 15.50, image: "salad.jpg" },
          { name: "Кока-Кола", quantity: 1, price: 5.00, image: "cola.jpg" }
        ],
        delivery_address: "ул. Примерная, д. 10, кв. 25",
        payment_method: "Картой онлайн"
      },
      {
        id: 2,
        order_number: "ORD-2024-002",
        date: "14 ноября 2024",
        status: "completed",
        status_text: "Выполнен",
        total: 32.75,
        items: [
          { name: "Пицца Маргарита", quantity: 1, price: 22.75, image: "pizza.jpg" },
          { name: "Лате", quantity: 2, price: 10.00, image: "latte.jpg" }
        ],
        delivery_address: "ул. Примерная, д. 10, кв. 25",
        payment_method: "Наличными"
      },
      {
        id: 3,
        order_number: "ORD-2024-003",
        date: "13 ноября 2024",
        status: "cancelled",
        status_text: "Отменен",
        total: 28.30,
        items: [
          { name: "Бургер Классический", quantity: 1, price: 18.30, image: "burger.jpg" },
          { name: "Картофель фри", quantity: 1, price: 7.00, image: "fries.jpg" },
          { name: "Апельсиновый сок", quantity: 1, price: 3.00, image: "juice.jpg" }
        ],
        delivery_address: "ул. Примерная, д. 10, кв. 25",
        payment_method: "Картой онлайн",
        cancellation_reason: "Изменение планов"
      },
      {
        id: 4,
        order_number: "ORD-2024-004",
        date: "12 ноября 2024",
        status: "completed",
        status_text: "Выполнен",
        total: 67.80,
        items: [
          { name: "Стейк Рибай", quantity: 1, price: 45.00, image: "steak.jpg" },
          { name: "Овощи гриль", quantity: 1, price: 12.80, image: "vegetables.jpg" },
          { name: "Красное вино", quantity: 1, price: 10.00, image: "wine.jpg" }
        ],
        delivery_address: "ул. Примерная, д. 10, кв. 25",
        payment_method: "Картой онлайн"
      },
      {
        id: 5,
        order_number: "ORD-2024-005",
        date: "10 ноября 2024",
        status: "completed",
        status_text: "Выполнен",
        total: 19.90,
        items: [
          { name: "Суп Том Ям", quantity: 1, price: 14.90, image: "soup.jpg" },
          { name: "Зеленый чай", quantity: 1, price: 5.00, image: "tea.jpg" }
        ],
        delivery_address: "ул. Примерная, д. 10, кв. 25",
        payment_method: "Наличными"
      }
    ]
  end
end
