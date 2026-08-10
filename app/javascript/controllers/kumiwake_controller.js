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

    this.showMessage(`ふむふむ　全部で${count}名じゃな`)

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

        this.showMessage("ええと……名簿は……")

        break


      // --------------------------------
      // 名簿についてのセリフ
      // --------------------------------

      case "initial-2":

        this.currentStep = "initial-menu"

        this.showMenu()

        break


      // --------------------------------
      // 組数確認後のセリフ
      // 今後ここに追加していく
      // --------------------------------

      case "group-count":

        this.currentStep = "group-count-next"

        this.showMessage("そうじゃった　そうじゃった……")

        break


      case "group-count-next":
        this.currentStep = "group-count-number"
        this.showMessage(`${this.selectedGroupCount}組じゃったわ`)
        break


      case "group-count-number":

        this.currentStep = "group-name-question"

        this.showMessage("それぞれ組には　名　があるんじゃが…")

        // 1秒後に選択肢
        this.showMenuAfterDelay(() => {
          this.showGroupNameMenu()
        })

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
      "はて？　いくつに分けるんじゃったかな？"
    )

    // 1秒後に組数選択
    this.showMenuAfterDelay(() => {
      this.showGroupCountMenu()
    })
  }


  // ========================================
  // 「いいえ」
  // ========================================

  confirmNo() {

    window.location.href = "/kumiwake/input"

  }


  // ========================================
  // 組数選択
  // ========================================

  showGroupCountMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#selectGroupCount"
        data-group-count="2">

        <span class="cursor">▶</span>
        2

      </button>


      <button
        class="menu-item"
        data-action="click->kumiwake#selectGroupCount"
        data-group-count="3">

        <span class="cursor">▶</span>
        3

      </button>


      <button
        class="menu-item"
        data-action="click->kumiwake#selectGroupCount"
        data-group-count="4">

        <span class="cursor">▶</span>
        4

      </button>


      <button
        class="menu-item"
        data-action="click->kumiwake#selectMoreGroups">

        <span class="cursor">▶</span>
        それ以上

      </button>

    `
  }


  // ========================================
  // 2・3・4を選択
  // ========================================

  selectGroupCount(event) {

    const groupCount =
      Number(event.currentTarget.dataset.groupCount)

    // 今は確認用
    console.log(`組数: ${groupCount}`)

    this.selectedGroupCount = groupCount

    this.currentStep = "group-count"

    this.showMessage("そうじゃった　そうじゃった……")

  }


  // ========================================
  // 「それ以上」
  // ========================================

  selectMoreGroups() {

    console.log("それ以上を選択")

    // ここに数字入力画面への処理を追加する
  }


  // ========================================
  // 組名についての選択肢
  // ========================================

  showGroupNameMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#defaultGroupNames">

        <span class="cursor">▶</span>
        知ってるからいい

      </button>


      <button
        class="menu-item"
        data-action="click->kumiwake#askGroupNames">

        <span class="cursor">▶</span>
        きく

      </button>

    `
  }


  // ========================================
  // デフォルトの組名
  // ========================================

  defaultGroupNames() {

    console.log("アルファベットで組名を設定")

    // 今後ここに
    // A / B / C ...
    // を設定する処理を追加

  }


  // ========================================
  // 組名を「きく」
  // ========================================

  askGroupNames() {

    console.log("組名入力画面へ")

    // 今後ここに組名入力画面への処理を追加

  }

}