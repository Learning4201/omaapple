import QtQuick
import "Api.js" as Api

Item {
  id: root

  visible: false
  width: 0
  height: 0

  required property var auth

  property var xhrFactory: function() { return new XMLHttpRequest() }
  property var now: function() { return Date.now() }
  property var requestQueue: []
  property int requestsInFlight: 0
  property int searchSerial: 0
  property var searchHandle: null
  property double rateLimitedUntil: 0

  function get(path, query, callback, options) {
    return request("GET", path, query, null, callback, options)
  }

  function test(callback) {
    return get("/v1/test", null, callback, { priority: "interactive" })
  }

  function searchCatalog(storefront, term, types, callback) {
    if (searchHandle && typeof searchHandle.abort === "function")
      searchHandle.abort()
    var serial = ++searchSerial
    searchHandle = get("/v1/catalog/" + encodeURIComponent(storefront || "us") + "/search", {
      term: term,
      types: types || "songs",
      limit: 12
    }, function(status, payload, error, xhr) {
      if (serial !== root.searchSerial) return
      if (typeof callback === "function") callback(status, payload, error, xhr)
    }, { priority: "interactive" })
    return searchHandle
  }

  function catalogResource(storefront, type, id, callback) {
    return get("/v1/catalog/" + encodeURIComponent(storefront || "us")
      + "/" + encodeURIComponent(type) + "/" + encodeURIComponent(id),
      null, callback, { priority: "interactive" })
  }

  function request(method, path, query, body, callback, options) {
    var settings = options || ({})
    var handle = { aborted: false, xhr: null }
    var job = {
      method: method,
      path: path,
      query: query,
      body: body,
      callback: callback,
      handle: handle,
      retried: false
    }
    requestQueue = requestQueue.concat([job])
    pump()
    handle.abort = function() {
      handle.aborted = true
      if (handle.xhr && typeof handle.xhr.abort === "function") handle.xhr.abort()
    }
    return handle
  }

  function pump() {
    if (requestsInFlight >= Api.API_MAX_IN_FLIGHT) return
    if (now() < rateLimitedUntil) return
    if (!requestQueue.length) return
    var job = requestQueue[0]
    requestQueue = requestQueue.slice(1)
    startJob(job)
  }

  function startJob(job) {
    var handle = job.handle
    if (handle.aborted) {
      Qt.callLater(pump)
      return
    }
    var url = Api.safeApiUrl(job.path)
    if (!url) {
      finish(job, 0, null, "Blocked non-Apple Music API URL")
      return
    }
    url = Api.appendQuery(url, job.query)
    var token = auth && auth.restToken ? String(auth.restToken) : ""
    if (!token) {
      finish(job, 0, null, "Import a MusicKit key first")
      return
    }

    requestsInFlight += 1
    var xhr = xhrFactory()
    handle.xhr = xhr
    xhr.onreadystatechange = function() {
      if (xhr.readyState !== XMLHttpRequest.DONE) return
      if (handle.aborted) {
        requestsInFlight = Math.max(0, requestsInFlight - 1)
        Qt.callLater(pump)
        return
      }
      if (xhr.status === 429 && job.retried !== true) {
        job.retried = true
        rateLimitedUntil = now() + Api.retryAfterMs(Api.responseRetryAfter(xhr))
        requestQueue = [job].concat(requestQueue)
        requestsInFlight = Math.max(0, requestsInFlight - 1)
        Qt.callLater(pump)
        return
      }
      var payload = Api.parseJson(xhr.responseText, null)
      var ok = xhr.status >= 200 && xhr.status < 300
      var error = ok ? "" : Api.redact(xhr.status + " " + (xhr.responseText || "request failed"))
      requestsInFlight = Math.max(0, requestsInFlight - 1)
      finish(job, xhr.status, payload, error)
    }
    try {
      xhr.open(String(job.method || "GET"), url)
      xhr.setRequestHeader("Authorization", "Bearer " + token)
      xhr.setRequestHeader("Accept", "application/json")
      if (auth && auth.musicUserToken)
        xhr.setRequestHeader("Music-User-Token", auth.musicUserToken)
      // Do not set Origin. REST JWT has no origin claim.
      if (job.body) {
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.send(JSON.stringify(job.body))
      } else {
        xhr.send()
      }
    } catch (e) {
      requestsInFlight = Math.max(0, requestsInFlight - 1)
      finish(job, 0, null, "Something went wrong contacting Apple Music")
    }
  }

  function finish(job, status, payload, error) {
    if (job.handle) job.handle.xhr = null
    if (typeof job.callback === "function" && !job.handle.aborted)
      job.callback(status, payload, error)
    Qt.callLater(pump)
  }
}
