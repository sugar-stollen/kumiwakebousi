import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

addGroupName(event) {

  const button = event.currentTarget

  const panel = button.closest(".kumiwake-input-panel")

  if (!panel) {
    console.log("panel が見つからない")
    return
  }

  const list = panel.querySelector("[data-group-name-list]")

  if (!list) {
    console.log("list が見つからない")
    return
  }

  const maxGroups = Number(list.dataset.maxGroups)

  const currentCount =
    list.querySelectorAll(".group-name-row").length

  console.log("現在の枠数 =", currentCount)
  console.log("最大枠数 =", maxGroups)

  if (currentCount >= maxGroups) {
    console.log("最大数に達しているため追加しない")
    return
  }

  const nextNumber = currentCount + 1

  const nextName =
    String.fromCharCode(64 + nextNumber) + "組"

  const row = document.createElement("div")

  row.className = "group-name-row"

  row.innerHTML = `
    <span>${nextNumber}.</span>

    <input
      type="text"
      name="group_names[]"
      value="${nextName}"
      placeholder="${nextName}">
  `

  list.appendChild(row)

  console.log("追加しました")
}
  removeGroupName(event) {

    const button = event.currentTarget

    const panel = button.closest(".kumiwake-input-panel")

    if (!panel) return

    const list = panel.querySelector("[data-group-name-list]")

    if (!list) return

    const rows =
      list.querySelectorAll(".group-name-row")
    // 2枠よりへらさないようにする
    if (rows.length <= 2) {
      return
    }

    rows[rows.length - 1].remove()

    this.renumberRows(list)
  }

  renumberRows(list) {
    const rows =
      list.querySelectorAll(".group-name-row")

    rows.forEach((row, index) => {
      const number = index + 1
      const numberSpan = row.querySelector("span")

      if (numberSpan) {
        numberSpan.textContent = `${number}.`
      }
    })
  }
}