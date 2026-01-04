
import { Controller } from "@hotwired/stimulus";


const COOKIE_NAME = "site_theme";
const COOKIE_DAYS = 365;

// Вспомогательная функция для установки куки с длительным сроком хранения
function setCookie(name, value, days) {
  const d = new Date();
  d.setTime(d.getTime() + days * 24 * 60 * 60 * 1000);
  // Кодирование значения необходимо для корректной работы спецсимволов
  document.cookie = `${name}=${encodeURIComponent(value)};path=/;expires=${d.toUTCString()};SameSite=Lax`;
}

// Вспомогательная функция для получения значения куки по имени
function getCookie(name) {
  const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
  return match ? decodeURIComponent(match[2]) : null;
}

export default class extends Controller {
  static targets = ["button", "label", "list"];

  connect() {
    // Приоритет отдается сохраненной теме в куках, иначе определяем системные предпочтения
    const cookieTheme = getCookie(COOKIE_NAME);
    const initial = cookieTheme || this.chooseInitialTheme();
    if (initial) this.applyTheme(initial);
  }

  chooseInitialTheme() {
    // Проверяем системные настройки пользователя (Dark Mode)
    const prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
    if (prefersDark) {
      // Возвращаем первый элемент как тему для темной схемы (предполагается, что первый элемент — темная тема)
      const first = this.element.querySelector('[data-theme-key]');
      return first ? first.getAttribute("data-theme-key") : null;
    }
    const first = this.element.querySelector('[data-theme-key]');
    return first ? first.getAttribute("data-theme-key") : null;
  }

  select(event) {
    event.preventDefault();
    const el = event.currentTarget;
    const key = el.getAttribute("data-theme-key");
    if (!key) return;
    
    this.applyTheme(key);
    // Сохраняем выбор пользователя в куках на год
    setCookie(COOKIE_NAME, key, COOKIE_DAYS);

    // Убираем фокус с кнопок для улучшения UX (убирает обводку после клика)
    if (this.buttonTarget) this.buttonTarget.blur();
    if (this.listTarget) this.listTarget.blur();
  }

  applyTheme(themeKey) {
    if (!themeKey) return;
    
    // Устанавливаем атрибут на html тег, который перехватывает DaisyUI/Tailwind
    document.documentElement.setAttribute("data-theme", themeKey);

    // Обновляем текст кнопки (label) в зависимости от выбранной темы
    if (this.labelTarget) {
      const item = this.element.querySelector(`[data-theme-key="${themeKey}"]`);
      if (item) {
        const text = item.querySelector("span.flex-1");
        if (text) this.labelTarget.textContent = text.textContent.trim();
      } else {
        this.labelTarget.textContent = themeKey;
      }
    }

    // Обновляем визуальное состояние меню (radio button behavior)
    this.element.querySelectorAll('[role="menuitemradio"]').forEach(a => {
      a.setAttribute("aria-checked", "false");
      const svg = a.querySelector(".check");
      if (svg) svg.style.opacity = "0";
    });

    // Подсвечиваем выбранную тему (показываем галочку)
    const chosen = this.element.querySelector(`[data-theme-key="${themeKey}"]`);
    if (chosen) {
      chosen.setAttribute("aria-checked", "true");
      const svg = chosen.querySelector(".check");
      if (svg) svg.style.opacity = "1";
    }
  }
}
