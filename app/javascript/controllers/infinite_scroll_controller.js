
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger"] // Элемент-триггер (например, спиннер "загрузки") в конце списка
  static values = { 
    url: String,            // Эндпоинт для подгрузки данных
    loadedCategories: String, // ID уже загруженных категорий (через запятую)
    categoryOffsets: String, // Смещения (offsets) для пагинации внутри категорий
    currentCategoryId: Number // ID текущей активной категории
  }
  
  loading = false // Флаг для предотвращения множественных одновременных запросов

  connect() {
    // Используем IntersectionObserver для ленивой загрузки (когда элемент появляется в области видимости)
    this.observer = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting && !this.loading) {
        this.loadMore()
      }
    }, {
      rootMargin: "200px", // Начинаем загрузку за 200px до конца экрана
      threshold: 0.1      // Срабатывает, когда видно 10% элемента
    })
    
    this.observer.observe(this.triggerTarget)
    
    // Дополнительный наблюдатель для футера (дублирует логику на случай длинного списка)
    this.setupFooterObserver()
    
    // Обработка навигации при загрузке страницы (например, site.com/#123)
    this.handleInitialNavigation()
  }

  disconnect() {
    // Очистка ресурсов при удалении контроллера из DOM
    this.observer.disconnect()
    if (this.footerObserver) {
      this.footerObserver.disconnect()
    }
  }

  setupFooterObserver() {
    const footer = document.querySelector('footer')
    if (!footer) return
    
    // Активируем подгрузку также при достижении футера
    this.footerObserver = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting && !this.loading) {
        this.loadMore()
      }
    }, {
      threshold: 0.1
    })
    
    this.footerObserver.observe(footer)
  }

  handleInitialNavigation() {
    // Проверяем хэш URL для скролла к конкретной категории после перезагрузки
    const hash = window.location.hash.substring(1)
    if (hash && !isNaN(hash)) {
      const categoryId = parseInt(hash)
      this.navigateToCategoryById(categoryId)
    }
  }

  loadMore() {
    if (!this.observer) return
    
    this.loading = true
    // Показываем индикатор загрузки
    this.triggerTarget.innerHTML = `
      <div class="flex justify-center py-4">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
    `
    
    // Формируем URL с параметрами текущего состояния (чтобы продолжить с нужного места)
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set('current_category_id', this.currentCategoryIdValue)
    url.searchParams.set('loaded_categories', this.loadedCategoriesValue)
    url.searchParams.set('category_offsets', this.categoryOffsetsValue)
    
    fetch(url, {
      headers: { "Accept": "text/html" } // Ожидаем HTML фрагмент (Turbo Stream или partial)
    })
      .then(r => r.text())
      .then(html => {
        if (html.trim() !== "") {
          // Вставляем новый контент перед триггером
          this.triggerTarget.insertAdjacentHTML("beforebegin", html)

          // Обновляем состояние из специального скрытого элемента в ответе сервера
          const stateUpdater = this.triggerTarget.previousElementSibling;

          if (stateUpdater && stateUpdater.classList.contains('state-updater')) {
            this.loadedCategoriesValue = stateUpdater.dataset.loadedCategories;
            this.categoryOffsetsValue = stateUpdater.dataset.categoryOffsets;
            this.currentCategoryIdValue = parseInt(stateUpdater.dataset.currentCategoryId);
          }

          this.triggerTarget.innerHTML = '';
          
          // Проверяем, не нужно ли переместиться к категории, которая только что загрузилась
          this.checkForPendingNavigation()
        } else {
          // Контент закончился — отключаем скролл-обозреватели
          this.triggerTarget.innerHTML = `
            <div class="text-center py-4 text-base-content">
              Вы просмотрели все блюда
            </div>
          `
          this.observer.disconnect()
          if (this.footerObserver) {
            this.footerObserver.disconnect()
          }
        }
        this.loading = false
      })
      .catch(error => {
        console.error("Error loading more dishes:", error)
        // Отображение ошибки с кнопкой повтора
        this.triggerTarget.innerHTML = `
          <div class="text-center py-4 text-error">
            Ошибка загрузки. <button class="btn btn-xs btn-ghost" data-action="click->infinite-scroll#loadMore">Попробовать снова</button>
          </div>
        `
        this.loading = false
      })
  }

  checkForPendingNavigation() {
    // Если есть отложенный запрос на скролл (категория еще не была загружена)
    if (this.pendingNavigation) {
      const { categoryId, callback } = this.pendingNavigation
      
      const loadedCategories = this.loadedCategoriesValue.split(',').map(id => parseInt(id))
      
      if (loadedCategories.includes(categoryId)) {
        // Категория загрузилась — выполняем скролл
        this.scrollToCategory(categoryId)
        this.pendingNavigation = null
        if (callback) callback()
      } else {
        // Категории все еще нет — подгружаем следующую порцию
        this.loadMore()
      }
    }
  }

  scrollToCategory(categoryId) {
    // Плавный скролл к заголовку категории
    const categoryElement = document.querySelector(`[data-category-id="${categoryId}"]`)
    if (categoryElement) {
      categoryElement.scrollIntoView({ behavior: 'smooth', block: 'start' })
      
      // Обновляем визуальное состояние табов категорий (активный/неактивный)
      document.querySelectorAll('.category-tab').forEach(tab => {
        tab.classList.remove('bg-primary', 'text-primary-content')
        if (tab.dataset.categoryId == categoryId) {
          tab.classList.add('bg-primary', 'text-primary-content')
          
          // Обновляем название категории в мобильном меню
          const mobileCategoryName = document.getElementById('current-category-name')
          if (mobileCategoryName) {
            mobileCategoryName.textContent = tab.textContent.trim()
          }
        }
      })
    }
  }

  navigateToCategoryById(categoryId, callback) {
    // Логика навигации: скролл сразу, если есть, или подгрузка + ожидание
    const loadedCategories = this.loadedCategoriesValue.split(',').map(id => parseInt(id))
    
    if (loadedCategories.includes(categoryId)) {
      this.scrollToCategory(categoryId)
      if (callback) callback()
    } else {
      // Запоминаем запрос, чтобы выполнить его после загрузки данных в checkForPendingNavigation
      this.pendingNavigation = { categoryId, callback }
      this.loadMore()
    }
  }
}
