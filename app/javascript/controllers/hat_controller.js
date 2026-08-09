import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "menu", "skip"]

  connect() {
    this.scene = "opening"
    this.startOpening()
    
  }

  // --------------------------------
  // セリフを表示
  // --------------------------------

  showMessage(text) {
    this.messageTarget.textContent = text
  }

  // --------------------------------
  // オープニング
  // --------------------------------

  startOpening() {
    this.openingMessages = [
      "おお、よく来たのう……こどもたちよ",
      "ワシか？…… ワシの名前は、組み分け被るの防止帽子じゃ",
      "なに？ 何か言いたいことでもありそうな顔をしておるな",
      "長すぎると言いたいんじゃろ？",
      "だから皆には、こう呼ばれておる……",
      "組み分け帽子",
      "なに？ まだ言いたいことがあるのか？"
    ]

    this.currentMessage = 0

    this.showNextOpeningMessage()
  }

  showNextOpeningMessage() {
  if (this.currentMessage < this.openingMessages.length) {
    const message = this.openingMessages[this.currentMessage]

    this.showMessage(message)
    this.currentMessage += 1

    // 最後のセリフだった場合だけ
    if (message === "なに？ まだ言いたいことがあるのか？") {
      this.showYesNoMenu()
    }
  }
}

  // --------------------------------
  // オープニングのセリフを次へ
  // --------------------------------

next(event) {
  event.preventDefault()

  if (this.scene === "no") {
    this.nextAfterNo()
    return
  }

  if (this.scene === "yes") {
    this.nextYesMessage()
    return
  }

  if (this.scene === "opening") {
    this.showNextOpeningMessage()
  }
}
  // --------------------------------
  // はい・いいえ
  // --------------------------------

  showYesNoMenu() {
    this.menuTarget.innerHTML = `
      <button
        class="menu-item"
        data-action="click->hat#yes">
        <span class="cursor">▶</span>
        はい
      </button>

      <button
        class="menu-item"
        data-action="click->hat#no">
        <span class="cursor">▶</span>
        いいえ
      </button>
    `
  }

  // --------------------------------
// 「はい」
// --------------------------------

yes() {
  this.scene = "yes"

  this.yesMessages = [
    "何？　チョサ…剣？　活かした名前の武器じゃな",
    "ワシは剣なんて、持っとりゃせんよ…"
  ]

  this.yesMessageIndex = 0

  this.showNextYesMessage()
}

showNextYesMessage() {
  if (this.yesMessageIndex < this.yesMessages.length) {
    this.showMessage(this.yesMessages[this.yesMessageIndex])
    this.yesMessageIndex += 1
  } else {
    this.yesMessages = null
    this.yesMessageIndex = undefined

    this.showMessage(
      "なに？ まだ言いたいことがあるのか？"
    )

    this.showYesNoMenu()
  }
}

nextYesMessage() {
  this.showNextYesMessage()
}

  // --------------------------------
  // 「いいえ」
  // --------------------------------

  no() {
  this.scene = "no"

  this.showMessage(
    "そうかそうか、物分かりの良い子は嫌いではないぞ"
  )

  this.menuTarget.innerHTML = ""
}

  nextAfterNo() {
  this.scene = "main"

  this.showMessage(
    "さて、オヌシは何をしに来たんじゃ？"
  )

  this.showMainMenu()
}

  // --------------------------------
  // メインメニュー
  // --------------------------------

  showMainMenu() {
    this.menuTarget.innerHTML = `
      <button
        class="menu-item"
        data-action="click->hat#sorting">
        <span class="cursor">▶</span>
        組み分け
      </button>
    `
  }

  sorting() {
  this.scene = "sorting"

  this.showMessage(
    "組み分けをするんじゃな？"
  )

  // 次のクリックで「部屋を移動じゃ」へ進む
  this.menuTarget.innerHTML = `
    <button
      class="menu-item"
      data-action="click->hat#moveToKumiwake">
      <span class="cursor">▶</span>
      組み分けをはじめる
    </button>
  `
}

// --------------------------------
// スキップ
// --------------------------------

skip() {
  // オープニングを終了した状態にする
  this.currentMessage = this.openingMessages.length

  // 「いいえ」ルートの最後まで飛ばす
  this.scene = "main"

  // 「さて、オヌシは何をしに来たんじゃ？」を表示
  this.showMessage(
    "さて、オヌシは何をしに来たんじゃ？"
  )

  // 「組み分け」の選択肢を表示
  this.showMainMenu()
}

  // --------------------------------
  // 組み分けページへ移動
  // --------------------------------

  moveToKumiwake() {
    this.showMessage(
      "では、部屋を移動じゃ"
    )

    // 少し待ってから組み分けページへ移動
    setTimeout(() => {
      window.location.href = "/kumiwake"
    }, 2000)
  }

}

