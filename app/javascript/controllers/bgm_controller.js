import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "kumiwakebousi.bgmEnabled"
const VOLUME_KEY = "kumiwakebousi.bgmVolume.v2"
const POSITION_KEY = "kumiwakebousi.bgmPosition"
const SOURCE_GAIN = 0.25
const LOOP_END_CUT_SECONDS = 1

export default class extends Controller {
  static targets = ["audio", "button", "volume"]

  connect() {
    const savedVolume = localStorage.getItem(VOLUME_KEY)
    this.volumeTarget.value = savedVolume ?? "50"
    this.enabled = localStorage.getItem(STORAGE_KEY) === "true"
    this.setupGain()
    this.setVolume()
    this.restorePosition()
    this.savePlaybackPosition = () => this.persistPosition()
    window.addEventListener("pagehide", this.savePlaybackPosition)

    if (this.enabled) {
      this.play()
    } else {
      this.updateButton()
    }
  }

  disconnect() {
    window.removeEventListener("pagehide", this.savePlaybackPosition)
    this.audioContext?.close()
  }

  setupGain() {
    const AudioContextClass = window.AudioContext || window.webkitAudioContext
    if (!AudioContextClass) return

    this.audioContext = new AudioContextClass()
    this.sourceNode = this.audioContext.createMediaElementSource(this.audioTarget)
    this.sourceGainNode = this.audioContext.createGain()
    this.volumeGainNode = this.audioContext.createGain()

    this.sourceGainNode.gain.value = SOURCE_GAIN
    this.sourceNode.connect(this.sourceGainNode)
    this.sourceGainNode.connect(this.volumeGainNode)
    this.volumeGainNode.connect(this.audioContext.destination)
  }

  restorePosition() {
    const position = Number(localStorage.getItem(POSITION_KEY))
    if (!position || position < 0) return

    const seek = () => {
      if (Number.isFinite(this.audioTarget.duration)) {
        this.audioTarget.currentTime = Math.min(
          position,
          Math.max(0, this.audioTarget.duration - LOOP_END_CUT_SECONDS)
        )
      }
    }

    if (this.audioTarget.readyState >= 1) {
      seek()
    } else {
      this.audioTarget.addEventListener("loadedmetadata", seek, { once: true })
    }
  }

  persistPosition() {
    if (this.enabled && this.audioTarget.currentTime > 0) {
      localStorage.setItem(POSITION_KEY, String(this.audioTarget.currentTime))
    }
  }

  toggle() {
    this.enabled = !this.enabled
    localStorage.setItem(STORAGE_KEY, String(this.enabled))

    if (this.enabled) {
      this.play()
    } else {
      this.audioTarget.pause()
      this.audioTarget.currentTime = 0
      localStorage.removeItem(POSITION_KEY)
      this.updateButton()
    }
  }

  setVolume() {
    const volume = Number(this.volumeTarget.value) / 100

    if (this.volumeGainNode) {
      this.volumeGainNode.gain.value = volume
    } else {
      this.audioTarget.volume = SOURCE_GAIN * volume
    }

    localStorage.setItem(VOLUME_KEY, this.volumeTarget.value)
  }

  trimEnd() {
    const { currentTime, duration } = this.audioTarget
    if (!Number.isFinite(duration) || duration <= LOOP_END_CUT_SECONDS) return

    if (currentTime >= duration - LOOP_END_CUT_SECONDS) {
      this.audioTarget.currentTime = 0
    }
  }

  play() {
    const contextReady = this.audioContext
      ? this.audioContext.resume()
      : Promise.resolve()

    contextReady
      .then(() => this.audioTarget.play())
      .then(() => this.updateButton())
      .catch(() => {
        this.enabled = false
        localStorage.setItem(STORAGE_KEY, "false")
        this.updateButton()
      })
  }

  updateButton() {
    this.buttonTarget.textContent = this.enabled ? "BGM ON" : "BGM OFF"
    this.buttonTarget.setAttribute("aria-checked", String(this.enabled))
    this.buttonTarget.classList.toggle("is-on", this.enabled)
  }
}
