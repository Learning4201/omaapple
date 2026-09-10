import QtQuick
import QtTest
import ".." as Plugin
import "../Api.js" as Api

TestCase {
  name: "AppleMusicApi"

  Plugin.AppleMusicApi {
    id: api
    auth: QtObject {
      property string restToken: "test-token"
      property string musicUserToken: ""
    }
    xhrFactory: function() {
      return mockXhr
    }
  }

  property var mockXhr: ({
    status: 200,
    readyState: 0,
    responseText: '{"ok":true}',
    headers: {},
    opened: [],
    sent: 0,
    onreadystatechange: null,
    open: function(method, url) {
      this.opened = [method, url]
      this.readyState = 1
    },
    setRequestHeader: function(name, value) {
      this.headers[name] = value
    },
    send: function() {
      this.sent += 1
      this.readyState = 4
      if (this.onreadystatechange) this.onreadystatechange()
    },
    abort: function() {},
    getResponseHeader: function(name) { return this.headers[name] || "" }
  })

  function test_safeApiUrl_blocks_other_hosts() {
    compare(Api.safeApiUrl("https://example.com/v1/test"), "")
    compare(Api.safeApiUrl("/test").indexOf("https://api.music.apple.com/v1") === 0, true)
  }

  function test_get_sets_bearer_and_no_origin() {
    mockXhr.headers = {}
    mockXhr.opened = []
    var done = false
    api.get("/v1/test", null, function(status, payload, error) {
      done = true
      compare(status, 200)
      compare(error, "")
    })
    compare(mockXhr.opened[1].indexOf("https://api.music.apple.com/v1/test") === 0, true)
    compare(mockXhr.headers["Authorization"], "Bearer test-token")
    compare(mockXhr.headers["Origin"] === undefined, true)
    compare(done, true)
  }

  function test_catalogTrack() {
    var row = Api.catalogTrack({
      id: "1613600188",
      type: "songs",
      attributes: { name: "Song", artistName: "Artist", durationInMillis: 125000 }
    })
    compare(row.id, "1613600188")
    compare(row.title, "Song")
    compare(row.duration, "2:05")
  }
}
