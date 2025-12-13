import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger"]
  static values = { 
    url: String,
    loadedCategories: String,
    categoryOffsets: String,
    currentCategoryId: Number
  }
  
  loading = false

  connect() {
    this.observer = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting && !this.loading) {
        this.loadMore()
      }
    }, {
      rootMargin: "200px",
      threshold: 0.1
    })
    
    this.observer.observe(this.triggerTarget)
    
    this.setupFooterObserver()
    
    this.handleInitialNavigation()
  }

  disconnect() {
    this.observer.disconnect()
    if (this.footerObserver) {
      this.footerObserver.disconnect()
    }
  }

  setupFooterObserver() {
    const footer = document.querySelector('footer')
    if (!footer) return
    
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
    const hash = window.location.hash.substring(1)
    if (hash && !isNaN(hash)) {
      const categoryId = parseInt(hash)
      this.navigateToCategoryById(categoryId)
    }
  }

  loadMore() {
    if (!this.observer) return
    
    this.loading = true
    this.triggerTarget.innerHTML = `
      <div class="flex justify-center py-4">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
    `
    
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set('current_category_id', this.currentCategoryIdValue)
    url.searchParams.set('loaded_categories', this.loadedCategoriesValue)
    url.searchParams.set('category_offsets', this.categoryOffsetsValue)
    
    fetch(url, {
      headers: { "Accept": "text/html" }
    })
      .then(r => r.text())
      .then(html => {
        if (html.trim() !== "") {
          this.triggerTarget.insertAdjacentHTML("beforebegin", html)

          const stateUpdater = this.triggerTarget.previousElementSibling;

          if (stateUpdater && stateUpdater.classList.contains('state-updater')) {
            this.loadedCategoriesValue = stateUpdater.dataset.loadedCategories;
            this.categoryOffsetsValue = stateUpdater.dataset.categoryOffsets;
            this.currentCategoryIdValue = parseInt(stateUpdater.dataset.currentCategoryId);
          }

          this.triggerTarget.innerHTML = '';
          
          this.checkForPendingNavigation()
        } else {
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
        this.triggerTarget.innerHTML = `
          <div class="text-center py-4 text-error">
            Ошибка загрузки. <button class="btn btn-xs btn-ghost" data-action="click->infinite-scroll#loadMore">Попробовать снова</button>
          </div>
        `
        this.loading = false
      })
  }

  checkForPendingNavigation() {
    if (this.pendingNavigation) {
      const { categoryId, callback } = this.pendingNavigation
      
      const loadedCategories = this.loadedCategoriesValue.split(',').map(id => parseInt(id))
      
      if (loadedCategories.includes(categoryId)) {
        this.scrollToCategory(categoryId)
        this.pendingNavigation = null
        if (callback) callback()
      } else {
        this.loadMore()
      }
    }
  }

  scrollToCategory(categoryId) {
    const categoryElement = document.querySelector(`[data-category-id="${categoryId}"]`)
    if (categoryElement) {
      categoryElement.scrollIntoView({ behavior: 'smooth', block: 'start' })
      
      document.querySelectorAll('.category-tab').forEach(tab => {
        tab.classList.remove('bg-primary', 'text-primary-content')
        if (tab.dataset.categoryId == categoryId) {
          tab.classList.add('bg-primary', 'text-primary-content')
          
          const mobileCategoryName = document.getElementById('current-category-name')
          if (mobileCategoryName) {
            mobileCategoryName.textContent = tab.textContent.trim()
          }
        }
      })
    }
  }

  navigateToCategoryById(categoryId, callback) {
    const loadedCategories = this.loadedCategoriesValue.split(',').map(id => parseInt(id))
    
    if (loadedCategories.includes(categoryId)) {
      this.scrollToCategory(categoryId)
      if (callback) callback()
    } else {
      this.pendingNavigation = { categoryId, callback }
      this.loadMore()
    }
  }
}
