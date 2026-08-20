import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "menu", "csvFileInput"]

  connect() {
    this.menuTarget.innerHTML = ""

    const count =
      this.messageTarget.dataset.namesCount

    const fromInput =
      this.messageTarget.dataset.fromInput

    const fromGroupNameInput =
      this.messageTarget.dataset.fromGroupNameInput

    const limitReached =
      this.messageTarget.dataset.limitReached

    const magicMode =
      this.messageTarget.dataset.magicMode

    const magicMaxRounds =
      this.messageTarget.dataset.magicMaxRounds


    // ========================================
    // 魔法の上限に到達して戻ってきた
    // ========================================

    if (limitReached === "true") {
      this.startAfterLimit()
      return
    }


    // ========================================
    // 組名入力画面から戻ってきた
    // ========================================

    if (fromGroupNameInput === "true") {
      this.startAfterGroupNames()
      return
    }


    // ========================================
    // 名簿入力画面から戻ってきた
    // ========================================

    if (fromInput === "true") {
      this.startAfterInput(Number(count))
      return
    }


    // ========================================
    // 初めての組み分け
    // ========================================

    this.startInitial()
  }


  // ========================================
  // 結果画面へ
  // ========================================

  goToDraw() {
    this.submitDraw(this.bousiMagic === true)
  }


  // ========================================
  // 抽選POST
  // ========================================

  submitDraw(magicMode) {
    const form = document.createElement("form")

    form.method = "POST"
    form.action = "/kumiwake/draw"
    form.dataset.turbo = "false"

    const csrfToken = document.querySelector(
      'meta[name="csrf-token"]'
    ).content

    const csrfInput = document.createElement("input")

    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = csrfToken

    const modeInput = document.createElement("input")

    modeInput.type = "hidden"
    modeInput.name = "magic_mode"
    modeInput.value = magicMode ? "true" : "false"

    form.appendChild(csrfInput)
    form.appendChild(modeInput)

    document.body.appendChild(form)

    form.submit()
  }


  // ========================================
  // 最初の会話 リセット付き
  // ========================================

    startInitial() {
      this.resetHistory()

      this.currentStep = "initial-1"

      this.showMessage(
        "では組み分けをはじめるぞ"
      )
    }
