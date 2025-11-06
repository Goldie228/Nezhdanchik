class CartController < ApplicationController
  def show
    # Тестовые данные корзины
    @cart_items = [
      {
        id: 1,
        dish_id: 101,
        name: "Паста Карбонара",
        price: 25.00,
        quantity: 1,
        image: "pasta.jpg",
        modifications: {
          added: [ "Сыр Пармезан", "Чеснок" ],
          removed: [ "Бекон" ]
        },
        special_instructions: "Пожалуйста, сделать поострее"
      },
      {
        id: 2,
        dish_id: 102,
        name: "Салат Цезарь",
        price: 15.50,
        quantity: 2,
        image: "salad.jpg",
        modifications: {
          added: [ "Куриная грудка" ],
          removed: [ "Сухарики", "Сыр Пармезан" ]
        },
        special_instructions: "Заправку отдельно"
      },
      {
        id: 3,
        dish_id: 103,
        name: "Кока-Кола",
        price: 5.00,
        quantity: 1,
        image: "cola.jpg",
        modifications: {
          added: [],
          removed: []
        },
        special_instructions: nil
      }
    ]

    @total_price = @cart_items.sum { |item| item[:price] * item[:quantity] }
    @total_items = @cart_items.sum { |item| item[:quantity] }
  end

  def add
    # В реальном приложении здесь была бы логика добавления в корзину
    redirect_to cart_path, notice: "Товар добавлен в корзину"
  end

  def update
    # В реальном приложении здесь была бы логика обновления количества
    redirect_to cart_path, notice: "Корзина обновлена"
  end

  def remove
    # В реальном приложении здесь была бы логика удаления из корзины
    redirect_to cart_path, notice: "Товар удален из корзины"
  end

  def clear
    # В реальном приложении здесь была бы логика очистки корзины
    redirect_to cart_path, notice: "Корзина очищена"
  end
end
