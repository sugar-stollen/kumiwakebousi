import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.count = this.listTarget.children.length
  }

  add() {
    this.count += 1

    const row = document.createElement("div")

    row.className = "name-input-row"

    row.innerHTML = `
      <span>${this.count}.</span>
      <input
        type="text"
        name="names[]"
        placeholder="名前を入力"
      >
    `

    this.listTarget.appendChild(row)
  }
}