// ========================================
// ２周目以降の組み分け開始時に履歴をリセット用
// ========================================

  resetHistory() {
    const form = document.createElement("form")

    form.method = "POST"
    form.action = "/kumiwake/reset_history"
    form.dataset.turbo = "false"

    const csrfToken = document.querySelector(
      'meta[name="csrf-token"]'
    ).content

    const csrfInput = document.createElement("input")

    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = csrfToken

    form.appendChild(csrfInput)

    document.body.appendChild(form)

    form.submit()
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
  // 魔法の上限到達後
  // ========================================

  startAfterLimit() {
    this.currentStep = "limit-1"

    this.showMessage(
      "おやおや？　すべての組み合わせが終わったようじゃぞ"
    )
  }


  // ========================================
  // セリフをクリック
  // ========================================

  nextMessage() {

    // 選択肢が表示されている場合は進めない
    if (this.menuTarget.innerHTML !== "") {
      return
    }

    switch (this.currentStep) {

      // ========================================
      // 最初
      // ========================================

      case "initial-1":

        this.currentStep = "initial-2"

        this.showMessage(
          "ええと……名簿は……"
        )

        break


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
          "ちなみに今回なら、だいたい" +
          this.messageTarget.dataset.magicMaxRounds +
          "回くらいまでなら同じ組み合わせにならんようにできるぞい"
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


      // ========================================
      // 魔法を使う
      // ========================================

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

        this.showMenuAfterDelay(() => {
          this.showDrawMenu()
        })

        break


      // ========================================
      // 魔法を使わない
      // ========================================

      case "bousi-magic-no":

        this.currentStep = "normal-draw"

        this.showMessage(
          "では、今回は　クミワケ・カブルノｫボウシｨー　は使わずに　組み分けを始めるぞい"
        )

        this.showMenuAfterDelay(() => {
          this.showNormalDrawMenu()
        })

        break


      // ========================================
      // 魔法上限到達後
      // ========================================

      case "limit-1":

        this.currentStep = "limit-2"

        this.showMessage(
          "ワシの魔法の効果はココまでのようじゃな"
        )

        break


      case "limit-2":

        this.currentStep = "limit-3"

        this.showMessage(
          "ここから先は魔法は使わずに通常の組み分けになるが・・・"
        )

        break


      case "limit-3":

        this.currentStep = "limit-4"

        this.showMessage(
          "まだ組み分けを続けるかの？"
        )

        this.showMenuAfterDelay(() => {
          this.showLimitMenu()
        })

        break
    }
  }


  // ========================================
  // セリフ表示
  // ========================================

  showMessage(text) {
    this.messageTarget.textContent = text
    this.menuTarget.innerHTML = ""
  }


  // ========================================
  // 1秒後に選択肢
  // ========================================

  showMenuAfterDelay(callback) {
    setTimeout(() => {
      callback()
    }, 1000)
  }


  // ========================================
  // 最初のメニュー
  // ========================================
  // ========================================
  // CSVインポート
  // ========================================

  importCsv() {
    this.csvFileInputTarget.click()
  }
  
  showMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#goToInput">

        <span class="cursor">▶</span>
        入力する

      </button>

        <button
          class="menu-item"
          data-action="click->kumiwake#importCsv">

          <span class="cursor">▶</span>
          CSVからインポート

        </button>

    `
  }

    // ========================================
    // CSVファイル選択
    // ========================================

    importCsvFile(event) {
      const file = event.target.files[0]

      if (!file) {
        return
      }

      const form = document.createElement("form")

      form.method = "POST"
      form.action = "/csv/import"
      form.enctype = "multipart/form-data"
      form.dataset.turbo = "false"

      const csrfToken = document.querySelector(
        'meta[name="csrf-token"]'
      ).content

      const csrfInput = document.createElement("input")

      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken

      event.target.name = "file"

      form.appendChild(csrfInput)
      form.appendChild(event.target)
      document.body.appendChild(form)

      form.submit()
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
  // 名簿入力
  // ========================================

  goToInput() {
    window.location.href = "/kumiwake/input"
  }


  // ========================================
  // 人数確認「はい」
  // ========================================

  confirmYes() {

    this.currentStep = "group-question"

    this.showMessage(
      "ところでオヌシは組の名前と数は知っておるかの？"
    )
  }


  // ========================================
  // 人数確認「いいえ」
  // ========================================

  confirmNo() {
    window.location.href = "/kumiwake/input"
  }


  // ========================================
  // 組名入力
  // ========================================

  goToGroupNames() {
    window.location.href = "/kumiwake/group_names"
  }


  // ========================================
  // 魔法選択
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
  // 魔法を使う
  // ========================================

  bousiMagicYes() {

    this.bousiMagic = true

    this.currentStep = "bousi-magic-yes"

    this.showMessage(
      "よしきた！　では　魔法をかけるぞい"
    )
  }


  // ========================================
  // 魔法を使わない
  // ========================================

  bousiMagicNo() {

    this.bousiMagic = false

    this.currentStep = "bousi-magic-no"

    this.showMessage(
      "では、今回は　クミワケ・カブルノｫボウシｨー　は使わずに　組み分けを始めるぞい"
    )
  }


  // ========================================
  // 魔法モードの結果を見る
  // ========================================

  showDrawMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#goToDraw">

        <span class="cursor">▶</span>
        結果をみる

      </button>

    `
  }


  // ========================================
  // 通常モードの結果を見る
  // ========================================

  showNormalDrawMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#goToDraw">

        <span class="cursor">▶</span>
        結果をみる

      </button>

    `
  }


  // ========================================
  // 上限到達後の選択肢
  // ========================================

  showLimitMenu() {

    this.menuTarget.innerHTML = `

      <button
        class="menu-item"
        data-action="click->kumiwake#continueNormal">

        <span class="cursor">▶</span>
        続ける

      </button>


      <button
        class="menu-item"
        data-action="click->kumiwake#finish">

        <span class="cursor">▶</span>
        終わる

      </button>

    `
  }


  // ========================================
  // 魔法終了 → 通常モード
  // ========================================

  continueNormal() {

    const form = document.createElement("form")

    form.method = "POST"
    form.action = "/kumiwake/draw"
    form.dataset.turbo = "false"

    const csrfToken = document.querySelector(
      'meta[name="csrf-token"]'
    ).content

    const csrfInput = document.createElement("input")

    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = csrfToken

    const switchInput = document.createElement("input")

    switchInput.type = "hidden"
    switchInput.name = "switch_to_normal"
    switchInput.value = "true"

    // 明示的に normal モード（魔法なし）を指定
    const modeInput = document.createElement("input")

    modeInput.type = "hidden"
    modeInput.name = "magic_mode"
    modeInput.value = "false"

    form.appendChild(csrfInput)
    form.appendChild(switchInput)
    form.appendChild(modeInput)

    document.body.appendChild(form)

    form.submit()
  }


  // ========================================
  // 組み分け終了
  // ========================================

  finish() {

    const form = document.createElement("form")

    form.method = "POST"
    form.action = "/kumiwake/finish"

    const csrfToken = document.querySelector(
      'meta[name="csrf-token"]'
    ).content

    const csrfInput = document.createElement("input")

    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = csrfToken

    form.appendChild(csrfInput)

    document.body.appendChild(form)

    form.submit()
  }
}