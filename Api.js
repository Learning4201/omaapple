.pragma library

var API_BASE = "https://api.music.apple.com/v1"
var API_MAX_IN_FLIGHT = 4

function redact(value) {
  var text = String(value || "")
  text = text.replace(/(authorization\s*:\s*bearer\s+)[^\s]+/ig, "$1<redacted>")
  text = text.replace(/(music-user-token\s*:\s*)[^\s]+/ig, "$1<redacted>")
  text = text.replace(/("(?:token|developerToken|userToken|p8|privateKey)"\s*:\s*")[^"]+/ig, "$1<redacted>")
  return text
}

function parseJson(text, fallback) {
  try {
    if (!text) return fallback
    return JSON.parse(text)
  } catch (e) {
    return fallback
  }
}

function appendQuery(url, query) {
  if (!query || typeof query !== "object") return url
  var parts = []
  for (var key in query) {
    if (!Object.prototype.hasOwnProperty.call(query, key)) continue
    if (query[key] === undefined || query[key] === null || query[key] === "") continue
    parts.push(encodeURIComponent(key) + "=" + encodeURIComponent(String(query[key])))
  }
  if (!parts.length) return url
  return url + (url.indexOf("?") >= 0 ? "&" : "?") + parts.join("&")
}

function safeApiUrl(path) {
  var value = String(path || "")
  if (value.charAt(0) === "/") {
    if (value.indexOf("/v1") === 0) return "https://api.music.apple.com" + value
    return API_BASE + value
  }
  if (value.indexOf(API_BASE) === 0) return value
  return ""
}

function formatMs(ms) {
  var n = Math.max(0, Math.floor(Number(ms) || 0) / 1000)
  var m = Math.floor(n / 60)
  var s = Math.floor(n % 60)
  return m + ":" + (s < 10 ? "0" : "") + s
}

function catalogTrack(item) {
  if (!item || typeof item !== "object") return null
  var attrs = item.attributes || {}
  var artist = attrs.artistName || ""
  if (!artist && attrs.curatorName) artist = attrs.curatorName
  return {
    id: String(item.id || ""),
    type: String(item.type || "songs"),
    title: String(attrs.name || ""),
    artist: String(artist),
    duration: formatMs(attrs.durationInMillis)
  }
}

function catalogResults(payload, type) {
  var out = []
  var results = payload && payload.results ? payload.results : null
  if (!results) return out
  var bucket = results[type] || results.songs
  var data = bucket && bucket.data ? bucket.data : []
  for (var i = 0; i < data.length; i++) {
    var row = catalogTrack(data[i])
    if (row && row.id) out.push(row)
  }
  return out
}

function searchTypes(uiType) {
  if (uiType === "albums") return "albums"
  if (uiType === "artists") return "artists"
  if (uiType === "playlists") return "playlists"
  return "songs"
}

function responseRetryAfter(xhr) {
  if (!xhr || typeof xhr.getResponseHeader !== "function") return ""
  try {
    return xhr.getResponseHeader("Retry-After") || ""
  } catch (e) {
    return ""
  }
}

function retryAfterMs(header) {
  var seconds = Number(String(header || "").trim())
  if (!isFinite(seconds) || seconds <= 0) return 1000
  return Math.max(1000, Math.round(seconds * 1000))
}
