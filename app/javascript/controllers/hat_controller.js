import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "menu", "skip"]

  connect() {
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
      this.showMessage(this.openingMessages[this.currentMessage])
      this.currentMessage += 1
    } else {
      this.showYesNoMenu()
    }
  }

  // --------------------------------
  // オープニングのセリフを次へ
  // --------------------------------

next(event) {
  event.preventDefault()

  // 「はい」ルート中なら、はいルートを進める
  if (this.yesMessages && this.yesMessageIndex !== undefined) {
    this.nextYesMessage()
    return
  }

  // オープニング
  if (this.currentMessage < this.openingMessages.length) {
    this.showNextOpeningMessage()
  } else {
    this.showYesNoMenu()
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
    this.showMessage(
      "そうかそうか、物分かりの良い子は嫌いではないぞ"
    )

    this.menuTarget.innerHTML = `
      <button
        class="menu-item"
        data-action="click->hat#nextAfterNo">
        <span class="cursor">▶</span>
        次へ
      </button>
    `
  }

  nextAfterNo() {
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
    this.showMessage(
      "組み分けをするんじゃな？"
    )
  }

  // --------------------------------
  // スキップ
  // --------------------------------

  skip() {
    this.showMessage(
      "なに？ まだ言いたいことがあるのか？"
    )

    this.showYesNoMenu()
  }
}