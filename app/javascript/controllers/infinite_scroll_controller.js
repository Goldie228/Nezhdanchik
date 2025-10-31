
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
    })
    this.observer.observe(this.triggerTarget)
  }

  disconnect() {
    this.observer.disconnect()
  }

  loadMore() {
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
        } else {
          this.triggerTarget.innerHTML = `
            <div class="text-center py-4 text-base-content">
              Вы просмотрели все блюда
            </div>
          `
          this.observer.disconnect()
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
}
