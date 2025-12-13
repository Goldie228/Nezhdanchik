import { Controller } from "@hotwired/stimulus";


const COOKIE_NAME = "site_theme";
const COOKIE_DAYS = 365;

function setCookie(name, value, days) {
  const d = new Date();
  d.setTime(d.getTime() + days * 24 * 60 * 60 * 1000);
  document.cookie = `${name}=${encodeURIComponent(value)};path=/;expires=${d.toUTCString()};SameSite=Lax`;
}

function getCookie(name) {
  const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
  return match ? decodeURIComponent(match[2]) : null;
}

export default class extends Controller {
  static targets = ["button", "label", "list"];

  connect() {
    const cookieTheme = getCookie(COOKIE_NAME);
    const initial = cookieTheme || this.chooseInitialTheme();
    if (initial) this.applyTheme(initial);
  }

  chooseInitialTheme() {
    const prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
    if (prefersDark) {
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
    setCookie(COOKIE_NAME, key, COOKIE_DAYS);

    if (this.buttonTarget) this.buttonTarget.blur();
    if (this.listTarget) this.listTarget.blur();
  }

  applyTheme(themeKey) {
    if (!themeKey) return;
    document.documentElement.setAttribute("data-theme", themeKey);

    if (this.labelTarget) {
      const item = this.element.querySelector(`[data-theme-key="${themeKey}"]`);
      if (item) {
        const text = item.querySelector("span.flex-1");
        if (text) this.labelTarget.textContent = text.textContent.trim();
      } else {
        this.labelTarget.textContent = themeKey;
      }
    }

    this.element.querySelectorAll('[role="menuitemradio"]').forEach(a => {
      a.setAttribute("aria-checked", "false");
      const svg = a.querySelector(".check");
      if (svg) svg.style.opacity = "0";
    });

    const chosen = this.element.querySelector(`[data-theme-key="${themeKey}"]`);
    if (chosen) {
      chosen.setAttribute("aria-checked", "true");
      const svg = chosen.querySelector(".check");
      if (svg) svg.style.opacity = "1";
    }
  }
}
