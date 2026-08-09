import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "menu"]

  connect() {
    // 最初は選択肢を隠す
    this.menuTarget.innerHTML = ""

    // 2秒後に最初のセリフ
    setTimeout(() => {
      this.showMessage("では組み分けをはじめるぞ")

      // さらに2秒後
      setTimeout(() => {
        this.showMessage("ええと……名簿は……")

        // さらに2秒後に選択肢を表示
        setTimeout(() => {
          this.showMenu()
        }, 2000)

      }, 2000)

    }, 2000)
  }

  showMessage(text) {
    this.messageTarget.textContent = text
  }

  showMenu() {
    this.menuTarget.innerHTML = `
      <button class="menu-item">
        <span class="cursor">▶</span>
        入力する
      </button>

      <button class="menu-item">
        <span class="cursor">▶</span>
        CSVからインポート（未実装）
      </button>
    `
  }
}
