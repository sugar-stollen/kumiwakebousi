import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "menu"]

  connect() {
    this.menuTarget.innerHTML = ""

    const count = 
      this.messageTarget.dataset.namesCount

    const fromInput = 
      this.messageTarget.dataset.fromInput

    const fromGroupNameInput =
    this.messageTarget.dataset.fromGroupNameInput

     // 組名入力画面から戻ってきた場合
    if (fromGroupNameInput === "true") {
      this.startAfterGroupNames()
      return
    }

    // 名簿入力画面から戻ってきた場合
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

    this.showMessage(
      "では組み分けをはじめるぞ"
    )
  }


  // ========================================
  // 名簿入力から戻ってきた場合
  // ========================================

  startAfterInput(count) {
    this.currentStep = "confirm"

    this.showMessage(
      `ふむふむ　全部で${count}名じゃな`
    )

    this.showMenuAfterDelay(() => {
      this.showConfirmMenu()
    })
  }


  // ========================================
  // 組名入力から戻ってきた場合
  // ========================================

  startAfterGroupNames() {
    this.currentStep = "group-names-finished"

    this.showMessage(
      "ほほぅ　オヌシよく知っておるな"
    )
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

      case "group-question":

        this.goToGroupNames()

        break


      // ========================================
      // 組名入力後
      // ========================================

      case "group-names-finished":

        this.currentStep = "bousi-magic-1"

        this.showMessage(
          "では、いよいよ組み分けを始めるとするか・・・"
        )

        break


      case "bousi-magic-1":

        this.currentStep = "bousi-magic-2"

        this.showMessage(
          "っとその前に、大事なことを聞いておらんかったわい"
        )

        break


      case "bousi-magic-2":

        this.currentStep = "bousi-magic-3"

        this.showMessage(
          "ワシの魔法　クミワケ・カブルノｫボウシｨー　を使うかの？"
        )

        break


      case "bousi-magic-3":

        this.currentStep = "bousi-magic-4"

        this.showMessage(
          "この魔法はのぅ、過去に一度組み分けされた者同士が、なるべく違う組み合わせになる・・・という魔法じゃ！　すごいじゃろ？"
        )

        break


      case "bousi-magic-4":

        this.currentStep = "bousi-magic-5"

        this.showMessage(
          "ちなみに今回なら、だいたい○回くらいまでなら同じ組み合わせにならんようにできるぞい"
        )

        break


      case "bousi-magic-5":

        this.currentStep = "bousi-magic-6"

        this.showMessage(
          "ん？ なんで分かるのかじゃと？"
        )

        break


      case "bousi-magic-6":

        this.currentStep = "bousi-magic-7"

        this.showMessage(
          "な～に・・・ 簡単じゃよ・・・"
        )

        break


      case "bousi-magic-7":

        this.currentStep = "bousi-magic-8"

        this.showMessage(
          "勘　じゃ"
        )

        break


      case "bousi-magic-8":

        this.currentStep = "bousi-magic-question"

        this.showMessage(
          "さて、この魔法を使うかの？"
        )

        this.showMenuAfterDelay(() => {
          this.showBousiMagicMenu()
        })

        break


      // --------------------------------
      // 魔法を使う
      // --------------------------------

      case "bousi-magic-yes":

        this.currentStep = "bousi-magic-yes-2"

        this.showMessage(
          "よしきた！　では　魔法をかけるぞい"
        )

        break

      case "bousi-magic-yes-2":

        this.currentStep = "演出"

        this.showMessage(
        "クミワ～ケ・カブルノｫ～～ボウシｨ～～～"
          
        )

        break

      case "bousi-magic-no":

        this.currentStep = "演出"

        this.showMessage(
          "では、今回は　クミワケ・カブルノｫボウシｨー　は使わずに　組み分けを始めるぞい"
        )

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
    
    // 次のクリックで組名入力画面へ
  }


  // ========================================
  // 「いいえ」
  // ========================================

  confirmNo() {
    window.location.href = "/kumiwake/input"
  }


  // ========================================
  // 組名入力後の処理
  // ========================================

  showGroupNameMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#goToGroupNames">

        <span class="cursor">▶</span>
        組名を決める

      </button>

    `
  }


  // ========================================
  // 組名入力画面へ
  // ========================================

  goToGroupNames() {
    window.location.href = "/kumiwake/group_names"
  }


  // ========================================
  // ぼうし魔法
  // ========================================

  showBousiMagicMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#bousiMagicYes">

        <span class="cursor">▶</span>
        使う

      </button>


      <button
        class="menu-item"
        data-action="click->kumiwake#bousiMagicNo">

        <span class="cursor">▶</span>
        使わない

      </button>

    `
  }


  // ========================================
  // 「使う」
  // ========================================

  bousiMagicYes() {

    this.bousiMagic = true

    this.currentStep = "bousi-magic-yes"

    this.showMessage(
      "よしきた！　では　魔法をかけるぞい"
    )
  }


  // ========================================
  // 「使わない」
  // ========================================

  bousiMagicNo() {

    this.bousiMagic = false

    this.currentStep = "bousi-magic-no"

    this.showMessage(
      "では、今回は　クミワケ・カブルノｫボウシｨー　は使わずに　組み分けを始めるぞい"
    )
  }
}