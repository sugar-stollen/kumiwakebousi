import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "menu"]

  connect() {
    this.menuTarget.innerHTML = ""

    const count = this.messageTarget.dataset.namesCount
    const fromInput = this.messageTarget.dataset.fromInput

    if (fromInput === "true") {
      this.startAfterInput(Number(count))
      return
    }

    // 初めてHOMEを開いた場合
    this.startInitial()
  }


  // ========================================
  // 最初の会話
  // ========================================

  startInitial() {
    this.currentStep = "initial-1"

    this.showMessage("では組み分けをはじめるぞ")
  }


  // ========================================
  // 名簿入力から戻ってきた場合
  // ========================================

  startAfterInput(count) {
    this.currentStep = "confirm"

    this.showMessage(
      `ふむふむ　全部で${count}名じゃな`
    )

    // 1秒後に「はい / いいえ」
    this.showMenuAfterDelay(() => {
      this.showConfirmMenu()
    })
  }


  // ========================================
  // セリフをクリックして次へ
  // ========================================

  nextMessage() {

    // 選択肢が表示されているときは
    // セリフクリックでは進めない
    if (this.menuTarget.innerHTML !== "") {
      return
    }


    switch (this.currentStep) {

      // --------------------------------
      // 最初のセリフ
      // --------------------------------

      case "initial-1":

        this.currentStep = "initial-2"

        this.showMessage(
          "ええと……名簿は……"
        )

        break


      // --------------------------------
      // 名簿についてのセリフ
      // --------------------------------

      case "initial-2":

        this.currentStep = "initial-menu"

        this.showMenu()

        break


      // --------------------------------
      // 組名と組数を確認
      // --------------------------------

      case "group-question":

        window.location.href = "/kumiwake/group_names"

        break
    }
  }


  // ========================================
  // セリフ表示
  // ========================================

  showMessage(text) {
    this.messageTarget.textContent = text

    // セリフを表示したら選択肢を消す
    this.menuTarget.innerHTML = ""
  }


  // ========================================
  // 1秒後に選択肢を表示
  // ========================================

  showMenuAfterDelay(callback) {

    setTimeout(() => {
      callback()
    }, 1000)
  }


  // ========================================
  // 最初の選択肢
  // ========================================

  showMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#goToInput">

        <span class="cursor">▶</span>
        入力する

      </button>


      <button
        class="menu-item">

        <span class="cursor">▶</span>
        CSVからインポート（未実装）

      </button>

    `
  }


  // ========================================
  // 人数確認
  // ========================================

  showConfirmMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#confirmYes">

        <span class="cursor">▶</span>
        はい

      </button>


      <button
        class="menu-item"
        data-action="click->kumiwake#confirmNo">

        <span class="cursor">▶</span>
        いいえ

      </button>

    `
  }


  // ========================================
  // 「入力する」
  // ========================================

  goToInput() {
    window.location.href = "/kumiwake/input"
  }


  // ========================================
  // 「はい」
  // ========================================

  confirmYes() {

    this.currentStep = "group-question"

    this.showMessage(
      "ところでオヌシは組の名前と数は知っておるかの？"
    )

  }


  // ========================================
  // 「いいえ」
  // ========================================

  confirmNo() {

    window.location.href = "/kumiwake/input"

  }


  // ========================================
  // 組名入力画面へ
  // ========================================

  goToGroupNames() {

    window.location.href = "/kumiwake/group_names"

  }

}