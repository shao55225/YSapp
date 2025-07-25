/*! Aliplayer - v2.8.2 - 2019-05-09 16.34.41 */
!(function n(a, s, l) {
  function u(t, e) {
    if (!s[t]) {
      if (!a[t]) {
        var i = "function" == typeof require && require;
        if (!e && i) return i(t, !0);
        if (c) return c(t, !0);
        var r = new Error("Cannot find module '" + t + "'");
        throw ((r.code = "MODULE_NOT_FOUND"), r);
      }
      var o = (s[t] = { exports: {} });
      a[t][0].call(
        o.exports,
        function (e) {
          return u(a[t][1][e] || e);
        },
        o,
        o.exports,
        n,
        a,
        s,
        l
      );
    }
    return s[t].exports;
  }
  for (
    var c = "function" == typeof require && require, e = 0;
    e < l.length;
    e++
  )
    u(l[e]);
  return u;
})(
  {
    1: [
      function (e, t, i) {
        !(function () {
          "use strict";
          function l(o, e) {
            var t;
            if (
              ((e = e || {}),
              (this.trackingClick = !1),
              (this.trackingClickStart = 0),
              (this.targetElement = null),
              (this.touchStartX = 0),
              (this.touchStartY = 0),
              (this.lastTouchIdentifier = 0),
              (this.touchBoundary = e.touchBoundary || 10),
              (this.layer = o),
              (this.tapDelay = e.tapDelay || 200),
              (this.tapTimeout = e.tapTimeout || 700),
              !l.notNeeded(o))
            ) {
              for (
                var i = [
                    "onMouse",
                    "onClick",
                    "onTouchStart",
                    "onTouchMove",
                    "onTouchEnd",
                    "onTouchCancel",
                  ],
                  r = this,
                  n = 0,
                  a = i.length;
                n < a;
                n++
              )
                r[i[n]] = s(r[i[n]], r);
              u &&
                (o.addEventListener("mouseover", this.onMouse, !0),
                o.addEventListener("mousedown", this.onMouse, !0),
                o.addEventListener("mouseup", this.onMouse, !0)),
                o.addEventListener("click", this.onClick, !0),
                o.addEventListener("touchstart", this.onTouchStart, !1),
                o.addEventListener("touchmove", this.onTouchMove, !1),
                o.addEventListener("touchend", this.onTouchEnd, !1),
                o.addEventListener("touchcancel", this.onTouchCancel, !1),
                Event.prototype.stopImmediatePropagation ||
                  ((o.removeEventListener = function (e, t, i) {
                    var r = Node.prototype.removeEventListener;
                    "click" === e
                      ? r.call(o, e, t.hijacked || t, i)
                      : r.call(o, e, t, i);
                  }),
                  (o.addEventListener = function (e, t, i) {
                    var r = Node.prototype.addEventListener;
                    "click" === e
                      ? r.call(
                          o,
                          e,
                          t.hijacked ||
                            (t.hijacked = function (e) {
                              e.propagationStopped || t(e);
                            }),
                          i
                        )
                      : r.call(o, e, t, i);
                  })),
                "function" == typeof o.onclick &&
                  ((t = o.onclick),
                  o.addEventListener(
                    "click",
                    function (e) {
                      t(e);
                    },
                    !1
                  ),
                  (o.onclick = null));
            }
            function s(e, t) {
              return function () {
                return e.apply(t, arguments);
              };
            }
          }
          var e = 0 <= navigator.userAgent.indexOf("Windows Phone"),
            u = 0 < navigator.userAgent.indexOf("Android") && !e,
            s = /iP(ad|hone|od)/.test(navigator.userAgent) && !e,
            c = s && /OS 4_\d(_\d)?/.test(navigator.userAgent),
            d = s && /OS [6-7]_\d/.test(navigator.userAgent),
            o = 0 < navigator.userAgent.indexOf("BB10");
          (l.prototype.needsClick = function (e) {
            switch (e.nodeName.toLowerCase()) {
              case "button":
              case "select":
              case "textarea":
                if (e.disabled) return !0;
                break;
              case "input":
                if ((s && "file" === e.type) || e.disabled) return !0;
                break;
              case "label":
              case "iframe":
              case "video":
                return !0;
            }
            return /\bneedsclick\b/.test(e.className);
          }),
            (l.prototype.needsFocus = function (e) {
              switch (e.nodeName.toLowerCase()) {
                case "textarea":
                  return !0;
                case "select":
                  return !u;
                case "input":
                  switch (e.type) {
                    case "button":
                    case "checkbox":
                    case "file":
                    case "image":
                    case "radio":
                    case "submit":
                      return !1;
                  }
                  return !e.disabled && !e.readOnly;
                default:
                  return /\bneedsfocus\b/.test(e.className);
              }
            }),
            (l.prototype.sendClick = function (e, t) {
              var i, r;
              document.activeElement &&
                document.activeElement !== e &&
                document.activeElement.blur(),
                (r = t.changedTouches[0]),
                (i = document.createEvent("MouseEvents")).initMouseEvent(
                  this.determineEventType(e),
                  !0,
                  !0,
                  window,
                  1,
                  r.screenX,
                  r.screenY,
                  r.clientX,
                  r.clientY,
                  !1,
                  !1,
                  !1,
                  !1,
                  0,
                  null
                ),
                (i.forwardedTouchEvent = !0),
                e.dispatchEvent(i);
            }),
            (l.prototype.determineEventType = function (e) {
              return u && "select" === e.tagName.toLowerCase()
                ? "mousedown"
                : "click";
            }),
            (l.prototype.focus = function (e) {
              var t;
              s &&
              e.setSelectionRange &&
              0 !== e.type.indexOf("date") &&
              "time" !== e.type &&
              "month" !== e.type
                ? ((t = e.value.length), e.setSelectionRange(t, t))
                : e.focus();
            }),
            (l.prototype.updateScrollParent = function (e) {
              var t, i;
              if (!(t = e.fastClickScrollParent) || !t.contains(e)) {
                i = e;
                do {
                  if (i.scrollHeight > i.offsetHeight) {
                    (t = i), (e.fastClickScrollParent = i);
                    break;
                  }
                  i = i.parentElement;
                } while (i);
              }
              t && (t.fastClickLastScrollTop = t.scrollTop);
            }),
            (l.prototype.getTargetElementFromEventTarget = function (e) {
              return e.nodeType === Node.TEXT_NODE ? e.parentNode : e;
            }),
            (l.prototype.onTouchStart = function (e) {
              var t, i, r;
              if (1 < e.targetTouches.length) return !0;
              if (
                ((t = this.getTargetElementFromEventTarget(e.target)),
                (i = e.targetTouches[0]),
                s)
              ) {
                if ((r = window.getSelection()).rangeCount && !r.isCollapsed)
                  return !0;
                if (!c) {
                  if (i.identifier && i.identifier === this.lastTouchIdentifier)
                    return e.preventDefault(), !1;
                  (this.lastTouchIdentifier = i.identifier),
                    this.updateScrollParent(t);
                }
              }
              return (
                (this.trackingClick = !0),
                (this.trackingClickStart = e.timeStamp),
                (this.targetElement = t),
                (this.touchStartX = i.pageX),
                (this.touchStartY = i.pageY),
                e.timeStamp - this.lastClickTime < this.tapDelay &&
                  e.preventDefault(),
                !0
              );
            }),
            (l.prototype.touchHasMoved = function (e) {
              var t = e.changedTouches[0],
                i = this.touchBoundary;
              return (
                Math.abs(t.pageX - this.touchStartX) > i ||
                Math.abs(t.pageY - this.touchStartY) > i
              );
            }),
            (l.prototype.onTouchMove = function (e) {
              return (
                this.trackingClick &&
                  (this.targetElement !==
                    this.getTargetElementFromEventTarget(e.target) ||
                    this.touchHasMoved(e)) &&
                  ((this.trackingClick = !1), (this.targetElement = null)),
                !0
              );
            }),
            (l.prototype.findControl = function (e) {
              return void 0 !== e.control
                ? e.control
                : e.htmlFor
                ? document.getElementById(e.htmlFor)
                : e.querySelector(
                    "button, input:not([type=hidden]), keygen, meter, output, progress, select, textarea"
                  );
            }),
            (l.prototype.onTouchEnd = function (e) {
              var t,
                i,
                r,
                o,
                n,
                a = this.targetElement;
              if (!this.trackingClick) return !0;
              if (e.timeStamp - this.lastClickTime < this.tapDelay)
                return (this.cancelNextClick = !0);
              if (e.timeStamp - this.trackingClickStart > this.tapTimeout)
                return !0;
              if (
                ((this.cancelNextClick = !1),
                (this.lastClickTime = e.timeStamp),
                (i = this.trackingClickStart),
                (this.trackingClick = !1),
                (this.trackingClickStart = 0),
                d &&
                  ((n = e.changedTouches[0]),
                  ((a =
                    document.elementFromPoint(
                      n.pageX - window.pageXOffset,
                      n.pageY - window.pageYOffset
                    ) || a).fastClickScrollParent =
                    this.targetElement.fastClickScrollParent)),
                "label" === (r = a.tagName.toLowerCase()))
              ) {
                if ((t = this.findControl(a))) {
                  if ((this.focus(a), u)) return !1;
                  a = t;
                }
              } else if (this.needsFocus(a))
                return (
                  100 < e.timeStamp - i ||
                  (s && window.top !== window && "input" === r)
                    ? (this.targetElement = null)
                    : (this.focus(a),
                      this.sendClick(a, e),
                      (s && "select" === r) ||
                        ((this.targetElement = null), e.preventDefault())),
                  !1
                );
              return (
                !(
                  !s ||
                  c ||
                  !(o = a.fastClickScrollParent) ||
                  o.fastClickLastScrollTop === o.scrollTop
                ) ||
                (this.needsClick(a) ||
                  (e.preventDefault(), this.sendClick(a, e)),
                !1)
              );
            }),
            (l.prototype.onTouchCancel = function () {
              (this.trackingClick = !1), (this.targetElement = null);
            }),
            (l.prototype.onMouse = function (e) {
              return (
                !this.targetElement ||
                !!e.forwardedTouchEvent ||
                !e.cancelable ||
                !(
                  !this.needsClick(this.targetElement) || this.cancelNextClick
                ) ||
                (e.stopImmediatePropagation
                  ? e.stopImmediatePropagation()
                  : (e.propagationStopped = !0),
                e.stopPropagation(),
                e.preventDefault(),
                !1)
              );
            }),
            (l.prototype.onClick = function (e) {
              var t;
              return this.trackingClick
                ? ((this.targetElement = null), !(this.trackingClick = !1))
                : ("submit" === e.target.type && 0 === e.detail) ||
                    ((t = this.onMouse(e)) || (this.targetElement = null), t);
            }),
            (l.prototype.destroy = function () {
              var e = this.layer;
              u &&
                (e.removeEventListener("mouseover", this.onMouse, !0),
                e.removeEventListener("mousedown", this.onMouse, !0),
                e.removeEventListener("mouseup", this.onMouse, !0)),
                e.removeEventListener("click", this.onClick, !0),
                e.removeEventListener("touchstart", this.onTouchStart, !1),
                e.removeEventListener("touchmove", this.onTouchMove, !1),
                e.removeEventListener("touchend", this.onTouchEnd, !1),
                e.removeEventListener("touchcancel", this.onTouchCancel, !1);
            }),
            (l.notNeeded = function (e) {
              var t, i, r;
              if (void 0 === window.ontouchstart) return !0;
              if (
                (i = +(/Chrome\/([0-9]+)/.exec(navigator.userAgent) || [
                  ,
                  0,
                ])[1])
              ) {
                if (!u) return !0;
                if ((t = document.querySelector("meta[name=viewport]"))) {
                  if (-1 !== t.content.indexOf("user-scalable=no")) return !0;
                  if (
                    31 < i &&
                    document.documentElement.scrollWidth <= window.outerWidth
                  )
                    return !0;
                }
              }
              if (
                o &&
                10 <=
                  (r = navigator.userAgent.match(
                    /Version\/([0-9]*)\.([0-9]*)/
                  ))[1] &&
                3 <= r[2] &&
                (t = document.querySelector("meta[name=viewport]"))
              ) {
                if (-1 !== t.content.indexOf("user-scalable=no")) return !0;
                if (document.documentElement.scrollWidth <= window.outerWidth)
                  return !0;
              }
              return (
                "none" === e.style.msTouchAction ||
                "manipulation" === e.style.touchAction ||
                !!(
                  27 <=
                    +(/Firefox\/([0-9]+)/.exec(navigator.userAgent) || [
                      ,
                      0,
                    ])[1] &&
                  (t = document.querySelector("meta[name=viewport]")) &&
                  (-1 !== t.content.indexOf("user-scalable=no") ||
                    document.documentElement.scrollWidth <= window.outerWidth)
                ) ||
                "none" === e.style.touchAction ||
                "manipulation" === e.style.touchAction
              );
            }),
            (l.attach = function (e, t) {
              return new l(e, t);
            }),
            "function" == typeof define &&
            "object" == typeof define.amd &&
            define.amd
              ? define(function () {
                  return l;
                })
              : void 0 !== t && t.exports
              ? ((t.exports = l.attach), (t.exports.FastClick = l))
              : (window.FastClick = l);
        })();
      },
      {},
    ],
    2: [
      function (e, t, i) {
        var r = e("../ui/component"),
          o = (e("../lib/util"), e("../lib/dom")),
          n = e("../lib/event"),
          a = (e("../lib/ua"), e("../lang/index")),
          s = e("../player/base/event/eventtype"),
          l = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-auto-stream-selector"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (
                (e.innerHTML =
                  "<div><p class='tip-text'></p></div><div class='operators'><a class='prism-button prism-button-ok' type='button'>" +
                  a.get("OK_Text") +
                  "</a><a class='prism-button prism-button-cancel'  target='_blank'>" +
                  a.get("Cancel_Text") +
                  "</a></div>"),
                e
              );
            },
            bindEvent: function () {
              var r = this;
              r._player.on(s.Private.AutoStreamShow, function (e) {
                var t = document.querySelector("#" + r.getId() + " .tip-text");
                if (r._player._getLowerQualityLevel) {
                  var i = r._player._getLowerQualityLevel();
                  i &&
                    ((r._switchUrl = i),
                    (t.innerText = a
                      .get("Auto_Stream_Tip_Text")
                      .replace("$$", i.item.desc)),
                    o.css(r.el(), "display", "block"));
                }
              }),
                r._player.on(s.Private.AutoStreamHide, function (e) {
                  document.querySelector("#" + r.getId() + " .tip-text");
                  o.css(r.el(), "display", "none");
                });
              var e = document.querySelector(
                "#" + r.getId() + " .prism-button-ok"
              );
              n.on(e, "click", function () {
                r._player._changeStream &&
                  r._switchUrl &&
                  r._player._changeStream(
                    r._switchUrl.index,
                    a.get("Quality_Change_Text")
                  ),
                  o.css(r.el(), "display", "none");
              });
              var t = document.querySelector(
                "#" + r.getId() + " .prism-button-cancel"
              );
              n.on(t, "click", function () {
                o.css(r.el(), "display", "none");
              });
            },
          });
        t.exports = l;
      },
      {
        "../lang/index": 11,
        "../lib/dom": 18,
        "../lib/event": 19,
        "../lib/ua": 31,
        "../lib/util": 33,
        "../player/base/event/eventtype": 43,
        "../ui/component": 94,
      },
    ],
    3: [
      function (e, t, i) {
        var r = e("../ui/component"),
          s = e("../lib/dom"),
          o = e("../lib/event"),
          n = e("../lib/ua"),
          a = e("../lib/function"),
          l = (e("../lang/index"), e("../lib/util")),
          u = e("../config"),
          c = e("../lib/playerutil"),
          d = e("../player/base/event/eventtype"),
          p = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-liveshift-progress"),
                this.addClass(this.className),
                (this._liveshiftService = e._liveshiftService);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this);
              return (
                (e.innerHTML =
                  '<div class="prism-enable-liveshift"><div class="prism-progress-loaded"></div><div class="prism-progress-played"></div><div class="prism-progress-cursor"><img></img></div><p class="prism-progress-time"></p><div class="prism-liveshift-seperator">00:00:00</div></div><div class="prism-disable-liveshift"></div>'),
                e
              );
            },
            bindEvent: function () {
              var i = this;
              (this.loadedNode = document.querySelector(
                "#" + this.id() + " .prism-progress-loaded"
              )),
                (this.playedNode = document.querySelector(
                  "#" + this.id() + " .prism-progress-played"
                )),
                (this.cursorNode = document.querySelector(
                  "#" + this.id() + " .prism-progress-cursor"
                )),
                (this.timeNode = document.querySelector(
                  "#" + this.id() + " .prism-progress-time"
                )),
                (this.controlNode = document.querySelector(
                  "#" + this._player._options.id + " .prism-controlbar"
                )),
                (this.seperatorNode = document.querySelector(
                  "#" + this.id() + " .prism-liveshift-seperator"
                )),
                (this.progressNode = document.querySelector(
                  "#" + this.id() + " .prism-enable-liveshift"
                ));
              var e = document.querySelector(
                  "#" + this.id() + " .prism-progress-cursor img"
                ),
                t =
                  "//" +
                  u.domain +
                  "/de/prismplayer/" +
                  u.h5Version +
                  "/skins/default/img/dragcursor.png";
              u.domain
                ? -1 < u.domain.indexOf("localhost") &&
                  (t =
                    "//" + u.domain + "/build/skins/default/img/dragcursor.png")
                : (t =
                    "de/prismplayer/" +
                    u.h5Version +
                    "/skins/default/img/dragcursor.png"),
                (e.src =
                  "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEQAAABECAYAAAA4E5OyAAAAAXNSR0IArs4c6QAADHFJREFUeAHNWltoVdkZPknM1RhrMtNqdRgnU6QPVRGqVLDVohZqEeahF9BpB0tvjoj1wam+2SKKKFj6UCtU26JTHAVLxXmxE6kdpDMPiowRO4oGrZeaeInRXDTR0+/bOd/23+usfc4+OycZF6z8a/3rX//lO/+67L1TkRmbUlEmM9ky6YlVUy5HXQOjpde1U3aAyul4Gl1xc9IEmmaOC3AmzqE8wQKMpDqSysWZShpwUjmvnZE4mWSuK+P2vU55mG6Qbt8zJZNEJm9eGgeLzXHHbd+2rTPixwVh+bZNHW7f6k0yHpGXIxFmgU4heTtWattn0gZaatvVZ+e7Y5G+dTwy4OkUktWYKKerHUetjGvOBqB2HOVcd8zVZ2V8YyGvMmwVbigoV4p8jVlKvexH6K5duxo6OzuXDwwM7BgcHDz69OnT9mw2ex31Qa5eJ49jfX19OynLOT5dRjeaER/kB/m2xPGtTKI2Ffkqg2WtytVxoKzVqDWotayHDh2a3N3d/VME+fdnz571IvCSCuc8fvz46L179362f//+KdKbs0Fbsis/5JfP5xGDEqdURuVEHhDbtm2b1NvbuxkB9aCWBIJPmDqo68GDB7/ZtGlTSwww8kf+xfmP6aWXOGUyRuP6dcKsWL58eQOcXgPnb5YDCBcc6sSyunXnzp21ixYtaoQPzERmpJst8jMuDkxJXuKUyIjAoBMhGG1tba9jaZweDSB8wDx58uTMkSNHZsCHOlSBImDoo/yNiwciyYpPgZRbMLRX1F25cuUbAGJUssIFQ30CPzQ09L8zZ84sRljjUd1sKQZKIjRKBuP+/fur4Fw/HRzrQpu0ffXq1Z8jOi4hmy1c0iMGxQWkYGbkwBhrHPLsEZiOjo5fpAAFU+KLCwb7BIQos+o0YWpqmXwmmeEiokw5derUt+DbBPqHavcTZYovRoj6iysclx113EC529ORF6XQF+4pu3fv/grC0wlkQVE8bpxeNFwhTbaZEWyis2bNGo8dfkxOk1LBJii45Z6dPHnyy4iSG61On2L7SR4oPkDsUtGJUs87QC5FS/V31OXl18WLF99BhM2ovPrTdwESt3QgEi0WkLjsqOMtEWn5Qi0VF2WCggy+vWTJklaEOBGVe16xpRNBw4LBNgFRdlBRmB0PHz78tX4F15EXpS//rl27tgO+v4Rql47iYoxu3EHQ4IdPi2yzuILB5L179zbPnTv33YqKilrUYcmUf/m8/sm9Z5kPbgxl2lA/6nyaufwwi+f4iswX6ivyHCrFjHxrbGycdfPmzb/i4taH+c9ytaAqRSVKYbVJWYVkZVdX14+am5v/QIMyygmllCEgcfjKYGbfp08ydwboY355ub4ys2pGTeZ7rdWZcfImX6wgB9maYW1vb98we/bsv0CYoAyi0ih/D987lKzMiUIuAIF9WwlKJXbvg3V1dcvTgnG7P5tZ9+/+zKfdT2mnaPny56oyv51fH2RMUWGPAAHBxfF4S0vLjzHcizqASuMCRBSsoGT164vhowEwa9asqa+pqVnsE0jCIxg//GdfYjCo8z8AjnM4N21pamr6+rx587iH8JRhvIVKhStgM4UTwz5Ol8XIDB5hJRcuE2ZGV79/iRRSyDm/xFzqSFMqKyvrd+7cuRBzddwWjNkdpE27VML+hAkTqDRV4Z6RdJn4DDBTqCNtaW1tnY+5zBBWG1/4g0u3DxCNkWpyZty4cTPS7B38YbmBjrT86eKTcBcsRRd9bmhoeB1zGKuyJFZFMUA0sQKAvMZOqaDwaI07TaQ8CeXSoa5Sinytra19FfMIBmteVlidhQCJTITySXZi0va5e8lOlCT60urCj9kE/YyH8Yp6TVpAIgA40hzj02NwtjtjBbtpNtI4haXq4rHLgh+TpwxjUCXbljB2C4hPIKJABqzgi952fGa8ijkEwcagQcvztvHu45F3oAiTt85ylbS68DDKS5kXANe3xN4C6W4HbVeXtz+zmftYeUoaXfQZgPQk9SAxIPi80JEGkFnNlZm0v6wNgjqoq9RCn/Hp9BrmDW8oRRTEWdBk0qANQC5RuWoRveEw85QPaiMt1JEo53OG5CcpviBeybF5buvsVowR1ywgXgHpx7fVf1F5msKnVj6opS2cSx1pCn3G27OPMZfOq7qqwsAsILFCHMC32g+gvE+giLqTfH0+wvOpNc3S4RzOLeU1gHwjxcui/g0bNnwIvxg0s0PU52reucystJWAsZJXhSx5Dy9dvl1VVRXcWHUTxFiiMlaP/wSCFSdj5u7du21Tpkzh95rHqHwn0o/KByNliyhYz8/koOP5Y4WzPT097wPx8HKmX8Izz8vim7AD32zIvDO7rmC2MCsosx+ynFNKkU+k9LWjo6MN87V38NqsPcSrVtmgQVkXX9kRZMqWLVteWr9+fXt1dXVj2iyRISLNZxNex3UDJRA8WnmayBHJJ6UEgpXZgRfNvStWrFh09OjRu5jP7OB9hNlhXxKhG2QLaVAUvCiD5w7IR2XuZHxjXY/K6++EGzdubOvv7+cHIX5TDSoceCGK/KFv9PHcuXO/g89fQn0VlS+b+T7HffuuuAOqrZ8dlYhAjhny8G9OZ5ctW/YmXrw0cg/RPiIqJWNN8YsEJrlMctnR+cYbb6y/desW9w5mheiwoN/B4BWib4iTVDmudvbAgQOP8LJ5B43SuBzxKRlrHn0RIBcuXPh97m07lwdfyBAUnTKKJ89FZYaoBMKMAIPtyF4ybdq0GqTjCbxwno1H6wyy5TPLFP0gAgPLJfPo0aPzeEv2XXxDIhB8scz9gxkyhCowRMEKS2yGSIKTWDQ5oNevXx88ePDgm7i93qYDNlPk4PC00f0rWxYMbKSdmzdvfhtgMHhWZQczhUUxDfcK/LVZEZwqkLWbK+/f/BcDbkx8N9J0/PjxZbgWY//qzwIc/u/XmG20+BECW7RJ2/QBmTGwb9++H8A3bqTTUaegpvqUiXnB0nBBISACJfycCZ5AmYSlsxaOBA7h14mcPnS63EVAkPI0oc0cGNmTJ0/+Cr7NQH0N9YuoJX/sZiYUKja9tGzsxjQ4c+bMdy9fvrwOzj3m8uFmy2rTWe1ChoqNUYf0kMoObdL26dOnNy5cuPBv0KOlwj3D7hsyYWMSL6QWEFdQfQHhUgEzhE+FB06cOPF9pG5nzsHAYfyKkSAUUGg9QcMFgjoJhuwgQ7oOHz78Vg4M7hM8TXg9t2BY32lVsbHN4vaHufhrl4zaBM0uHV3WuJ/owsaXuC3YzL6KZ4dPuITw2TOL9xBBSsP5YH9BIOEeY1O/UJtzWKmDy4M6qZs2cPy3r169eiFsc5m0or6CygtY6n+pYtBucXnqCyAfJWis1fiOWo9seWv69OnrcL3/vI5kUV3mdJETlRPKImWGqLKNFOB08Z6xdOnS9wAMlwizgpVHrDJDGVxSdihY6AlLIZ4PDPEECq/8tQsWLGjas2fP21OnTv0JgBnPwONACS3nGgJBVGAgU3o7Ojr+vGrVqj+ePXuWdwsuEQFCMHjEsp8UDIhGl4sveAr5+OIJgDhKYPQcVL1y5cqWtWvXfgfALJ04ceJ8AFOvrBClQVsIBEsOkH58wf8I//zStn379n8cO3asG0MM2G6eyhDybEaoDXY0cDJQhg0Nt4O/CtKwEvEtGJygPsGw7RAY8KvnzJnTsHXr1kW4RX4N71VacdN9BVnThAwKPqIjA/qQDT3YJ/6Li1XHpUuXPt64ceOH58+f569PEFiZFay6cAkMZQWGIqCoT+qWxIBwYjGwFLhk1XepNmRuxrrTEDi2LYCuPQUoIEiVFaQEQuAoExSg+hDJzwIyUSQ73Mv9dZ2IDKITNy6+pWyrUo/aogxeQAgMZpAFhfNYFBCp9gkBwj7bpCxWVkG6dFjy+V+NP+fkWnS2WImTEd9HybN8t82+AJKsZOiPgmTgbJPaNrqhjIKLo5S1RXKWF7atEyHT04iTs3y1SW2b6mxfbZkhMLa4DgsIymjMUtuWHvHUF43jazx0NGQUaLiBWFGNiXJM7ThqZawutq3jasdRKy8ZV5+V8Y2FPDkbMoo0CsnbsVLbPrM2uFLbrj473x2L9K3jkYECnWJz3HHbt21rQvw4xy3ftqnD7Vu9ScYj8nIkwkzYSTLXlXH7CU3lBV0MBOpNIpNnP62DVlFSHUnlrG7bThpgUjmrO2yP1MlQERppdMXNSRNUmjnW/6Ad51CeYImM0dLrulEWEKzSsXK8XHbKDoAFg+3/AzG6P4gTtPU8AAAAAElFTkSuQmCC"),
                o.on(this.cursorNode, "mousedown", function (e) {
                  i._onMouseDown(e);
                }),
                o.on(this.cursorNode, "touchstart", function (e) {
                  i._onMouseDown(e);
                }),
                o.on(this.progressNode, "mousemove", function (e) {
                  i._progressMove(e);
                }),
                o.on(this.progressNode, "touchmove", function (e) {
                  i._progressMove(e);
                }),
                o.on(this._el, "click", function (e) {
                  i._onMouseClick(e);
                }),
                this._player.on(d.Private.HideProgress, function (e) {
                  i._hideProgress(e);
                }),
                this._player.on(d.Private.CancelHideProgress, function (e) {
                  i._cancelHideProgress(e);
                }),
                this._player.on(d.Private.ShowBar, function () {
                  i._updateLayout();
                }),
                o.on(this.progressNode, d.Private.MouseOver, function (e) {
                  i._onMouseOver(e);
                }),
                o.on(this.progressNode, d.Private.MouseOut, function (e) {
                  i._onMouseOut(e);
                }),
                (this.bindTimeupdate = a.bind(this, this._onTimeupdate)),
                this._player.on(d.Player.TimeUpdate, this.bindTimeupdate),
                c.isLiveShift(this._player._options) &&
                  this._player.on(d.Player.Play, function () {
                    i._liveshiftService.start(6e4, function (e) {
                      var t = {
                        mediaId: i._player._options.vid
                          ? i._player._options.vid
                          : "",
                        error_code: e.Code,
                        error_msg: e.Message,
                      };
                      i._player.logError(t),
                        i._player.trigger(d.Player.Error, t);
                    });
                  }),
                this._player.on(d.Private.LiveShiftQueryCompleted, function () {
                  i._updateSeperator(), i._updateLayout();
                }),
                this._player.on(d.Player.Pause, function () {
                  i._liveshiftService.stop();
                }),
                n.IS_IPAD
                  ? (this.interval = setInterval(function () {
                      i._onProgress();
                    }, 500))
                  : this._player.on(d.Video.Progress, function () {
                      i._onProgress();
                    });
            },
            _updateSeperator: function () {
              this._liveshiftService.currentTimeDisplay &&
                (this.seperatorNode.innerText =
                  this._liveshiftService.currentTimeDisplay);
            },
            _updateLayout: function () {
              var e = this.seperatorNode.offsetWidth,
                t = this.el().offsetWidth,
                i = t - e;
              0 != e &&
                0 != i &&
                (s.css(this.progressNode, "width", (100 * (i - 10)) / t + "%"),
                s.css(this.seperatorNode, "right", -1 * (e + 10) + "px"));
            },
            _progressMove: function (e) {
              var t = this._getSeconds(e),
                i = this._liveshiftService.availableLiveShiftTime;
              this.timeNode.innerText = "-" + l.formatTime(i - t);
              var r = i ? t / i : 0,
                o = 1 - this.timeNode.clientWidth / this.el().clientWidth;
              o < r && (r = o),
                this.timeNode && s.css(this.timeNode, "left", 100 * r + "%");
            },
            _hideProgress: function (e) {
              o.off(this.cursorNode, "mousedown"),
                o.off(this.cursorNode, "touchstart");
            },
            _cancelHideProgress: function (e) {
              var t = this;
              o.on(this.cursorNode, "mousedown", function (e) {
                t._onMouseDown(e);
              }),
                o.on(this.cursorNode, "touchstart", function (e) {
                  t._onMouseDown(e);
                });
            },
            _canSeekable: function (e) {
              var t = !0;
              return (
                "function" == typeof this._player.canSeekable &&
                  (t = this._player.canSeekable(e)),
                t
              );
            },
            _onMouseOver: function (e) {
              this._updateCursorPosition(this._getCurrentTime()),
                s.css(this.timeNode, "display", "block");
            },
            _onMouseOut: function (e) {
              s.css(this.timeNode, "display", "none");
            },
            _getSeconds: function (e) {
              for (
                var t = this.el().offsetLeft, i = this.el();
                (i = i.offsetParent);

              ) {
                var r = s.getTranslateX(i);
                t += i.offsetLeft + r;
              }
              var o = (e.touches ? e.touches[0].pageX : e.pageX) - t,
                n = this.progressNode.offsetWidth,
                a = this._liveshiftService.availableLiveShiftTime;
              return (
                (sec = a ? (o / n) * a : 0),
                sec < 0 && (sec = 0),
                sec > a && (sec = a),
                sec
              );
            },
            _onMouseClick: function (e) {
              var t = this,
                i = this._getSeconds(e),
                r = this._liveshiftService.availableLiveShiftTime - i;
              this._player.trigger(d.Private.SeekStart, {
                fromTime: this._getCurrentTime(),
              });
              var o = this._liveshiftService.getSourceUrl(r),
                n = t._player._options.source,
                a = c.isHls(t._player._options.source);
              a && o == n
                ? t._player.seek(i)
                : t._player._loadByUrlInner(o, i, !0),
                t._player.trigger(d.Private.Play_Btn_Hide),
                (t._liveshiftService.seekTime = i),
                t._player.trigger(d.Private.EndStart, { toTime: i }),
                t._updateCursorPosition(i),
                a &&
                  setTimeout(function () {
                    t._player.play();
                  });
            },
            _onMouseDown: function (e) {
              var t = this;
              e.preventDefault(),
                this._player.trigger(d.Private.SeekStart, {
                  fromTime: this._getCurrentTime(),
                }),
                o.on(this.controlNode, "mousemove", function (e) {
                  t._onMouseMove(e);
                }),
                o.on(this.controlNode, "touchmove", function (e) {
                  t._onMouseMove(e);
                }),
                o.on(this._player.tag, "mouseup", function (e) {
                  t._onMouseUp(e);
                }),
                o.on(this._player.tag, "touchend", function (e) {
                  t._onMouseUp(e);
                }),
                o.on(this.controlNode, "mouseup", function (e) {
                  t._onMouseUp(e);
                }),
                o.on(this.controlNode, "touchend", function (e) {
                  t._onMouseUp(e);
                });
            },
            _onMouseUp: function (e) {
              e.preventDefault(),
                o.off(this.controlNode, "mousemove"),
                o.off(this.controlNode, "touchmove"),
                o.off(this._player.tag, "mouseup"),
                o.off(this._player.tag, "touchend"),
                o.off(this.controlNode, "mouseup"),
                o.off(this.controlNode, "touchend");
              var t = this._liveshiftService.availableLiveShiftTime,
                i = (this.playedNode.offsetWidth / this.el().offsetWidth) * t;
              this._player.seek(i),
                this._player.trigger(d.Private.Play_Btn_Hide),
                (this._liveshiftService.seekTime = i),
                this._player.trigger(d.Private.EndStart, { toTime: i });
            },
            _onMouseMove: function (e) {
              e.preventDefault();
              var t = this._getSeconds(e);
              this._updateProgressBar(this.playedNode, t),
                this._updateCursorPosition(t);
            },
            _onTimeupdate: function (e) {
              this._updateProgressBar(this.playedNode, this._getCurrentTime()),
                this._updateCursorPosition(this._getCurrentTime()),
                this._player.trigger(d.Private.UpdateProgressBar, {
                  time: this._getCurrentTime(),
                });
            },
            _getCurrentTime: function () {
              var e = this._liveshiftService.seekTime;
              return -1 == e && (e = 0), this._player.getCurrentTime() + e;
            },
            _onProgress: function (e) {
              this._player.getDuration() &&
                1 <= this._player.getBuffered().length &&
                this._updateProgressBar(
                  this.loadedNode,
                  this._player
                    .getBuffered()
                    .end(this._player.getBuffered().length - 1)
                );
            },
            _updateProgressBar: function (e, t) {
              if (1 != this._player._switchSourcing) {
                var i = 0;
                if (-1 == this._liveshiftService.seekTime) i = 1;
                else {
                  var r = this._liveshiftService.availableLiveShiftTime;
                  1 < (i = r ? t / r : 0) &&
                    ((i = 1), (this._liveshiftService.seekTime = -1));
                }
                this.liveShiftStartDisplay;
                e && s.css(e, "width", 100 * i + "%");
              }
            },
            _updateCursorPosition: function (e) {
              if (
                this._player.el() &&
                1 != this._player._switchSourcing &&
                (0 != e || 0 != this._player.tag.readyState)
              ) {
                var t = 0,
                  i = 1,
                  r = this._player.el().clientWidth;
                if (-1 == this._liveshiftService.seekTime) t = 1;
                else {
                  var o = this._liveshiftService.availableLiveShiftTime;
                  1 < (t = o ? e / o : 0) &&
                    (this._liveshiftService.seekTime = -1);
                }
                if (0 != r) {
                  var n = 18 / r;
                  (i = 1 - n), (t -= n);
                }
                this.cursorNode &&
                  (i < t
                    ? (s.css(this.cursorNode, "right", "0px"),
                      s.css(this.cursorNode, "left", "auto"))
                    : (s.css(this.cursorNode, "right", "auto"),
                      s.css(this.cursorNode, "left", 100 * t + "%")));
              }
            },
          });
        t.exports = p;
      },
      {
        "../config": 5,
        "../lang/index": 11,
        "../lib/dom": 18,
        "../lib/event": 19,
        "../lib/function": 20,
        "../lib/playerutil": 29,
        "../lib/ua": 31,
        "../lib/util": 33,
        "../player/base/event/eventtype": 43,
        "../ui/component": 94,
      },
    ],
    4: [
      function (e, t, i) {
        var r = e("../ui/component"),
          n = e("../lib/util"),
          a = e("../player/base/event/eventtype"),
          o = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-live-time-display"),
                this.addClass(this.className),
                (this._liveshiftService = e._liveshiftService);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (
                (e.innerHTML =
                  '<span class="current-time">00:00</span> <span class="time-bound">/</span> <span class="end-time">00:00</span><span class="live-text">Live: </span><span class="live-time"></span>'),
                e
              );
            },
            bindEvent: function () {
              var o = this;
              this._player.on(a.Video.TimeUpdate, function () {
                var e = o._liveshiftService,
                  t = document.querySelector("#" + o.id() + " .current-time");
                if (
                  e.liveShiftStartDisplay &&
                  e.availableLiveShiftTime > e.seekTime &&
                  -1 != e.seekTime
                ) {
                  var i = o._liveshiftService.getBaseTime(),
                    r = n.formatTime(i + o._player.getCurrentTime());
                  t.innerText = r;
                } else e.currentTimeDisplay && (t.innerText = e.currentTimeDisplay);
              }),
                this._player.on(a.Private.LiveShiftQueryCompleted, function () {
                  o.updateTime();
                });
            },
            updateTime: function () {
              (document.querySelector(
                "#" + this.id() + " .end-time"
              ).innerText = this._liveshiftService.liveTimeRange.endDisplay),
                (document.querySelector(
                  "#" + this.id() + " .live-time"
                ).innerText = this._liveshiftService.currentTimeDisplay);
            },
          });
        t.exports = o;
      },
      {
        "../lib/util": 33,
        "../player/base/event/eventtype": 43,
        "../ui/component": 94,
      },
    ],
    5: [
      function (e, t, i) {
        t.exports = {
          domain: "g.alicdn.com",
          flashVersion: "2.8.2",
          h5Version: "2.8.2",
          cityBrain: !0,
          logDuration: 10,
          logCount: 100,
          logReportTo: "/",
        };
      },
      {},
    ],
    6: [
      function (e, t, i) {
        e("./lang/index").load();
        var r = e("./player/adaptivePlayer"),
          o = e("./lib/componentutil"),
          n = e("./config"),
          a = function (e, t) {
            return r.create(e, t);
          };
        (a.getVersion = function () {
          return n.h5Version;
        }),
          o.register(a);
        var s = (window.Aliplayer = a);
        (a.players = {}),
          "function" == typeof define && define.amd
            ? define([], function () {
                return s;
              })
            : "object" == typeof i && "object" == typeof t && (t.exports = s),
          "undefined" != typeof Uint8Array &&
            (Uint8Array.prototype.slice ||
              Object.defineProperty(Uint8Array.prototype, "slice", {
                value: Array.prototype.slice,
              }));
      },
      {
        "./config": 5,
        "./lang/index": 11,
        "./lib/componentutil": 14,
        "./player/adaptivePlayer": 40,
      },
    ],
    7: [
      function (e, t, i) {
        var r = e("../lib/oo"),
          o = e("../lang/index"),
          n = r.extend({
            init: function (e, t) {
              (this._player = e), (this._options = e.options());
            },
          });
        (n.prototype.handle = function (e) {
          if (this._options.autoPlayDelay) {
            var t = this._options.autoPlayDelayDisplayText;
            t ||
              (t = o
                .get("AutoPlayDelayDisplayText")
                .replace("$$", this._options.autoPlayDelay)),
              this._player.trigger("info_show", t),
              this._player.trigger("h5_loading_hide"),
              this._player.trigger("play_btn_hide");
            var i = this;
            (this._timeHandler = setTimeout(function () {
              i._player.trigger("info_hide"),
                (i._options.autoPlayDelay = 0),
                e && e();
            }, 1e3 * this._options.autoPlayDelay)),
              this._player.on("play", function () {
                a(i);
              }),
              this._player.on("pause", function () {
                a(i);
              });
          }
        }),
          (n.prototype.dispose = function () {
            a(this), (this._player = null);
          });
        var a = function (e) {
          e._timeHandler &&
            (clearTimeout(e._timeHandler), (e._timeHandler = null));
        };
        t.exports = n;
      },
      { "../lang/index": 11, "../lib/oo": 27 },
    ],
    8: [
      function (e, t, i) {
        t.exports = t.exports = {
          OD: "OD",
          FD: "360p",
          LD: "540p",
          SD: "720p",
          HD: "1080p",
          "2K": "2K",
          "4K": "4K",
          FHD: "FHD",
          XLD: "XLD",
          SQ: "SQ",
          HQ: "HQ",
          Speed: "Speed",
          Speed_05X_Text: "0.5X",
          Speed_1X_Text: "Normal",
          Speed_125X_Text: "1.25X",
          Speed_15X_Text: "1.5X",
          Speed_2X_Text: "2X",
          Refresh_Text: "Refresh",
          Cancel: "Cancel",
          Mute: "Mute",
          Snapshot: "Snapshot",
          Detection_Text: "Diagnosis",
          Play_DateTime: "Time",
          Quality_Change_Fail_Switch_Text: "Cannot play, switch to ",
          Quality_Change_Text: "Switch to ",
          Quality_The_Url: "The url",
          AutoPlayDelayDisplayText: "Play in $$ seconds",
          Error_Load_Abort_Text: "Data abort erro",
          Error_Network_Text: "Loading failed due to network error",
          Error_Decode_Text: "Decode error",
          Error_Server_Network_NotSupport_Text:
            "Network error or \xa0the format of video is unsupported",
          Error_Offline_Text:
            "The network is unreachable, please click Refresh",
          Error_Play_Text: "Error occured while playing",
          Error_Retry_Text: " Please close or refresh",
          Error_AuthKey_Text:
            "Authentication expired or the domain is not in white list",
          Error_H5_Not_Support_Text:
            "The format of video is not supported by\xa0h5 player\uff0cplease use flash player",
          Error_Not_Support_M3U8_Text:
            "The format of m3u8 is not supported by this explorer",
          Error_Not_Support_MP4_Text:
            "The format of mp4\xa0is not supported by this explorer",
          Error_Not_Support_encrypt_Text:
            "Play the encrypted video,please set encryptType to 1",
          Error_Vod_URL_Is_Empty_Text: "The url is empty",
          Error_Vod_Fetch_Urls_Text:
            "Error occured when fetch urls\uff0cplease close or refresh",
          Fetch_Playauth_Error:
            "Error occured when fetch playauth close or refresh",
          Error_Playauth_Decode_Text: "PlayAuth parse failed",
          Error_Vid_Not_Same_Text: "Cannot renew url due to vid changed",
          Error_Playauth_Expired_Text:
            "Playauth expired, please close or refresh",
          Error_MTS_Fetch_Urls_Text:
            "Error occurred while requesting mst server",
          Error_Load_M3U8_Failed_Text: "The\xa0m3u8 file loaded failed",
          Error_Load_M3U8_Timeout_Text:
            "Timeout error occored\xa0when the\xa0m3u8 file loaded",
          Error_M3U8_Decode_Text: "The m3u8 file decoded failed",
          Error_TX_Decode_Text: "Video decoded failed",
          Error_Waiting_Timeout_Text:
            "Buffering timeout,\xa0please close or refresh",
          Error_Invalidate_Source:
            "Video shoud be mp4\u3001mp3\u3001m3u8\u3001mpd or flv",
          Error_Empty_Source: "Video URL shouldn't be empty",
          Error_Vid_Empty_Source: "vid's video URL hasn't been fetched",
          Error_Fetch_NotStream: "The vid has no stream to play",
          Error_Not_Found: "Url is not found",
          Live_End: "Live has finished",
          Play_Before_Fullscreen: "Please play before fullscreen",
          Can_Not_Seekable: "Can not seek to this position",
          Cancel_Text: "Cancel",
          OK_Text: "OK",
          Auto_Stream_Tip_Text: "Internet is slow, does switch to $$",
          Request_Block_Text:
            "This request is blocked, the video Url should be over https",
          Open_Html_By_File: "Html page should be on the server",
          Maybe_Cors_Error:
            "please make sure enable cors,<a href='https://help.aliyun.com/document_detail/62950.html?spm=a2c4g.11186623.2.21.Y3n2oi' target='_blank'>refer to document</a>",
          Speed_Switch_To: "Speed switch to ",
          Curent_Volume: "Current volume:",
          Volume_Mute: "set to mute",
          Volume_UnMute: "set to unmute",
          ShiftLiveTime_Error:
            "Live start time should not be greater than over time",
          Error_Not_Support_Format_On_Mobile:
            "flv\u3001rmtp can't be supported on mobile\uff0cplease use m3u8",
          SessionId_Ticket_Invalid:
            "please assign value for sessionId and ticket properties",
          Http_Error:
            " An HTTP network request failed with an error, but not from the server.",
          Http_Timeout: "A network request timed out",
          DRM_License_Expired: "DRM license is expired, please refresh",
          Not_Support_DRM: "Browser doesn't support DRM",
          CC_Switch_To: "Subtitle switch to ",
          AudioTrack_Switch_To: "Audio tracks switch to ",
          Subtitle: "Subtitle/CC",
          AudioTrack: "Audio Track",
          Quality: "Quality",
          Auto: "Auto",
          Quality_Switch_To: "Quality switch to ",
          Fullscreen: "Full Screen",
          Setting: "Settings",
          Volume: "Volume",
          Play: "Play",
          Pause: "Pause",
          CloseSubtitle: "Close CC",
          OpenSubtitle: "Open CC",
          ExistFullScreen: "Exit Full Screen",
          Muted: "Muted",
          Retry: "Retry",
          SwitchToLive: "Return to live",
          iOSNotSupportVodEncription:
            "iOS desn't suport Vod's encription video",
          UseChromeForVodEncription:
            "This browser desn't suport Vod's encription video, please use latest Chrome",
        };
      },
      {},
    ],
    9: [
      function (e, t, i) {
        t.exports = t.exports = {
          OD: "OD",
          LD: "360p",
          FD: "540p",
          SD: "720p",
          HD: "1080p",
          "2K": "2K",
          "4K": "4K",
          FHD: "FHD",
          XLD: "XLD",
          SQ: "SQ",
          HQ: "HQ",
          Forbidden_Text:
            "Internal information is strictly forbidden to outsider",
          Refresh: "Refresh",
          Diagnosis: "Diagnosis",
          Live_Finished: "Live has finished, thanks for watching",
          Play: "Play",
          Pause: "Pause",
          Snapshot: "Snapshot",
          Replay: "Replay",
          Live: "Live",
          Encrypt: "Encrypt",
          Sound: "Sound",
          Fullscreen: "Full Screen",
          Exist_Fullscreen: "Exit Full-screen",
          Resolution: "Resolution",
          Next: "Next Video",
          Brightness: "Brightness",
          Default: "Default",
          Contrast: "Contrast",
          Titles_Credits: "Titles\xa0and\xa0Credits",
          Skip_Titles: "Skip Titles",
          Skip_Credits: "Skip Credits",
          Not_Support_Out_Site:
            "The video is not supported for outside website, please watch it by TaoTV",
          Watch_Now: "Watch now",
          Network_Error: "Network is unreachable, please try to refresh",
          Video_Error: "Playing a video error,\xa0please try to refresh",
          Decode_Error: "Data decoding\xa0error",
          Live_Not_Start: "Live has not started, to be expected",
          Live_Loading: "Live information is loading,\xa0please try to refresh",
          Fetch_Playauth_Error:
            "Error occured when fetch playauth close or refresh",
          Live_End: "Live has finished",
          Live_Abrot: "Signal aborted,\xa0please try to refresh",
          Corss_Domain_Error:
            "Please ensure your domain has obtained IPC license and combined CNAME, \r\n or to set\xa0\xa0cross-domain accessing available",
          Url_Timeout_Error:
            "The video url is timeout,\xa0please try to refresh",
          Connetction_Error:
            "Sorry\uff0cthe video cannot play because of connection error, please try to watch other videos",
          Fetch_MTS_Error: "Fetching video list failed, please ensure",
          Token_Expired_Error:
            "Requesting open api failed, please ensure token expired or not",
          Video_Lists_Empty_Error:
            "The video list is empty, please check the format of video",
          Encrypted_Failed_Error:
            "Fetching encrypted file failed, please check the permission of player",
          Fetch_Failed_Permission_Error:
            "Fetching video list failed, please check the permission of player",
          Invalidate_Param_Error: "No video url, please check the parameters",
          AutoPlayDelayDisplayText: "Play in $$ seconds",
          Fetch_MTS_NOT_NotStream_Error: "The vid has no stream to play",
          Cancel_Text: "Cancel",
          OK_Text: "OK",
          Auto_Stream_Tip_Text: "Internet is slow, does switch to $$",
          Open_Html_By_File: "Html page should be on the server",
          Cant_Use_Flash_On_Mobile:
            "Mobile doesn't support flash player\uff0cplease use h5 player",
          Flash_Not_Ready:
            "Flash Player plugin hasn't been installed <a href='https://www.flash.cn/' target='_blank'>install plugin</a>, or check if disable Flash plugin",
        };
      },
      {},
    ],
    10: [
      function (e, t, i) {
        t.exports = t.exports = {
          OD: "\u539f\u753b",
          FD: "\u6d41\u7545",
          LD: "\u6807\u6e05",
          SD: "\u9ad8\u6e05",
          HD: "\u8d85\u6e05",
          "2K": "2K",
          "4K": "4K",
          FHD: "\u5168\u9ad8\u6e05",
          XLD: "\u6781\u901f",
          SQ: "\u666e\u901a\u97f3\u8d28",
          HQ: "\u9ad8\u97f3\u8d28",
          Forbidden_Text:
            "\u5185\u90e8\u4fe1\u606f\uff0c\u4e25\u7981\u5916\u4f20",
          Refresh: "\u5237\u65b0",
          Diagnosis: "\u8bca\u65ad",
          Live_Finished:
            "\u76f4\u64ad\u5df2\u7ed3\u675f,\u8c22\u8c22\u89c2\u770b",
          Play: "\u64ad\u653e",
          Pause: "\u6682\u505c",
          Snapshot: "\u622a\u56fe",
          Replay: "\u91cd\u64ad",
          Live: "\u76f4\u64ad",
          Encrypt: "\u52a0\u5bc6",
          Sound: "\u58f0\u97f3",
          Fullscreen: "\u5168\u5c4f",
          Exist_Fullscreen: "\u9000\u51fa\u5168\u5c4f",
          Resolution: "\u6e05\u6670\u5ea6",
          Next: "\u4e0b\u4e00\u96c6",
          Brightness: "\u4eae\u5ea6",
          Default: "\u9ed8\u8ba4",
          Contrast: "\u5bf9\u6bd4\u5ea6",
          Titles_Credits: "\u7247\u5934\u7247\u5c3e",
          Skip_Titles: "\u8df3\u8fc7\u7247\u5934",
          Skip_Credits: "\u8df3\u8fc7\u7247\u5c3e",
          Not_Support_Out_Site:
            "\u8be5\u89c6\u9891\u6682\u4e0d\u652f\u6301\u7ad9\u5916\u64ad\u653e\uff0c\u8bf7\u5230\u6dd8TV\u89c2\u770b",
          Watch_Now: "\u7acb\u5373\u89c2\u770b",
          Network_Error:
            "\u7f51\u7edc\u65e0\u6cd5\u8fde\u63a5\uff0c\u8bf7\u5c1d\u8bd5\u68c0\u67e5\u7f51\u7edc\u540e\u5237\u65b0\u8bd5\u8bd5",
          Video_Error:
            "\u89c6\u9891\u64ad\u653e\u5f02\u5e38\uff0c\u8bf7\u5237\u65b0\u8bd5\u8bd5",
          Decode_Error: "\u64ad\u653e\u6570\u636e\u89e3\u7801\u9519\u8bef",
          Live_Not_Start:
            "\u4eb2\uff0c\u76f4\u64ad\u8fd8\u672a\u5f00\u59cb\u54e6\uff0c\u656c\u8bf7\u671f\u5f85",
          Live_Loading:
            "\u76f4\u64ad\u4fe1\u606f\u52a0\u8f7d\u4e2d\uff0c\u8bf7\u5237\u65b0\u8bd5\u8bd5",
          Live_End: "\u4eb2\uff0c\u76f4\u64ad\u5df2\u7ed3\u675f",
          Live_Abrot:
            "\u5f53\u524d\u76f4\u64ad\u4fe1\u53f7\u4e2d\u65ad\uff0c\u8bf7\u5237\u65b0\u540e\u91cd\u8bd5",
          Corss_Domain_Error:
            "\u8bf7\u786e\u8ba4\u60a8\u7684\u57df\u540d\u5df2\u5b8c\u6210\u5907\u6848\u548cCNAME\u7ed1\u5b9a\uff0c\r\n\u5e76\u5904\u4e8e\u542f\u7528\u72b6\u6001\uff0c\u6216\u8d44\u6e90\u5141\u8bb8\u8de8\u8d8a\u8bbf\u95ee",
          Url_Timeout_Error:
            "\u60a8\u6240\u89c2\u770b\u7684\u89c6\u9891\u5730\u5740\u8fde\u63a5\u8d85\u65f6\uff0c\u8bf7\u5237\u65b0\u540e\u91cd\u8bd5",
          Connetction_Error:
            "\u62b1\u6b49,\u8be5\u89c6\u9891\u7531\u4e8e\u8fde\u63a5\u9519\u8bef\u6682\u65f6\u4e0d\u80fd\u64ad\u653e,\u8bf7\u89c2\u770b\u5176\u5b83\u89c6\u9891",
          Fetch_MTS_Error:
            "\u83b7\u53d6\u89c6\u9891\u5217\u8868\u5931\u8d25\uff0c\u8bf7\u786e\u8ba4",
          Token_Expired_Error:
            "\u8bf7\u6c42\u63a5\u53e3\u5931\u8d25\uff0c\u8bf7\u786e\u8ba4Token\u662f\u5426\u8fc7\u671f",
          Video_Lists_Empty_Error:
            "\u83b7\u53d6\u89c6\u9891\u5217\u8868\u4e3a\u7a7a\uff0c\u8bf7\u786e\u8ba4\u64ad\u653e\u6570\u636e\u4e0e\u683c\u5f0f",
          Encrypted_Failed_Error:
            "\u83b7\u53d6\u89c6\u9891\u52a0\u5bc6\u79d8\u94a5\u9519\u8bef\uff0c\u8bf7\u786e\u8ba4\u64ad\u653e\u6743\u9650",
          Fetch_Failed_Permission_Error:
            "\u83b7\u53d6\u89c6\u9891\u5217\u8868\u5931\u8d25\uff0c\u8bf7\u786e\u8ba4\u64ad\u653e\u6743\u9650",
          Invalidate_Param_Error:
            "\u65e0\u8f93\u5165\u89c6\u9891\uff0c\u8bf7\u786e\u8ba4\u8f93\u5165\u53c2\u6570",
          AutoPlayDelayDisplayText:
            "$$\u79d2\u4ee5\u540e\u5f00\u59cb\u64ad\u653e",
          Fetch_MTS_NOT_NotStream_Error:
            "\u6b64vid\u6ca1\u6709\u53ef\u64ad\u653e\u89c6\u9891",
          Cancel_Text: "\u53d6\u6d88",
          OK_Text: "\u786e\u8ba4",
          Auto_Stream_Tip_Text:
            "\u7f51\u7edc\u4e0d\u7ed9\u529b\uff0c\u662f\u5426\u5207\u6362\u5230$$",
          Fetch_Playauth_Error:
            "\u83b7\u53d6\u64ad\u653e\u51ed\u8bc1\u51fa\u9519\u5566\uff0c\u8bf7\u5c1d\u8bd5\u9000\u51fa\u91cd\u8bd5\u6216\u5237\u65b0",
          Open_Html_By_File:
            "\u4e0d\u80fd\u76f4\u63a5\u5728\u6d4f\u89c8\u5668\u6253\u5f00html\u6587\u4ef6\uff0c\u8bf7\u90e8\u7f72\u5230\u670d\u52a1\u7aef",
          Cant_Use_Flash_On_Mobile:
            "\u79fb\u52a8\u7aef\u4e0d\u652f\u6301Flash\u64ad\u653e\u5668\uff0c\u8bf7\u4f7f\u7528h5\u64ad\u653e\u5668",
          Flash_Not_Ready:
            "Flash Player\u63d2\u4ef6\u672a\u5b89\u88c5<a href='https://www.flash.cn/' target='_blank'>\u5b89\u88c5\u63d2\u4ef6</a>\uff0c\u5982\u679c\u5df2\u7ecf\u5b89\u88c5\u8bf7\u68c0\u67e5\u662f\u5426\u88ab\u7981\u7528",
        };
      },
      {},
    ],
    11: [
      function (n, e, t) {
        var i = n("../config"),
          a = n("../lib/storage"),
          o = (n("../lib/io"), "aliplayer_lang"),
          s = function () {
            if (void 0 === window[o] || !window[o]) {
              var e = (
                navigator.language || navigator.browserLanguage
              ).toLowerCase();
              (e = e && -1 < e.indexOf("zh") ? "zh-cn" : "en-us"),
                (window[o] = e);
            }
            return window[o];
          },
          l = function (e, t) {
            var i = d(e),
              r = "",
              o = c();
            (r =
              "flash" == e
                ? "en-us" == o
                  ? n("./flash/en-us")
                  : "zh-cn" == o
                  ? n("./flash/zh-cn")
                  : t[o]
                : "en-us" == o
                ? n("./en-us")
                : "zh-cn" == o
                ? n("./zh-cn")
                : t[o]),
              a.set(i, JSON.stringify(r)),
              u(e, r);
          },
          u = function (e, t) {
            var i = d(e);
            window[i] = t;
          },
          c = function () {
            return s();
          },
          d = function (e) {
            var t = c();
            return (
              e || (e = "h5"),
              "aliplayer_lang_data_" +
                e +
                "_" +
                i.h5Version.replace(/\./g, "_") +
                "_" +
                t
            );
          };
        (e.exports.setCurrentLanguage = function (e, t, i) {
          var r = window[o];
          if (
            ((void 0 !== e && e) || (e = s()),
            "en-us" != e && "zh-cn" != e && (!i || (i && !i[e])))
          )
            throw new Error(
              "There is not language resource for " +
                e +
                ", please specify the language resource by languageTexts property"
            );
          (window[o] = e),
            l(t, i),
            e != r && n("../lib/constants").updateByLanguage();
        }),
          (e.exports.getCurrentLanguage = s),
          (e.exports.getLanguageData = function (e, t) {
            var i = d(e);
            return window[i];
          }),
          (e.exports.load = l),
          (e.exports.get = function (e, t) {
            t || (t = "h5");
            var i = d(t),
              r = window[i];
            if (r) return r[e];
          });
      },
      {
        "../config": 5,
        "../lib/constants": 15,
        "../lib/io": 24,
        "../lib/storage": 30,
        "./en-us": 8,
        "./flash/en-us": 9,
        "./flash/zh-cn": 10,
        "./zh-cn": 12,
      },
    ],
    12: [
      function (e, t, i) {
        t.exports = t.exports = {
          OD: "\u539f\u753b",
          FD: "\u6d41\u7545",
          LD: "\u6807\u6e05",
          SD: "\u9ad8\u6e05",
          HD: "\u8d85\u6e05",
          "2K": "2K",
          "4K": "4K",
          FHD: "\u5168\u9ad8\u6e05",
          XLD: "\u6781\u901f",
          SQ: "\u666e\u901a\u97f3\u8d28",
          HQ: "\u9ad8\u97f3\u8d28",
          Speed: "\u500d\u901f",
          Speed_05X_Text: "0.5X",
          Speed_1X_Text: "\u6b63\u5e38",
          Speed_125X_Text: "1.25X",
          Speed_15X_Text: "1.5X",
          Speed_2X_Text: "2X",
          Quality_Change_Fail_Switch_Text:
            "\u4e0d\u80fd\u64ad\u653e\uff0c\u5207\u6362\u4e3a",
          Quality_Change_Text: "\u6b63\u5728\u4e3a\u60a8\u5207\u6362\u5230 ",
          Quality_The_Url: "\u6b64\u5730\u5740",
          Refresh_Text: "\u5237\u65b0",
          Detection_Text: "\u8bca\u65ad",
          Cancel: "\u53d6\u6d88",
          Mute: "\u9759\u97f3",
          Snapshot: "\u622a\u56fe",
          Play_DateTime: "\u64ad\u653e\u65f6\u95f4",
          AutoPlayDelayDisplayText:
            "$$\u79d2\u4ee5\u540e\u5f00\u59cb\u64ad\u653e",
          Error_Load_Abort_Text:
            "\u83b7\u53d6\u6570\u636e\u8fc7\u7a0b\u88ab\u4e2d\u6b62",
          Error_Network_Text:
            "\u7f51\u7edc\u9519\u8bef\u52a0\u8f7d\u6570\u636e\u5931\u8d25",
          Error_Decode_Text: "\u89e3\u7801\u9519\u8bef",
          Error_Server_Network_NotSupport_Text:
            "\u670d\u52a1\u5668\u3001\u7f51\u7edc\u9519\u8bef\u6216\u683c\u5f0f\u4e0d\u652f\u6301",
          Error_Offline_Text:
            "\u7f51\u7edc\u4e0d\u53ef\u7528\uff0c\u8bf7\u786e\u5b9a",
          Error_Play_Text: "\u64ad\u653e\u51fa\u9519\u5566",
          Error_Retry_Text:
            "\u8bf7\u5c1d\u8bd5\u9000\u51fa\u91cd\u8bd5\u6216\u5237\u65b0",
          Error_AuthKey_Text:
            "\u53ef\u80fd\u9274\u6743\u8fc7\u671f\u3001\u57df\u540d\u4e0d\u5728\u767d\u540d\u5355\u6216\u8bf7\u6c42\u88ab\u62e6\u622a",
          Error_H5_Not_Support_Text:
            "h5\u4e0d\u652f\u6301\u6b64\u683c\u5f0f\uff0c\u8bf7\u4f7f\u7528flash\u64ad\u653e\u5668",
          Error_Not_Support_M3U8_Text:
            "\u6d4f\u89c8\u5668\u4e0d\u652f\u6301m3u8\u89c6\u9891\u64ad\u653e",
          Error_Not_Support_MP4_Text:
            "\u6d4f\u89c8\u5668\u4e0d\u652f\u6301mp4\u89c6\u9891\u64ad\u653e",
          Error_Not_Support_encrypt_Text:
            "\u64ad\u653e\u52a0\u5bc6\u89c6\u9891\uff0c\u8bf7\u8bbe\u7f6e\u5c5e\u6027encryptType to 1",
          Error_Vod_URL_Is_Empty_Text:
            "\u83b7\u53d6\u64ad\u653e\u5730\u5740\u4e3a\u7a7a",
          Error_Vod_Fetch_Urls_Text:
            "\u83b7\u53d6\u5730\u5740\u51fa\u9519\u5566\uff0c\u8bf7\u5c1d\u8bd5\u9000\u51fa\u91cd\u8bd5\u6216\u5237\u65b0",
          Fetch_Playauth_Error:
            "\u83b7\u53d6\u64ad\u653e\u51ed\u8bc1\u51fa\u9519\u5566\uff0c\u8bf7\u5c1d\u8bd5\u9000\u51fa\u91cd\u8bd5\u6216\u5237\u65b0",
          Error_Playauth_Decode_Text: "playauth\u89e3\u6790\u9519\u8bef",
          Error_Vid_Not_Same_Text:
            "\u4e0d\u80fd\u66f4\u65b0\u5730\u5740\uff0cvid\u548c\u64ad\u653e\u4e2d\u7684\u4e0d\u4e00\u81f4",
          Error_Playauth_Expired_Text:
            "\u51ed\u8bc1\u5df2\u8fc7\u671f\uff0c\u8bf7\u5c1d\u8bd5\u9000\u51fa\u91cd\u8bd5\u6216\u5237\u65b0",
          Error_MTS_Fetch_Urls_Text: "MTS\u83b7\u53d6\u53d6\u6570\u5931\u8d25",
          Error_Load_M3U8_Failed_Text:
            "\u83b7\u53d6m3u8\u6587\u4ef6\u5931\u8d25",
          Error_Load_M3U8_Timeout_Text:
            "\u83b7\u53d6m3u8\u6587\u4ef6\u8d85\u65f6",
          Error_M3U8_Decode_Text:
            "\u83b7\u53d6m3u8\u6587\u4ef6\u89e3\u6790\u5931\u8d25",
          Error_TX_Decode_Text: "\u89e3\u6790\u6570\u636e\u51fa\u9519",
          Error_Waiting_Timeout_Text:
            "\u7f13\u51b2\u6570\u636e\u8d85\u65f6\uff0c\u8bf7\u5c1d\u8bd5\u9000\u51fa\u91cd\u8bd5\u6216\u5237\u65b0",
          Error_Invalidate_Source:
            "\u64ad\u653e\u5730\u5740\u683c\u5f0f\u9700\u8981\u4e3amp4\u3001mp3\u3001m3u8\u3001mpd\u6216flv",
          Error_Empty_Source:
            "\u64ad\u653e\u5730\u5740\u4e0d\u80fd\u4e3a\u7a7a",
          Error_Vid_Empty_Source:
            "vid\u5bf9\u5e94\u7684\u89c6\u9891\u5730\u5740\u8fd8\u672a\u83b7\u53d6\u5230",
          Error_Fetch_NotStream:
            "\u6b64vid\u6ca1\u6709\u53ef\u64ad\u653e\u89c6\u9891",
          Error_Not_Found: "\u64ad\u653e\u5730\u5740\u4e0d\u5b58\u5728",
          Live_End: "\u4eb2\uff0c\u76f4\u64ad\u5df2\u7ed3\u675f",
          Play_Before_Fullscreen: "\u64ad\u653e\u540e\u518d\u5168\u5c4f",
          Can_Not_Seekable: "\u4e0d\u80fdseek\u5230\u8fd9\u91cc",
          Cancel_Text: "\u53d6\u6d88",
          OK_Text: "\u786e\u8ba4",
          Auto_Stream_Tip_Text:
            "\u7f51\u7edc\u4e0d\u7ed9\u529b\uff0c\u662f\u5426\u5207\u6362\u5230$$",
          Request_Block_Text:
            "\u6d4f\u89c8\u5668\u5b89\u5168\u7b56\u7565\u89c6\u9891\u5730\u5740\u4e0d\u80fd\u4e3ahttp\u534f\u8bae\uff0c\u4e0e\u7f51\u7ad9https\u534f\u8bae\u4e0d\u4e00\u81f4",
          Open_Html_By_File:
            "\u4e0d\u80fd\u76f4\u63a5\u5728\u6d4f\u89c8\u5668\u6253\u5f00html\u6587\u4ef6\uff0c\u8bf7\u90e8\u7f72\u5230\u670d\u52a1\u7aef",
          Maybe_Cors_Error:
            "\u8bf7\u786e\u8ba4\u662f\u5426\u5f00\u542f\u4e86\u5141\u8bb8\u8de8\u57df\u8bbf\u95ee<a href='https://help.aliyun.com/document_detail/62950.html' target='_blank'>\u53c2\u8003\u6587\u6863</a>",
          Speed_Switch_To: "\u500d\u901f\u5207\u6362\u5230 ",
          Curent_Volume: "\u5f53\u524d\u97f3\u91cf\uff1a",
          Volume_Mute: "\u8bbe\u7f6e\u4e3a\u9759\u97f3",
          Volume_UnMute: "\u8bbe\u7f6e\u4e3a\u975e\u9759\u97f3",
          ShiftLiveTime_Error:
            "\u76f4\u64ad\u5f00\u59cb\u65f6\u95f4\u4e0d\u80fd\u5927\u4e8e\u76f4\u64ad\u7ed3\u675f\u65f6\u95f4",
          Error_Not_Support_Format_On_Mobile:
            "\u79fb\u52a8\u7aef\u4e0d\u652f\u6301flv\u3001rmtp\u89c6\u9891\uff0c\u8bf7\u4f7f\u7528m3u8",
          SessionId_Ticket_Invalid:
            "DRM\u89c6\u9891\u64ad\u653e\uff0csessionId\u548cticket\u5c5e\u6027\u4e0d\u80fd\u4e3a\u7a7a",
          Http_Error: "Http\u7f51\u7edc\u8bf7\u6c42\u5931\u8d25",
          Http_Timeout: "http\u8bf7\u6c42\u8d85\u65f6",
          DRM_License_Expired:
            "DRM license\u8d85\u65f6\uff0c\u8bf7\u5237\u65b0",
          Not_Support_DRM:
            "\u6d4f\u89c8\u5668\u4e0d\u652f\u6301DRM\u89c6\u9891\u7684\u64ad\u653e",
          CC_Switch_To: "\u5b57\u5e55\u5207\u6362\u5230 ",
          AudioTrack_Switch_To: "\u97f3\u8f68\u5207\u6362\u5230 ",
          Subtitle: "\u5b57\u5e55",
          AudioTrack: "\u97f3\u8f68",
          Quality: "\u6e05\u6670\u5ea6",
          Auto: "\u81ea\u52a8",
          Quality_Switch_To: "\u6e05\u6670\u5ea6\u5207\u6362\u5230 ",
          Fullscreen: "\u5168\u5c4f",
          Setting: "\u8bbe\u7f6e",
          Volume: "\u97f3\u91cf",
          Play: "\u64ad\u653e",
          Pause: "\u6682\u505c",
          CloseSubtitle: "\u5173\u95ed\u5b57\u5e55",
          OpenSubtitle: "\u6253\u5f00\u5b57\u5e55",
          ExistFullScreen: "\u9000\u51fa\u5168\u5c4f",
          Muted: "\u9759\u97f3",
          Retry: "\u91cd\u8bd5",
          SwitchToLive: "\u8fd4\u56de\u76f4\u64ad",
          iOSNotSupportVodEncription:
            "iOS\u4e0d\u652f\u6301\u70b9\u64ad\u52a0\u5bc6\u64ad\u653e",
          UseChromeForVodEncription:
            "\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u70b9\u64ad\u52a0\u5bc6\u64ad\u653e\uff0c\u8bf7\u4f7f\u7528\u6700\u65b0Chrome\u6d4f\u89c8\u5668",
        };
      },
      {},
    ],
    13: [
      function (e, t, i) {
        var n =
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        if (window.Uint8Array)
          for (var d = new Uint8Array(256), r = 0; r < n.length; r++)
            d[n.charCodeAt(r)] = r;
        var u = function (e) {
          for (var t = "", i = 0; i < e.length; i += 16e3) {
            var r = e.subarray(i, i + 16e3);
            t += String.fromCharCode.apply(null, r);
          }
          return t;
        };
        (unpackPlayReady = function (e) {
          var t = (function (e, t, i) {
            if (!e) return "";
            var r;
            if (
              (i ||
                e.byteLength % 2 == 0 ||
                console.log("Data has an incorrect length, must be even."),
              e instanceof ArrayBuffer)
            )
              r = e;
            else {
              var o = new Uint8Array(e.byteLength);
              o.set(new Uint8Array(e)), (r = o.buffer);
            }
            for (
              var n = Math.floor(e.byteLength / 2),
                a = new Uint16Array(n),
                s = new DataView(r),
                l = 0;
              l < n;
              l++
            )
              a[l] = s.getUint16(2 * l, t);
            return u(a);
          })(e, !0, !0);
          if (-1 != t.indexOf("PlayReadyKeyMessage")) {
            for (
              var i = new DOMParser().parseFromString(t, "application/xml"),
                r = i.getElementsByTagName("HttpHeader"),
                o = {},
                n = 0;
              n < r.length;
              ++n
            ) {
              var a = r[n].querySelector("name"),
                s = r[n].querySelector("value");
              o[a.textContent] = s.textContent;
            }
            return {
              header: o,
              changange: i.querySelector("Challenge").textContent,
            };
          }
          console.log("PlayReady request is already unwrapped.");
        }),
          (t.exports = {
            decode: function (e) {
              var t,
                i,
                r,
                o,
                n,
                a = 0.75 * e.length,
                s = e.length,
                l = 0;
              "=" === e[e.length - 1] && (a--, "=" === e[e.length - 2] && a--);
              var u = new ArrayBuffer(a),
                c = new Uint8Array(u);
              for (t = 0; t < s; t += 4)
                (i = d[e.charCodeAt(t)]),
                  (r = d[e.charCodeAt(t + 1)]),
                  (o = d[e.charCodeAt(t + 2)]),
                  (n = d[e.charCodeAt(t + 3)]),
                  (c[l++] = (i << 2) | (r >> 4)),
                  (c[l++] = ((15 & r) << 4) | (o >> 2)),
                  (c[l++] = ((3 & o) << 6) | (63 & n));
              return u;
            },
            encode: function (e) {
              var t,
                i = new Uint8Array(e),
                r = i.length,
                o = "";
              for (t = 0; t < r; t += 3)
                (o += n[i[t] >> 2]),
                  (o += n[((3 & i[t]) << 4) | (i[t + 1] >> 4)]),
                  (o += n[((15 & i[t + 1]) << 2) | (i[t + 2] >> 6)]),
                  (o += n[63 & i[t + 2]]);
              return (
                r % 3 == 2
                  ? (o = o.substring(0, o.length - 1) + "=")
                  : r % 3 == 1 && (o = o.substring(0, o.length - 2) + "=="),
                o
              );
            },
            unpackPlayReady: unpackPlayReady,
          });
      },
      {},
    ],
    14: [
      function (e, t, i) {
        var r = e("./oo"),
          o = e("../player/base/event/eventtype");
        (t.exports.stopPropagation = function (e) {
          window.event ? (window.event.cancelBubble = !0) : e.stopPropagation();
        }),
          (t.exports.register = function (e) {
            (e.util = { stopPropagation: t.exports.stopPropagation }),
              (e.Component = r.extend),
              (e.EventType = o.Player);
          });
      },
      { "../player/base/event/eventtype": 43, "./oo": 27 },
    ],
    15: [
      function (e, t, i) {
        var r = e("../lang/index");
        (t.exports.LOAD_START = "loadstart"),
          (t.exports.LOADED_METADATA = "loadedmetadata"),
          (t.exports.LOADED_DATA = "loadeddata"),
          (t.exports.PROGRESS = "progress"),
          (t.exports.CAN_PLAY = "canplay"),
          (t.exports.CAN_PLYA_THROUGH = "canplaythrough"),
          (t.exports.PLAY = "play"),
          (t.exports.PAUSE = "pause"),
          (t.exports.ENDED = "ended"),
          (t.exports.PLAYING = "playing"),
          (t.exports.WAITING = "waiting"),
          (t.exports.ERROR = "error"),
          (t.exports.SUSPEND = "suspend"),
          (t.exports.STALLED = "stalled"),
          (t.exports.AuthKeyExpiredEvent = "authkeyexpired"),
          (t.exports.DRMKeySystem = {
            4: "com.microsoft.playready",
            5: "com.widevine.alpha",
          }),
          (t.exports.EncryptionType = {
            Private: 1,
            Standard: 2,
            ChinaDRM: 3,
            PlayReady: 4,
            Widevine: 5,
          }),
          (t.exports.VodEncryptionType = {
            AliyunVoDEncryption: 1,
            HLSEncryption: 2,
          }),
          (t.exports.DRMType = {
            Widevine: "Widevine",
            PlayReady: "PlayReady",
          }),
          (t.exports.ErrorCode = {
            InvalidParameter: 4001,
            AuthKeyExpired: 4002,
            InvalidSourceURL: 4003,
            NotFoundSourceURL: 4004,
            StartLoadData: 4005,
            LoadedMetadata: 4006,
            PlayingError: 4007,
            LoadingTimeout: 4008,
            RequestDataError: 4009,
            EncrptyVideoNotSupport: 4010,
            FormatNotSupport: 4011,
            PlayauthDecode: 4012,
            PlayDataDecode: 4013,
            NetworkUnavaiable: 4014,
            UserAbort: 4015,
            NetworkError: 4016,
            URLsIsEmpty: 4017,
            CrossDomain: 4027,
            OtherError: 4400,
            ServerAPIError: 4500,
            FlashNotInstalled: 4600,
          }),
          (t.exports.AuthKeyExpired = 7200),
          (t.exports.AuthKeyRefreshExpired = 7e3),
          (t.exports.AuthInfoExpired = 100),
          (t.exports.VideoErrorCode = { 1: 4015, 2: 4016, 3: 4013, 4: 4400 }),
          (t.exports.IconType = {
            FontClass: "fontclass",
            Symbol: "symbol",
            Sprite: "Sprite",
          }),
          (t.exports.SelectedStreamLevel = "selectedStreamLevel"),
          (t.exports.SelectedCC = "selectedCC"),
          (t.exports.WidthMapToLevel = {
            0: "OD",
            640: "FD",
            960: "LD",
            1280: "SD",
            1920: "HD",
            2580: "2K",
            3840: "4K",
          });
        var o = function () {
          (t.exports.VideoErrorCodeText = {
            1: r.get("Error_Load_Abort_Text"),
            2: r.get("Error_Network_Text"),
            3: r.get("Error_Decode_Text"),
            4: r.get("Error_Server_Network_NotSupport_Text"),
          }),
            (t.exports.VideoLevels = {
              0: r.get("OD"),
              640: r.get("FD"),
              960: r.get("LD"),
              1280: r.get("SD"),
              1920: r.get("HD"),
              2580: r.get("2K"),
              3840: r.get("4K"),
            }),
            (t.exports.QualityLevels = {
              OD: r.get("OD"),
              LD: r.get("LD"),
              FD: r.get("FD"),
              SD: r.get("SD"),
              HD: r.get("HD"),
              "2K": r.get("2K"),
              "4K": r.get("4K"),
              XLD: r.get("XLD"),
              FHD: r.get("FHD"),
              SQ: r.get("SQ"),
              HQ: r.get("HQ"),
            }),
            (t.exports.SpeedLevels = [
              { key: 0.5, text: r.get("Speed_05X_Text") },
              { key: 1, text: r.get("Speed_1X_Text") },
              { key: 1.25, text: r.get("Speed_125X_Text") },
              { key: 1.5, text: r.get("Speed_15X_Text") },
              { key: 2, text: r.get("Speed_2X_Text") },
            ]);
        };
        o(), (t.exports.updateByLanguage = o);
      },
      { "../lang/index": 11 },
    ],
    16: [
      function (e, t, i) {
        (t.exports.get = function (e) {
          for (
            var t = e + "", i = document.cookie.split(";"), r = 0;
            r < i.length;
            r++
          ) {
            var o = i[r].trim();
            if (0 == o.indexOf(t))
              return unescape(o.substring(t.length + 1, o.length));
          }
          return "";
        }),
          (t.exports.set = function (e, t, i) {
            var r = new Date();
            r.setTime(r.getTime() + 24 * i * 60 * 60 * 1e3);
            var o = "expires=" + r.toGMTString();
            document.cookie = e + "=" + escape(t) + "; " + o;
          });
      },
      {},
    ],
    17: [
      function (e, i, t) {
        var r = e("./object");
        (i.exports.cache = {}),
          (i.exports.guid = function (e, t) {
            var i,
              r,
              o =
                "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".split(
                  ""
                ),
              n = [];
            if (((t = t || o.length), e))
              for (i = 0; i < e; i++) n[i] = o[0 | (Math.random() * t)];
            else
              for (
                n[8] = n[13] = n[18] = n[23] = "-", n[14] = "4", i = 0;
                i < 36;
                i++
              )
                n[i] ||
                  ((r = 0 | (16 * Math.random())),
                  (n[i] = o[19 == i ? (3 & r) | 8 : r]));
            return n.join("");
          }),
          (i.exports.expando = "vdata" + new Date().getTime()),
          (i.exports.getData = function (e) {
            var t = e[i.exports.expando];
            return (
              t ||
                ((t = e[i.exports.expando] = i.exports.guid()),
                (i.exports.cache[t] = {})),
              i.exports.cache[t]
            );
          }),
          (i.exports.hasData = function (e) {
            var t = "";
            return (
              e && (t = e[i.exports.expando]),
              !(!t || r.isEmpty(i.exports.cache[t]))
            );
          }),
          (i.exports.removeData = function (t) {
            var e = "";
            if ((t && (e = t[i.exports.expando]), e)) {
              delete i.exports.cache[e];
              try {
                delete t[i.exports.expando];
              } catch (e) {
                t.removeAttribute
                  ? t.removeAttribute(i.exports.expando)
                  : (t[i.exports.expando] = null);
              }
            }
          });
      },
      { "./object": 26 },
    ],
    18: [
      function (e, c, t) {
        var r = e("./object");
        (c.exports.el = function (e) {
          return document.getElementById(e);
        }),
          (c.exports.createEl = function (e, t) {
            var i;
            return (
              (e = e || "div"),
              (t = t || {}),
              (i = document.createElement(e)),
              r.each(t, function (e, t) {
                -1 !== e.indexOf("aria-") || "role" == e
                  ? i.setAttribute(e, t)
                  : (i[e] = t);
              }),
              i
            );
          }),
          (c.exports.addClass = function (e, t) {
            -1 == (" " + e.className + " ").indexOf(" " + t + " ") &&
              (e.className = "" === e.className ? t : e.className + " " + t);
          }),
          (c.exports.removeClass = function (e, t) {
            var i, r;
            if (-1 != e.className.indexOf(t)) {
              for (r = (i = e.className.split(" ")).length - 1; 0 <= r; r--)
                i[r] === t && i.splice(r, 1);
              e.className = i.join(" ");
            }
          }),
          (c.exports.hasClass = function (e, t) {
            return -1 != e.className.indexOf(t);
          }),
          (c.exports.getClasses = function (e) {
            return e.className ? e.className.split(" ") : [];
          }),
          (c.exports.getElementAttributes = function (e) {
            var t, i, r, o, n;
            if (
              ((t = {}),
              (i = ",autoplay,controls,loop,muted,default,"),
              e && e.attributes && 0 < e.attributes.length)
            )
              for (var a = (r = e.attributes).length - 1; 0 <= a; a--)
                (o = r[a].name),
                  (n = r[a].value),
                  ("boolean" != typeof e[o] &&
                    -1 === i.indexOf("," + o + ",")) ||
                    (n = null !== n),
                  (t[o] = n);
            return t;
          }),
          (c.exports.insertFirst = function (e, t) {
            t.firstChild ? t.insertBefore(e, t.firstChild) : t.appendChild(e);
          }),
          (c.exports.blockTextSelection = function () {
            document.body.focus(),
              (document.onselectstart = function () {
                return !1;
              });
          }),
          (c.exports.unblockTextSelection = function () {
            document.onselectstart = function () {
              return !0;
            };
          }),
          (c.exports.css = function (i, e, t) {
            return (
              !(!i || !i.style) &&
              (e && t
                ? ((i.style[e] = t), !0)
                : t || "string" != typeof e
                ? !t &&
                  "object" == typeof e &&
                  (r.each(e, function (e, t) {
                    i.style[e] = t;
                  }),
                  !0)
                : i.style[e])
            );
          }),
          (c.exports.getTransformName = function (e) {
            var t,
              i,
              r = [
                "transform",
                "WebkitTransform",
                "MozTransform",
                "msTransform",
                "OTransform",
              ],
              o = r[0];
            for (t = 0, i = r.length; t < i; t++)
              if (void 0 !== e.style[r[t]]) {
                o = r[t];
                break;
              }
            return o;
          }),
          (c.exports.getTransformEventName = function (e, t) {
            var i,
              r,
              o = ["", "Webkit", "Moz", "ms", "O"],
              n = t.toLowerCase(),
              a = [
                "transform",
                "WebkitTransform",
                "MozTransform",
                "msTransform",
                "OTransform",
              ];
            for (i = 0, r = a.length; i < r; i++)
              if (void 0 !== e.style[a[i]]) {
                0 != i && (n = o[i] + t);
                break;
              }
            return n;
          }),
          (c.exports.addCssByStyle = function (e) {
            var t = document,
              i = t.createElement("style");
            if ((i.setAttribute("type", "text/css"), i.styleSheet))
              i.styleSheet.cssText = e;
            else {
              var r = t.createTextNode(e);
              i.appendChild(r);
            }
            var o = t.getElementsByTagName("head");
            o.length ? o[0].appendChild(i) : t.documentElement.appendChild(i);
          }),
          (c.exports.getTranslateX = function (e) {
            var t = 0;
            if (e)
              try {
                var i = window.getComputedStyle(e),
                  r = c.exports.getTransformName(e);
                t = new WebKitCSSMatrix(i[r]).m41;
              } catch (e) {
                console.log(e);
              }
            return t;
          }),
          (c.exports.getPointerPosition = function (e, t) {
            var i = {},
              r = c.exports.findPosition(e),
              o = e.offsetWidth,
              n = e.offsetHeight,
              a = r.top,
              s = r.left,
              l = t.pageY,
              u = t.pageX;
            return (
              t.changedTouches &&
                ((u = t.changedTouches[0].pageX),
                (l = t.changedTouches[0].pageY)),
              (i.y = Math.max(0, Math.min(1, (a - l + n) / n))),
              (i.x = Math.max(0, Math.min(1, (u - s) / o))),
              i
            );
          }),
          (c.exports.findPosition = function (e) {
            var t;
            if (
              (e.getBoundingClientRect &&
                e.parentNode &&
                (t = e.getBoundingClientRect()),
              !t)
            )
              return { left: 0, top: 0 };
            var i = document.documentElement,
              r = document.body,
              o = i.clientLeft || r.clientLeft || 0,
              n = window.pageXOffset || r.scrollLeft,
              a = t.left + n - o,
              s = i.clientTop || r.clientTop || 0,
              l = window.pageYOffset || r.scrollTop,
              u = t.top + l - s;
            return { left: Math.round(a), top: Math.round(u) };
          });
      },
      { "./object": 26 },
    ],
    19: [
      function (e, l, t) {
        var u = e("./object"),
          c = e("./data"),
          i = e("./ua"),
          r = e("fastclick");
        function d(t, i, e, r) {
          u.each(e, function (e) {
            t(i, e, r);
          });
        }
        (l.exports.on = function (n, e, t) {
          if (n) {
            if (u.isArray(e)) return d(l.exports.on, n, e, t);
            i.IS_MOBILE && "click" == e && r(n);
            var a = c.getData(n);
            a.handlers || (a.handlers = {}),
              a.handlers[e] || (a.handlers[e] = []),
              t.guid || (t.guid = c.guid()),
              a.handlers[e].push(t),
              a.dispatcher ||
                ((a.disabled = !1),
                (a.dispatcher = function (e) {
                  if (!a.disabled) {
                    e = l.exports.fixEvent(e);
                    var t = a.handlers[e.type];
                    if (t)
                      for (
                        var i = t.slice(0), r = 0, o = i.length;
                        r < o && !e.isImmediatePropagationStopped();
                        r++
                      )
                        i[r].call(n, e);
                  }
                })),
              1 == a.handlers[e].length &&
                (n.addEventListener
                  ? n.addEventListener(e, a.dispatcher, !1)
                  : n.attachEvent && n.attachEvent("on" + e, a.dispatcher));
          }
        }),
          (l.exports.off = function (t, e, i) {
            if (t && c.hasData(t)) {
              var r = c.getData(t);
              if (r.handlers) {
                if (u.isArray(e)) return d(l.exports.off, t, e, i);
                var o = function (e) {
                  (r.handlers[e] = []), l.exports.cleanUpEvents(t, e);
                };
                if (e) {
                  var n = r.handlers[e];
                  if (n)
                    if (i) {
                      if (i.guid)
                        for (var a = 0; a < n.length; a++)
                          n[a].guid === i.guid && n.splice(a--, 1);
                      l.exports.cleanUpEvents(t, e);
                    } else o(e);
                } else for (var s in r.handlers) o(s);
              }
            }
          }),
          (l.exports.cleanUpEvents = function (e, t) {
            var i = c.getData(e);
            0 === i.handlers[t].length &&
              (delete i.handlers[t],
              e.removeEventListener
                ? e.removeEventListener(t, i.dispatcher, !1)
                : e.detachEvent && e.detachEvent("on" + t, i.dispatcher)),
              u.isEmpty(i.handlers) &&
                (delete i.handlers, delete i.dispatcher, delete i.disabled),
              u.isEmpty(i) && c.removeData(e);
          }),
          (l.exports.fixEvent = function (e) {
            function t() {
              return !0;
            }
            function i() {
              return !1;
            }
            if (!e || !e.isPropagationStopped) {
              var r = e || window.event;
              for (var o in ((e = {}), r))
                "layerX" !== o &&
                  "layerY" !== o &&
                  "keyboardEvent.keyLocation" !== o &&
                  (("returnValue" == o && r.preventDefault) || (e[o] = r[o]));
              if (
                (e.target || (e.target = e.srcElement || document),
                (e.relatedTarget =
                  e.fromElement === e.target ? e.toElement : e.fromElement),
                (e.preventDefault = function () {
                  r.preventDefault && r.preventDefault(),
                    (e.returnValue = !1),
                    (e.isDefaultPrevented = t),
                    (e.defaultPrevented = !0);
                }),
                (e.isDefaultPrevented = i),
                (e.defaultPrevented = !1),
                (e.stopPropagation = function () {
                  r.stopPropagation && r.stopPropagation(),
                    (e.cancelBubble = !0),
                    (e.isPropagationStopped = t);
                }),
                (e.isPropagationStopped = i),
                (e.stopImmediatePropagation = function () {
                  r.stopImmediatePropagation && r.stopImmediatePropagation(),
                    (e.isImmediatePropagationStopped = t),
                    e.stopPropagation();
                }),
                (e.isImmediatePropagationStopped = i),
                null != e.clientX)
              ) {
                var n = document.documentElement,
                  a = document.body;
                (e.pageX =
                  e.clientX +
                  ((n && n.scrollLeft) || (a && a.scrollLeft) || 0) -
                  ((n && n.clientLeft) || (a && a.clientLeft) || 0)),
                  (e.pageY =
                    e.clientY +
                    ((n && n.scrollTop) || (a && a.scrollTop) || 0) -
                    ((n && n.clientTop) || (a && a.clientTop) || 0));
              }
              (e.which = e.charCode || e.keyCode),
                null != e.button &&
                  (e.button =
                    1 & e.button ? 0 : 4 & e.button ? 1 : 2 & e.button ? 2 : 0);
            }
            return e;
          }),
          (l.exports.trigger = function (e, t) {
            if (e) {
              var i = c.hasData(e) ? c.getData(e) : {},
                r = e.parentNode || e.ownerDocument;
              if ("string" == typeof t) {
                var o = null;
                (e.paramData || 0 == e.paramData) &&
                  ((o = e.paramData),
                  (e.paramData = null),
                  e.removeAttribute(o)),
                  (t = { type: t, target: e, paramData: o });
              }
              if (
                ((t = l.exports.fixEvent(t)),
                i.dispatcher && i.dispatcher.call(e, t),
                r && !t.isPropagationStopped() && !1 !== t.bubbles)
              )
                l.exports.trigger(r, t);
              else if (!r && !t.defaultPrevented) {
                var n = c.getData(t.target);
                t.target[t.type] &&
                  ((n.disabled = !0),
                  "function" == typeof t.target[t.type] && t.target[t.type](),
                  (n.disabled = !1));
              }
              return !t.defaultPrevented;
            }
          }),
          (l.exports.one = function (e, t, i) {
            if (e) {
              if (u.isArray(t)) return d(l.exports.one, e, t, i);
              var r = function () {
                l.exports.off(e, t, r), i.apply(this, arguments);
              };
              (r.guid = i.guid = i.guid || c.guid()), l.exports.on(e, t, r);
            }
          });
      },
      { "./data": 17, "./object": 26, "./ua": 31, fastclick: 1 },
    ],
    20: [
      function (e, t, i) {
        var o = e("./data");
        t.exports.bind = function (e, t, i) {
          t.guid || (t.guid = o.guid());
          var r = function () {
            return t.apply(e, arguments);
          };
          return (r.guid = i ? i + "_" + t.guid : t.guid), r;
        };
      },
      { "./data": 17 },
    ],
    21: [
      function (e, t, i) {
        var r =
            /^((?:[a-zA-Z0-9+\-.]+:)?)(\/\/[^\/\;?#]*)?(.*?)??(;.*?)?(\?.*?)?(#.*?)?$/,
          c = /^([^\/;?#]*)(.*)$/,
          o = /(?:\/|^)\.(?=\/)/g,
          n = /(?:\/|^)\.\.\/(?!\.\.\/).*?(?=\/)/g,
          d = {
            buildAbsoluteURL: function (e, t, i) {
              if (((i = i || {}), (e = e.trim()), !(t = t.trim()))) {
                if (!i.alwaysNormalize) return e;
                var r = d.parseURL(e);
                if (!r) throw new Error("Error trying to parse base URL.");
                return (
                  (r.path = d.normalizePath(r.path)), d.buildURLFromParts(r)
                );
              }
              var o = d.parseURL(t);
              if (!o) throw new Error("Error trying to parse relative URL.");
              if (o.scheme)
                return i.alwaysNormalize
                  ? ((o.path = d.normalizePath(o.path)), d.buildURLFromParts(o))
                  : t;
              var n = d.parseURL(e);
              if (!n) throw new Error("Error trying to parse base URL.");
              if (!n.netLoc && n.path && "/" !== n.path[0]) {
                var a = c.exec(n.path);
                (n.netLoc = a[1]), (n.path = a[2]);
              }
              n.netLoc && !n.path && (n.path = "/");
              var s = {
                scheme: n.scheme,
                netLoc: o.netLoc,
                path: null,
                params: o.params,
                query: o.query,
                fragment: o.fragment,
              };
              if (!o.netLoc && ((s.netLoc = n.netLoc), "/" !== o.path[0]))
                if (o.path) {
                  var l = n.path,
                    u = l.substring(0, l.lastIndexOf("/") + 1) + o.path;
                  s.path = d.normalizePath(u);
                } else
                  (s.path = n.path),
                    o.params ||
                      ((s.params = n.params), o.query || (s.query = n.query));
              return (
                null === s.path &&
                  (s.path = i.alwaysNormalize
                    ? d.normalizePath(o.path)
                    : o.path),
                d.buildURLFromParts(s)
              );
            },
            parseURL: function (e) {
              var t = r.exec(e);
              return t
                ? {
                    scheme: t[1] || "",
                    netLoc: t[2] || "",
                    path: t[3] || "",
                    params: t[4] || "",
                    query: t[5] || "",
                    fragment: t[6] || "",
                  }
                : null;
            },
            normalizePath: function (e) {
              for (
                e = e.split("").reverse().join("").replace(o, "");
                e.length !== (e = e.replace(n, "")).length;

              );
              return e.split("").reverse().join("");
            },
            buildURLFromParts: function (e) {
              return (
                e.scheme + e.netLoc + e.path + e.params + e.query + e.fragment
              );
            },
          };
        t.exports = d;
      },
      {},
    ],
    22: [
      function (e, t, i) {
        var r = /^(\d+)x(\d+)$/,
          o = /\s*(.+?)\s*=((?:\".*?\")|.*?)(?:,|$)/g,
          n = function (e) {
            for (var t in ("string" == typeof e && (e = this.parseAttrList(e)),
            e))
              e.hasOwnProperty(t) && (this[t] = e[t]);
          };
        (n.prototype = {
          decimalInteger: function (e) {
            var t = parseInt(this[e], 10);
            return t > Number.MAX_SAFE_INTEGER ? 1 / 0 : t;
          },
          hexadecimalInteger: function (e) {
            if (this[e]) {
              var t = (this[e] || "0x").slice(2);
              t = (1 & t.length ? "0" : "") + t;
              for (
                var i = new Uint8Array(t.length / 2), r = 0;
                r < t.length / 2;
                r++
              )
                i[r] = parseInt(t.slice(2 * r, 2 * r + 2), 16);
              return i;
            }
            return null;
          },
          hexadecimalIntegerAsNumber: function (e) {
            var t = parseInt(this[e], 16);
            return t > Number.MAX_SAFE_INTEGER ? 1 / 0 : t;
          },
          decimalFloatingPoint: function (e) {
            return parseFloat(this[e]);
          },
          enumeratedString: function (e) {
            return this[e];
          },
          decimalResolution: function (e) {
            var t = r.exec(this[e]);
            if (null !== t)
              return { width: parseInt(t[1], 10), height: parseInt(t[2], 10) };
          },
          parseAttrList: function (e) {
            var t,
              i = {};
            for (o.lastIndex = 0; null !== (t = o.exec(e)); ) {
              var r = t[2];
              0 === r.indexOf('"') &&
                r.lastIndexOf('"') === r.length - 1 &&
                (r = r.slice(1, -1)),
                (i[t[1]] = r);
            }
            return i;
          },
        }),
          (t.exports = n);
      },
      {},
    ],
    23: [
      function (e, t, i) {
        var P = e("./attrlist"),
          r = e("../io"),
          o = e("./URLToolkit"),
          c = /#EXT-X-STREAM-INF:([^\n\r]*)[\r\n]+([^\r\n]+)/g,
          u = /#EXT-X-MEDIA:(.*)/g,
          w = new RegExp(
            [
              /#EXTINF:(\d*(?:\.\d+)?)(?:,(.*)\s+)?/.source,
              /|(?!#)(\S+)/.source,
              /|#EXT-X-BYTERANGE:*(.+)/.source,
              /|#EXT-X-PROGRAM-DATE-TIME:(.+)/.source,
              /|#.*/.source,
            ].join(""),
            "g"
          ),
          C =
            /(?:(?:#(EXTM3U))|(?:#EXT-X-(PLAYLIST-TYPE):(.+))|(?:#EXT-X-(MEDIA-SEQUENCE): *(\d+))|(?:#EXT-X-(TARGETDURATION): *(\d+))|(?:#EXT-X-(KEY):(.+))|(?:#EXT-X-(START):(.+))|(?:#EXT-X-(ENDLIST))|(?:#EXT-X-(DISCONTINUITY-SEQ)UENCE:(\d+))|(?:#EXT-X-(DIS)CONTINUITY))|(?:#EXT-X-(VERSION):(\d+))|(?:#EXT-X-(MAP):(.+))|(?:(#)(.*):(.*))|(?:(#)(.*))(?:.*)\r?\n?/,
          k = function () {
            (this.method = null),
              (this.key = null),
              (this.iv = null),
              (this._uri = null);
          },
          I = function () {
            (this._url = null),
              (this._byteRange = null),
              (this._decryptdata = null),
              (this.tagList = []);
          };
        (I.prototype.getUrl = function () {
          return (
            !this._url &&
              this.relurl &&
              (this._url = o.buildAbsoluteURL(this.baseurl, this.relurl, {
                alwaysNormalize: !0,
              })),
            this._url
          );
        }),
          (I.prototype.Seturl = function (e) {
            this._url = e;
          }),
          (I.prototype.getProgramDateTime = function () {
            return (
              !this._programDateTime &&
                this.rawProgramDateTime &&
                (this._programDateTime = new Date(
                  Date.parse(this.rawProgramDateTime)
                )),
              this._programDateTime
            );
          }),
          (I.prototype.GetbyteRange = function () {
            if (!this._byteRange) {
              var e = (this._byteRange = []);
              if (this.rawByteRange) {
                var t = this.rawByteRange.split("@", 2);
                if (1 === t.length) {
                  var i = this.lastByteRangeEndOffset;
                  e[0] = i || 0;
                } else e[0] = parseInt(t[1]);
                e[1] = parseInt(t[0]) + e[0];
              }
            }
            return this._byteRange;
          }),
          (I.prototype.getByteRangeStartOffset = function () {
            return this.byteRange[0];
          }),
          (I.prototype.getByteRangeEndOffset = function () {
            return this.byteRange[1];
          });
        I.prototype.getDecryptdata = function () {
          return (
            this._decryptdata ||
              (this._decryptdata = this.fragmentDecryptdataFromLevelkey(
                this.levelkey,
                this.sn
              )),
            this._decryptdata
          );
        };
        var n = function () {
          this.loaders = {};
        };
        (n.prototype = {
          parseMasterPlaylist: function (e, t) {
            var i,
              r = [];
            for (c.lastIndex = 0; null != (i = c.exec(e)); ) {
              var o = {},
                n = (o.attrs = new P(i[1]));
              o.url = this.resolve(i[2], t);
              var a = n.decimalResolution("RESOLUTION");
              a && ((o.width = a.width), (o.height = a.height)),
                (o.bitrate =
                  n.decimalInteger("AVERAGE-BANDWIDTH") ||
                  n.decimalInteger("BANDWIDTH")),
                (o.name = n.NAME);
              var s = n.CODECS;
              if (s) {
                s = s.split(/[ ,]+/);
                for (var l = 0; l < s.length; l++) {
                  var u = s[l];
                  -1 !== u.indexOf("avc1")
                    ? (o.videoCodec = this.avc1toavcoti(u))
                    : -1 !== u.indexOf("hvc1")
                    ? (o.videoCodec = u)
                    : (o.audioCodec = u);
                }
              }
              r.push(o);
            }
            return r;
          },
          parseMasterPlaylistMedia: function (e, t, i, r) {
            var o,
              n = [],
              a = 0;
            for (u.lastIndex = 0; null != (o = u.exec(e)); ) {
              var s = {},
                l = new P(o[1]);
              l.TYPE === i &&
                ((s.groupId = l["GROUP-ID"]),
                (s.name = l.NAME),
                (s.type = i),
                (s["default"] = "YES" === l.DEFAULT),
                (s.autoselect = "YES" === l.AUTOSELECT),
                (s.forced = "YES" === l.FORCED),
                l.URI && (s.url = this.resolve(l.URI, t)),
                (s.lang = l.LANGUAGE),
                s.name || (s.name = s.lang),
                r && (s.audioCodec = r),
                (s.id = a++),
                n.push(s));
            }
            return n;
          },
          avc1toavcoti: function (e) {
            var t,
              i = e.split(".");
            return (
              2 < i.length
                ? ((t = i.shift() + "."),
                  (t += parseInt(i.shift()).toString(16)),
                  (t += ("000" + parseInt(i.shift()).toString(16)).substr(-4)))
                : (t = e),
              t
            );
          },
          parseLevelPlaylist: function (e, t, i, r) {
            var o,
              n,
              a = 0,
              s = 0,
              l = {
                type: null,
                version: null,
                url: t,
                fragments: [],
                live: !0,
                startSN: 0,
              },
              u = new k(),
              c = 0,
              d = null,
              p = new I();
            for (w.lastIndex = 0; null !== (o = w.exec(e)); ) {
              var h = o[1];
              if (h) {
                p.duration = parseFloat(h);
                var f = (" " + o[2]).slice(1);
                (p.title = f || null),
                  p.tagList.push(f ? ["INF", h, f] : ["INF", h]);
              } else if (o[3]) {
                if (!isNaN(p.duration)) {
                  var _ = a++;
                  (p.type = r),
                    (p.start = s),
                    (p.levelkey = u),
                    (p.sn = _),
                    (p.level = i),
                    (p.cc = c),
                    (p.baseurl = t),
                    (p.relurl = (" " + o[3]).slice(1)),
                    l.fragments.push(p),
                    (s += (d = p).duration),
                    (p = new I());
                }
              } else if (o[4]) {
                if (((p.rawByteRange = (" " + o[4]).slice(1)), d)) {
                  var g = d.byteRangeEndOffset;
                  g && (p.lastByteRangeEndOffset = g);
                }
              } else if (o[5])
                (p.rawProgramDateTime = (" " + o[5]).slice(1)),
                  p.tagList.push(["PROGRAM-DATE-TIME", p.rawProgramDateTime]),
                  void 0 === l.programDateTime &&
                    (l.programDateTime = new Date(
                      new Date(Date.parse(o[5])) - 1e3 * s
                    ));
              else {
                for (
                  o = o[0].match(C), n = 1;
                  n < o.length && void 0 === o[n];
                  n++
                );
                var y = (" " + o[n + 1]).slice(1),
                  v = (" " + o[n + 2]).slice(1);
                switch (o[n]) {
                  case "#":
                    p.tagList.push(v ? [y, v] : [y]);
                    break;
                  case "PLAYLIST-TYPE":
                    l.type = y.toUpperCase();
                    break;
                  case "MEDIA-SEQUENCE":
                    a = l.startSN = parseInt(y);
                    break;
                  case "TARGETDURATION":
                    l.targetduration = parseFloat(y);
                    break;
                  case "VERSION":
                    l.version = parseInt(y);
                    break;
                  case "EXTM3U":
                    break;
                  case "ENDLIST":
                    l.live = !1;
                    break;
                  case "DIS":
                    c++, p.tagList.push(["DIS"]);
                    break;
                  case "DISCONTINUITY-SEQ":
                    c = parseInt(y);
                    break;
                  case "KEY":
                    var m = new P(y),
                      S = m.enumeratedString("METHOD"),
                      T = m.URI,
                      b = m.hexadecimalInteger("IV");
                    S &&
                      ((u = new k()),
                      T &&
                        0 <= ["AES-128", "SAMPLE-AES"].indexOf(S) &&
                        ((u.method = S),
                        (u.baseuri = t),
                        (u.reluri = T),
                        (u.key = null),
                        (u.iv = b)));
                    break;
                  case "START":
                    var x = new P(y).decimalFloatingPoint("TIME-OFFSET");
                    isNaN(x) || (l.startTimeOffset = x);
                    break;
                  case "MAP":
                    var E = new P(y);
                    (p.relurl = E.URI),
                      (p.rawByteRange = E.BYTERANGE),
                      (p.baseurl = t),
                      (p.level = i),
                      (p.type = r),
                      (p.sn = "initSegment"),
                      (l.initSegment = p),
                      (p = new I());
                    break;
                  default:
                    console.log("line parsed but not handled: result");
                }
              }
            }
            return (
              (p = d) && !p.relurl && (l.fragments.pop(), (s -= p.duration)),
              (l.totalduration = s),
              (l.averagetargetduration = s / l.fragments.length),
              (l.endSN = a - 1),
              l
            );
          },
          load: function (n, a) {
            var s = this;
            r.get(
              n,
              function (e) {
                var t = s.parseMasterPlaylist(e, n);
                if (t.length) {
                  var i = s.parseMasterPlaylistMedia(
                      e,
                      n,
                      "AUDIO",
                      t[0].audioCodec
                    ),
                    r = s.parseMasterPlaylistMedia(e, n, "SUBTITLES");
                  if (i.length) {
                    var o = !1;
                    i.forEach(function (e) {
                      e.url || (o = !0);
                    }),
                      !1 === o &&
                        t[0].audioCodec &&
                        !t[0].attrs.AUDIO &&
                        (console.log(
                          "audio codec signaled in quality level, but no embedded audio track signaled, create one"
                        ),
                        i.unshift({ type: "main", name: "main" }));
                  }
                }
                a({ levels: t, audioTracks: i, subtitles: r, url: n });
              },
              function (e) {
                console.log(e);
              }
            );
          },
          resolve: function (e, t) {
            return o.buildAbsoluteURL(t, e, { alwaysNormalize: !0 });
          },
          parseMasterPlaylist: function (e, t) {
            var i,
              r = [];
            for (c.lastIndex = 0; null != (i = c.exec(e)); ) {
              var o = {},
                n = (o.attrs = new P(i[1]));
              o.url = this.resolve(i[2], t);
              var a = n.decimalResolution("RESOLUTION");
              a && ((o.width = a.width), (o.height = a.height)),
                (o.bitrate =
                  n.decimalInteger("AVERAGE-BANDWIDTH") ||
                  n.decimalInteger("BANDWIDTH")),
                (o.name = n.NAME);
              var s = n.CODECS;
              if (s) {
                s = s.split(/[ ,]+/);
                for (var l = 0; l < s.length; l++) {
                  var u = s[l];
                  -1 !== u.indexOf("avc1")
                    ? (o.videoCodec = this.avc1toavcoti(u))
                    : -1 !== u.indexOf("hvc1")
                    ? (o.videoCodec = u)
                    : (o.audioCodec = u);
                }
              }
              r.push(o);
            }
            return r;
          },
          parseMasterPlaylistMedia: function (e, t, i, r) {
            var o,
              n = [],
              a = 0;
            for (u.lastIndex = 0; null != (o = u.exec(e)); ) {
              var s = {},
                l = new P(o[1]);
              l.TYPE === i &&
                ((s.groupId = l["GROUP-ID"]),
                (s.name = l.NAME),
                (s.type = i),
                (s["default"] = "YES" === l.DEFAULT),
                (s.autoselect = "YES" === l.AUTOSELECT),
                (s.forced = "YES" === l.FORCED),
                l.URI && (s.url = this.resolve(l.URI, t)),
                (s.lang = l.LANGUAGE),
                s.name || (s.name = s.lang),
                r && (s.audioCodec = r),
                (s.id = a++),
                n.push(s));
            }
            return n;
          },
          avc1toavcoti: function (e) {
            var t,
              i = e.split(".");
            return (
              2 < i.length
                ? ((t = i.shift() + "."),
                  (t += parseInt(i.shift()).toString(16)),
                  (t += ("000" + parseInt(i.shift()).toString(16)).substr(-4)))
                : (t = e),
              t
            );
          },
          parseLevelPlaylist: function (e, t, i, r) {
            var o,
              n,
              a = 0,
              s = 0,
              l = {
                type: null,
                version: null,
                url: t,
                fragments: [],
                live: !0,
                startSN: 0,
              },
              u = new k(),
              c = 0,
              d = null,
              p = new I();
            for (w.lastIndex = 0; null !== (o = w.exec(e)); ) {
              var h = o[1];
              if (h) {
                p.duration = parseFloat(h);
                var f = (" " + o[2]).slice(1);
                (p.title = f || null),
                  p.tagList.push(f ? ["INF", h, f] : ["INF", h]);
              } else if (o[3]) {
                if (!isNaN(p.duration)) {
                  var _ = a++;
                  (p.type = r),
                    (p.start = s),
                    (p.levelkey = u),
                    (p.sn = _),
                    (p.level = i),
                    (p.cc = c),
                    (p.baseurl = t),
                    (p.relurl = (" " + o[3]).slice(1)),
                    l.fragments.push(p),
                    (s += (d = p).duration),
                    (p = new I());
                }
              } else if (o[4]) {
                if (((p.rawByteRange = (" " + o[4]).slice(1)), d)) {
                  var g = d.byteRangeEndOffset;
                  g && (p.lastByteRangeEndOffset = g);
                }
              } else if (o[5])
                (p.rawProgramDateTime = (" " + o[5]).slice(1)),
                  p.tagList.push(["PROGRAM-DATE-TIME", p.rawProgramDateTime]),
                  void 0 === l.programDateTime &&
                    (l.programDateTime = new Date(
                      new Date(Date.parse(o[5])) - 1e3 * s
                    ));
              else {
                for (
                  o = o[0].match(C), n = 1;
                  n < o.length && void 0 === o[n];
                  n++
                );
                var y = (" " + o[n + 1]).slice(1),
                  v = (" " + o[n + 2]).slice(1);
                switch (o[n]) {
                  case "#":
                    p.tagList.push(v ? [y, v] : [y]);
                    break;
                  case "PLAYLIST-TYPE":
                    l.type = y.toUpperCase();
                    break;
                  case "MEDIA-SEQUENCE":
                    a = l.startSN = parseInt(y);
                    break;
                  case "TARGETDURATION":
                    l.targetduration = parseFloat(y);
                    break;
                  case "VERSION":
                    l.version = parseInt(y);
                    break;
                  case "EXTM3U":
                    break;
                  case "ENDLIST":
                    l.live = !1;
                    break;
                  case "DIS":
                    c++, p.tagList.push(["DIS"]);
                    break;
                  case "DISCONTINUITY-SEQ":
                    c = parseInt(y);
                    break;
                  case "KEY":
                    var m = new P(y),
                      S = m.enumeratedString("METHOD"),
                      T = m.URI,
                      b = m.hexadecimalInteger("IV");
                    S &&
                      ((u = new k()),
                      T &&
                        0 <= ["AES-128", "SAMPLE-AES"].indexOf(S) &&
                        ((u.method = S),
                        (u.baseuri = t),
                        (u.reluri = T),
                        (u.key = null),
                        (u.iv = b)));
                    break;
                  case "START":
                    var x = new P(y).decimalFloatingPoint("TIME-OFFSET");
                    isNaN(x) || (l.startTimeOffset = x);
                    break;
                  case "MAP":
                    var E = new P(y);
                    (p.relurl = E.URI),
                      (p.rawByteRange = E.BYTERANGE),
                      (p.baseurl = t),
                      (p.level = i),
                      (p.type = r),
                      (p.sn = "initSegment"),
                      (l.initSegment = p),
                      (p = new I());
                    break;
                  default:
                    console.log("line parsed but not handled: " + o);
                }
              }
            }
            return (
              (p = d) && !p.relurl && (l.fragments.pop(), (s -= p.duration)),
              (l.totalduration = s),
              (l.averagetargetduration = s / l.fragments.length),
              (l.endSN = a - 1),
              l
            );
          },
        }),
          (t.exports = n);
      },
      { "../io": 24, "./URLToolkit": 21, "./attrlist": 22 },
    ],
    24: [
      function (e, s, t) {
        var h = e("./url");
        (s.exports.get = function (e, t, i, r, o) {
          s.exports.ajax("GET", e, {}, t, i, r, o);
        }),
          (s.exports.post = function (e, t, i, r, o, n) {
            var a = {
              "Content-Type":
                "application/x-www-form-urlencoded; charset=UTF-8",
              Accept: "application/json",
            };
            s.exports.ajax("POST", e, t, i, r, o, n, a);
          }),
          (s.exports.postWithHeader = function (e, t, i, r, o) {
            s.exports.ajax("POST", e, t, r, o, !0, !1, i);
          }),
          (s.exports.ajax = function (e, t, i, r, o, n, a, s) {
            var l, u, c, d;
            (o = o || function () {}),
              "undefined" == typeof XMLHttpRequest &&
                (window.XMLHttpRequest = function () {
                  try {
                    return new window.ActiveXObject("Msxml2.XMLHTTP.6.0");
                  } catch (e) {}
                  try {
                    return new window.ActiveXObject("Msxml2.XMLHTTP.3.0");
                  } catch (e) {}
                  try {
                    return new window.ActiveXObject("Msxml2.XMLHTTP");
                  } catch (e) {}
                  throw new Error(
                    "This browser does not support XMLHttpRequest."
                  );
                }),
              (u = new XMLHttpRequest()),
              (c = h.parseUrl(t)),
              (d = window.location),
              !(c.protocol + c.host !== d.protocol + d.host) ||
              !window.XDomainRequest ||
              "withCredentials" in u
                ? ((l = "file:" == c.protocol || "file:" == d.protocol),
                  (u.onreadystatechange = function () {
                    4 === u.readyState &&
                      (200 === u.status || (l && 0 === u.status)
                        ? r(u.responseText)
                        : o(u.responseText));
                  }))
                : (((u = new window.XDomainRequest()).onload = function () {
                    r(u.responseText);
                  }),
                  (u.onerror = o),
                  (u.onprogress = function () {}),
                  (u.ontimeout = o));
            try {
              if (
                (void 0 === n && (n = !0),
                u.open(e, t, n),
                a && (u.withCredentials = !0),
                s)
              )
                for (var p in s)
                  s.hasOwnProperty(p) && u.setRequestHeader(p, s[p]);
            } catch (e) {
              return void o(e);
            }
            try {
              u.send(i);
            } catch (e) {
              o(e);
            }
          }),
          (s.exports.jsonp = function (e, t, i) {
            var r = "jsonp_callback_" + Math.round(1e5 * Math.random()),
              o = document.createElement("script");
            e &&
              ((o.src =
                e +
                (0 <= e.indexOf("?") ? "&" : "?") +
                "callback=" +
                r +
                "&cb=" +
                r),
              (o.onerror = function () {
                delete window[r], document.body.removeChild(o), i();
              }),
              (o.onload = function () {
                setTimeout(function () {
                  window[r] && (delete window[r], document.body.removeChild(o));
                }, 0);
              }),
              (window[r] = function (e) {
                delete window[r], document.body.removeChild(o), t(e);
              }),
              document.body.appendChild(o));
          }),
          (s.exports.loadJS = function (e, t) {
            var i = document.getElementsByTagName("HEAD").item(0),
              r = document.createElement("script");
            (r.type = "text/javascript"),
              (r.src = e),
              (r.onload = function () {
                t && t();
              }),
              i.appendChild(r);
          });
      },
      { "./url": 32 },
    ],
    25: [
      function (e, t, i) {
        var s = e("./dom");
        t.exports.render = function (e, t) {
          var i = t.align ? t.align : "tl",
            r = t.x ? t.x : 0,
            o = t.y ? t.y : 0,
            n = r.indexOf && 0 < r.indexOf("%") ? "" : "px",
            a = o.indexOf && 0 < o.indexOf("%") ? "" : "px";
          "tl" === i
            ? s.css(e, {
                float: "left",
                "margin-left": r + n,
                "margin-top": o + a,
              })
            : "tr" === i
            ? s.css(e, {
                float: "right",
                "margin-right": r + n,
                "margin-top": o + a,
              })
            : "tlabs" === i
            ? s.css(e, { position: "absolute", left: r + n, top: o + a })
            : "trabs" === i
            ? s.css(e, { position: "absolute", right: r + n, top: o + a })
            : "blabs" === i
            ? s.css(e, { position: "absolute", left: r + n, bottom: o + a })
            : "brabs" === i
            ? s.css(e, { position: "absolute", right: r + n, bottom: o + a })
            : "cc" === i && s.addClass(e, "center");
        };
      },
      { "./dom": 18 },
    ],
    26: [
      function (e, a, t) {
        var s = Object.prototype.hasOwnProperty;
        (a.exports.create =
          Object.create ||
          function (e) {
            function t() {}
            return (t.prototype = e), new t();
          }),
          (a.exports.isArray = function (e) {
            return "[object Array]" === Object.prototype.toString.call(arg);
          }),
          (a.exports.isEmpty = function (e) {
            for (var t in e) if (null !== e[t]) return !1;
            return !0;
          }),
          (a.exports.each = function (e, t, i) {
            if (a.exports.isArray(e))
              for (
                var r = 0, o = e.length;
                r < o && !1 !== t.call(i || this, e[r], r);
                ++r
              );
            else
              for (var n in e)
                if (s.call(e, n) && !1 === t.call(i || this, n, e[n])) break;
            return e;
          }),
          (a.exports.merge = function (e, t) {
            if (!t) return e;
            for (var i in t) s.call(t, i) && (e[i] = t[i]);
            return e;
          }),
          (a.exports.deepMerge = function (e, t) {
            var i, r, o;
            for (i in ((e = a.exports.copy(e)), t))
              s.call(t, i) &&
                ((r = e[i]),
                (o = t[i]),
                a.exports.isPlain(r) && a.exports.isPlain(o)
                  ? (e[i] = a.exports.deepMerge(r, o))
                  : (e[i] = t[i]));
            return e;
          }),
          (a.exports.copy = function (e) {
            return a.exports.merge({}, e);
          }),
          (a.exports.isPlain = function (e) {
            return (
              !!e &&
              "object" == typeof e &&
              "[object Object]" === e.toString() &&
              e.constructor === Object
            );
          }),
          (a.exports.isArray =
            Array.isArray ||
            function (e) {
              return "[object Array]" === Object.prototype.toString.call(e);
            }),
          (a.exports.unescape = function (e) {
            return e.replace(/&([^;]+);/g, function (e, t) {
              return (
                {
                  amp: "&",
                  lt: "<",
                  gt: ">",
                  quot: '"',
                  "#x27": "'",
                  "#x60": "`",
                }[t.toLowerCase()] || e
              );
            });
          });
      },
      {},
    ],
    27: [
      function (e, t, i) {
        var o = e("./object"),
          n = function () {};
        ((n = function () {}).extend = function (e) {
          var t, i;
          for (var r in ((t =
            (e = e || {}).init ||
            e.init ||
            this.prototype.init ||
            this.prototype.init ||
            function () {}),
          ((((i = function () {
            t.apply(this, arguments);
          }).prototype = o.create(this.prototype)).constructor = i).extend =
            n.extend),
          (i.create = n.create),
          e))
            e.hasOwnProperty(r) && (i.prototype[r] = e[r]);
          return i;
        }),
          (n.create = function () {
            var e = o.create(this.prototype);
            return this.apply(e, arguments), e;
          }),
          (t.exports = n);
      },
      { "./object": 26 },
    ],
    28: [
      function (e, f, t) {
        var _ = e("./object"),
          i = e("../config"),
          r = e("./dom"),
          o = e("./cookie"),
          n = e("./constants"),
          a = e("../lang/index"),
          s = e("./ua"),
          g = e("../player/base/plugin/defaultemptycomponent"),
          y = {
            preload: !0,
            autoplay: !0,
            useNativeControls: !1,
            width: "100%",
            height: "300px",
            cover: "",
            from: "",
            trackLog: !0,
            logBatched: !0,
            isLive: !1,
            playsinline: !0,
            showBarTime: 5e3,
            rePlay: !1,
            liveRetry: 5,
            liveRetryInterval: 1,
            liveRetryStep: 0,
            vodRetry: 3,
            format: "",
            definition: "",
            defaultDefinition: "",
            loadDataTimeout: 20,
            waitingTimeout: 60,
            delayLoadingShow: 1,
            controlBarForOver: !1,
            controlBarVisibility: "hover",
            enableSystemMenu: !1,
            qualitySort: "asc",
            x5_video_position: "normal",
            x5_type: "",
            x5_fullscreen: !1,
            x5_orientation: "landscape|portrait",
            x5LandscapeAsFullScreen: !0,
            autoPlayDelay: 0,
            autoPlayDelayDisplayText: "",
            useHlsPluginForSafari: !1,
            enableMSEForAndroid: !0,
            encryptType: 0,
            language: "zh-cn",
            languageTexts: {},
            mediaType: "video",
            outputType: "",
            playConfig: {},
            reAuthInfo: {},
            components: [],
            liveTimeShiftUrl: "",
            liveShiftSource: "",
            liveShiftTime: "",
            videoHeight: "100%",
            videoWidth: "100%",
            enableWorker: !0,
            authTimeout: "",
            enableMockFullscreen: !1,
            region: "cn-shanghai",
            debug: !1,
            progressMarkers: [],
            snapshotWatermark: {
              left: "500",
              top: "100",
              text: "",
              font: "16px \u5b8b\u4f53",
              fillColor: "#FFFFFF",
              strokeColor: "#FFFFFF",
            },
            liveStartTime: "",
            liveOverTime: "",
            enableStashBufferForFlv: !0,
            stashInitialSizeForFlv: 32,
            flvOption: {},
            hlsOption: { stopLoadAsPaused: !1 },
            hlsLoadingTimeOut: 2e4,
            useHlsPlugOnMobile: !0,
            nudgeMaxRetry: 5,
            tracks: [],
            recreatePlayer: function () {},
            diagnosisButtonVisible: !0,
            _native: !0,
            ai: {
              label: !1,
              meta: {
                url: "http://172.19.61.105:8085/meta/query",
                getMeta: "",
              },
              boxes: "",
              host: "",
              app: "",
              streamName: "",
              startDateTime: 0,
              waitMetaDataTime: 2,
              displayAttrs: {
                header: "\u59d3\u540d",
                "\u8bc1\u4ef6\u53f7\u7801": "text",
                "\u6027\u522b": "text",
                "\u5e74\u9f84": "text",
                "\u53d1\u578b": "text",
                "\u4eba\u8138\u5927\u56fe": function (e) {},
                "\u4eba\u8138\u5c0f\u56fe": function (e) {},
              },
              getClass: function (e, t) {
                return "";
              },
            },
            thumbnailUrl: "",
            skinRes:
              "//" +
              i.domain +
              "/de/prismplayer-flash/" +
              i.flashVersion +
              "/atlas/defaultSkin",
          };
        (f.exports.defaultH5Layout = [
          { name: "bigPlayButton", align: "blabs", x: 30, y: 80 },
          { name: "H5Loading", align: "cc" },
          { name: "errorDisplay", align: "tlabs", x: 0, y: 0 },
          { name: "infoDisplay" },
          { name: "tooltip", align: "blabs", x: 0, y: 50 },
          { name: "thumbnail" },
          {
            name: "controlBar",
            align: "blabs",
            x: 0,
            y: 0,
            children: [
              { name: "progress", align: "blabs", x: 0, y: 44 },
              { name: "playButton", align: "tl", x: 15, y: 12 },
              { name: "timeDisplay", align: "tl", x: 10, y: 5 },
              { name: "fullScreenButton", align: "tr", x: 10, y: 12 },
              { name: "subtitle", align: "tr", x: 15, y: 12 },
              { name: "setting", align: "tr", x: 15, y: 12 },
              { name: "volume", align: "tr", x: 5, y: 10 },
            ],
          },
        ]),
          (f.exports.defaultAudioLayout = [
            {
              name: "controlBar",
              align: "blabs",
              x: 0,
              y: 0,
              children: [
                { name: "progress", align: "blabs", x: 0, y: 44 },
                { name: "playButton", align: "tl", x: 15, y: 12 },
                { name: "timeDisplay", align: "tl", x: 10, y: 5 },
                { name: "volume", align: "tr", x: 5, y: 10 },
              ],
            },
          ]),
          (f.exports.defaultFlashLayout = [
            { name: "bigPlayButton", align: "blabs", x: 30, y: 80 },
            {
              name: "controlBar",
              align: "blabs",
              x: 0,
              y: 0,
              children: [
                { name: "progress", align: "tlabs", x: 0, y: 0 },
                { name: "playButton", align: "tl", x: 15, y: 26 },
                { name: "nextButton", align: "tl", x: 10, y: 26 },
                { name: "timeDisplay", align: "tl", x: 10, y: 24 },
                { name: "fullScreenButton", align: "tr", x: 10, y: 25 },
                { name: "streamButton", align: "tr", x: 10, y: 23 },
                { name: "volume", align: "tr", x: 10, y: 25 },
              ],
            },
            {
              name: "fullControlBar",
              align: "tlabs",
              x: 0,
              y: 0,
              children: [
                { name: "fullTitle", align: "tl", x: 25, y: 6 },
                { name: "fullNormalScreenButton", align: "tr", x: 24, y: 13 },
                { name: "fullTimeDisplay", align: "tr", x: 10, y: 12 },
                { name: "fullZoom", align: "cc" },
              ],
            },
          ]),
          (f.exports.canPlayType = function (e) {
            var t = document.createElement("video");
            return t.canPlayType ? t.canPlayType(e) : "";
          }),
          (f.exports.canPlayHls = function () {
            return "" != f.exports.canPlayType("application/x-mpegURL");
          }),
          (f.exports.isUsedHlsPluginOnMobile = function (e) {
            return !(!s.IS_MOBILE || (!s.IS_CHROME && !s.IS_FIREFOX));
          }),
          (f.exports.isSafariUsedHlsPlugin = function (e) {
            return !!(s.os.pc && s.browser.safari && e);
          }),
          (f.exports.hasUIComponent = function (e, t) {
            if (void 0 === e || !e || 0 == e.length) return !1;
            for (var i = 0, r = e.length; i < r; i++) {
              var o = e[i].name;
              if (o == t) return !0;
              if ("controlBar" == o)
                return f.exports.hasUIComponent(e[i].children, t);
            }
            return !1;
          }),
          (f.exports.validateSource = function (e) {
            return !0;
          }),
          (f.exports.supportH5Video = function () {
            return void 0 !== document.createElement("video").canPlayType;
          }),
          (f.exports.createWrapper = function (e) {
            var t,
              i = e.id;
            if (
              !(t =
                "string" == typeof i
                  ? (0 === i.indexOf("#") && (i = i.slice(1)), r.el(i))
                  : i) ||
              !t.nodeName
            )
              throw new TypeError(
                "\u6ca1\u6709\u4e3a\u64ad\u653e\u5668\u6307\u5b9a\u5bb9\u5668"
              );
            return f.exports.adjustContainerLayout(t, e), t;
          }),
          (f.exports.adjustContainerLayout = function (e, t) {
            t.width && !e.style.width && (e.style.width = t.width),
              t.height && !e.style.height && (e.style.height = t.height);
          }),
          (f.exports.isSupportHls = function () {
            var e = (window.MediaSource =
                window.MediaSource || window.WebKitMediaSource),
              t = (window.SourceBuffer =
                window.SourceBuffer || window.WebKitSourceBuffer),
              i =
                e &&
                "function" == typeof e.isTypeSupported &&
                e.isTypeSupported('video/mp4; codecs="avc1.42E01E,mp4a.40.2"'),
              r =
                !t ||
                (t.prototype &&
                  "function" == typeof t.prototype.appendBuffer &&
                  "function" == typeof t.prototype.remove);
            return i && r;
          }),
          (f.exports.isSupportFlv = function () {
            return f.exports.isSupportHls();
          }),
          (f.exports.isSupportMSE = function () {
            return (
              !!window.Promise &&
              !!window.Uint8Array &&
              !!Array.prototype.forEach &&
              f.exports.isSupportedMediaSource()
            );
          }),
          (f.exports.isSupportedMediaSource = function () {
            return !!window.MediaSource && !!MediaSource.isTypeSupported;
          }),
          (f.exports.isSupportedDrm = function () {
            return (
              !!(
                window.MediaKeys &&
                window.navigator &&
                window.navigator.requestMediaKeySystemAccess &&
                window.MediaKeySystemAccess &&
                window.MediaKeySystemAccess.prototype.getConfiguration
              ) && f.exports.isSupportMSE()
            );
          }),
          (f.exports.isAudio = function (e) {
            return e && 0 < e.toLowerCase().indexOf(".mp3");
          }),
          (f.exports.isLiveShift = function (e) {
            return e.isLive && e.liveStartTime && e.liveOverTime;
          }),
          (f.exports.isHls = function (e) {
            return e && 0 < e.toLowerCase().indexOf(".m3u8");
          }),
          (f.exports.isDash = function (e) {
            return e && 0 < e.toLowerCase().indexOf(".mpd");
          }),
          (f.exports.isFlv = function (e) {
            return e && 0 < e.toLowerCase().indexOf(".flv");
          }),
          (f.exports.isRTMP = function (e) {
            return e && -1 < e.toLowerCase().indexOf("rtmp:");
          }),
          (f.exports.checkSecuritSupport = function () {
            return f.exports.isSupportHls()
              ? ""
              : s.IS_IOS
              ? a.get("iOSNotSupportVodEncription")
              : a.get("UseChromeForVodEncription");
          }),
          (f.exports.findSelectedStreamLevel = function (e, t) {
            var i = t;
            if (!i && !(i = o.get(n.SelectedStreamLevel)))
              return o.set(n.SelectedStreamLevel, e[0].definition, 365), 0;
            for (var r = 0; r < e.length; r++)
              if (e[r].definition == i) return r;
            return 0;
          }),
          (f.exports.handleOption = function (e, t) {
            var i = _.merge(_.copy(y), e),
              r = [
                { name: "fullScreenButton", align: "tr", x: 20, y: 12 },
                { name: "subtitle", align: "tr", x: 15, y: 12 },
                { name: "setting", align: "tr", x: 15, y: 12 },
                { name: "volume", align: "tr", x: 5, y: 10 },
              ],
              o = !1;
            if (e.useFlashPrism || f.exports.isRTMP(e.source))
              (o = !0),
                (r = [
                  { name: "liveIco", align: "tlabs", x: 15, y: 25 },
                  { name: "fullScreenButton", align: "tr", x: 10, y: 25 },
                  { name: "volume", align: "tr", x: 10, y: 25 },
                ]);
            else {
              var n = f.exports.isLiveShift(i);
              n
                ? (r.push({
                    name: "liveShiftProgress",
                    align: "tlabs",
                    x: 0,
                    y: 0,
                  }),
                  r.push({ name: "playButton", align: "tl", x: 15, y: 12 }),
                  r.push({ name: "liveDisplay", align: "tl", x: 15, y: 6 }))
                : r.push({ name: "liveDisplay", align: "tlabs", x: 15, y: 6 });
            }
            if (e.isLive)
              if (void 0 === e.skinLayout)
                i.skinLayout = [
                  { name: "errorDisplay", align: "tlabs", x: 0, y: 0 },
                  { name: "infoDisplay" },
                  { name: "bigPlayButton", align: "blabs", x: 30, y: 80 },
                  { name: "tooltip", align: "blabs", x: 0, y: 56 },
                  { name: "H5Loading", align: "cc" },
                  {
                    name: "controlBar",
                    align: "blabs",
                    x: 0,
                    y: 0,
                    children: r,
                  },
                ];
              else if (0 != e.skinLayout) {
                for (
                  var a = e.skinLayout.length, s = [], l = -1, u = 0;
                  u < a;
                  u++
                )
                  if ("controlBar" == i.skinLayout[u].name) {
                    l = u;
                    for (
                      var c = i.skinLayout[u].children.length, d = 0;
                      d < c;
                      d++
                    ) {
                      var p = i.skinLayout[u].children[d].name;
                      if (
                        "liveDisplay" == p ||
                        "liveIco" == p ||
                        "fullScreenButton" == p ||
                        "volume" == p ||
                        "snapshot" == p ||
                        "setting" == p ||
                        "subtitle" == p ||
                        (n &&
                          ("progress" == p ||
                            "playButton" == p ||
                            "timeDisplay" == p))
                      ) {
                        var h = i.skinLayout[u].children[d];
                        "progress" == p
                          ? (h.name = "liveShiftProgress")
                          : "timeDisplay" == p
                          ? (h.name = "liveShiftTimeDisplay")
                          : o && "liveDisplay" == p && (h.name = "liveIco"),
                          s.push(h);
                      }
                    }
                    break;
                  }
                -1 != l && (i.skinLayout[l].children = s);
              }
            return (
              (void 0 === e.components ||
                !e.components ||
                (_.isArray(e.components) && 0 == e.components.length)) &&
                "false" != e.components &&
                (i.components = [g]),
              i
            );
          });
      },
      {
        "../config": 5,
        "../lang/index": 11,
        "../player/base/plugin/defaultemptycomponent": 63,
        "./constants": 15,
        "./cookie": 16,
        "./dom": 18,
        "./object": 26,
        "./ua": 31,
      },
    ],
    29: [
      function (e, t, i) {
        arguments[4][28][0].apply(i, arguments);
      },
      {
        "../config": 5,
        "../lang/index": 11,
        "../player/base/plugin/defaultemptycomponent": 63,
        "./constants": 15,
        "./cookie": 16,
        "./dom": 18,
        "./object": 26,
        "./ua": 31,
        dup: 28,
      },
    ],
    30: [
      function (e, t, i) {
        (t.exports.set = function (t, i) {
          try {
            window.localStorage && localStorage.setItem(t, i);
          } catch (e) {
            window[t + "_localStorage"] = i;
          }
        }),
          (t.exports.get = function (t) {
            try {
              if (window.localStorage) return localStorage.getItem(t);
            } catch (e) {
              return window[t + "_localStorage"];
            }
            return "";
          });
      },
      {},
    ],
    31: [
      function (e, C, t) {
        if (
          ((C.exports.USER_AGENT = navigator.userAgent),
          (C.exports.IS_IPHONE = /iPhone/i.test(C.exports.USER_AGENT)),
          (C.exports.IS_IPAD = /iPad/i.test(C.exports.USER_AGENT)),
          (C.exports.IS_IPOD = /iPod/i.test(C.exports.USER_AGENT)),
          (C.exports.IS_MAC = /mac/i.test(C.exports.USER_AGENT)),
          (C.exports.IS_EDGE = /Edge/i.test(C.exports.USER_AGENT)),
          (C.exports.IS_IE11 = /Trident\/7.0/i.test(C.exports.USER_AGENT)),
          (C.exports.IS_X5 = /qqbrowser/i.test(
            C.exports.USER_AGENT.toLowerCase()
          )),
          (C.exports.IS_CHROME =
            /Chrome/i.test(C.exports.USER_AGENT) &&
            !C.exports.IS_EDGE &&
            !C.exports.IS_X5),
          (C.exports.IS_SAFARI =
            /Safari/i.test(C.exports.USER_AGENT) && !C.exports.IS_CHROME),
          (C.exports.IS_FIREFOX = /Firefox/i.test(C.exports.USER_AGENT)),
          document.all)
        )
          try {
            var i = new ActiveXObject("ShockwaveFlash.ShockwaveFlash");
            C.exports.HAS_FLASH = !!i;
          } catch (e) {
            C.exports.HAS_FLASH = !1;
          }
        else if (navigator.plugins && 0 < navigator.plugins.length) {
          i = navigator.plugins["Shockwave Flash"];
          C.exports.HAS_FLASH = !!i;
        } else C.exports.HAS_FLASH = !1;
        var r, o, n, a;
        (C.exports.IS_MAC_SAFARI =
          C.exports.IS_MAC &&
          C.exports.IS_SAFARI &&
          !C.exports.IS_CHROME &&
          !C.exports.HAS_FLASH),
          (C.exports.IS_IOS =
            C.exports.IS_IPHONE || C.exports.IS_IPAD || C.exports.IS_IPOD),
          (C.exports.IOS_VERSION = (function () {
            var e = C.exports.USER_AGENT.match(/OS (\d+)_/i);
            if (e && e[1]) return e[1];
          })()),
          (C.exports.IS_ANDROID = /Android/i.test(C.exports.USER_AGENT)),
          (C.exports.ANDROID_VERSION = (n = C.exports.USER_AGENT.match(
            /Android (\d+)(?:\.(\d+))?(?:\.(\d+))*/i
          ))
            ? ((r = n[1] && parseFloat(n[1])),
              (o = n[2] && parseFloat(n[2])),
              r && o ? parseFloat(n[1] + "." + n[2]) : r || null)
            : null),
          (C.exports.IS_OLD_ANDROID =
            C.exports.IS_ANDROID &&
            /webkit/i.test(C.exports.USER_AGENT) &&
            C.exports.ANDROID_VERSION < 2.3),
          (C.exports.TOUCH_ENABLED = !!(
            "ontouchstart" in window ||
            (window.DocumentTouch && document instanceof window.DocumentTouch)
          )),
          (C.exports.IS_MOBILE = C.exports.IS_IOS || C.exports.IS_ANDROID),
          (C.exports.IS_H5 = C.exports.IS_MOBILE || !C.exports.HAS_FLASH),
          (C.exports.IS_PC = !C.exports.IS_MOBILE),
          (C.exports.is_X5 =
            /micromessenger/i.test(C.exports.USER_AGENT) ||
            /qqbrowser/i.test(C.exports.USER_AGENT)),
          (C.exports.getHost = function (e) {
            var t = "";
            if (void 0 === e || null == e || "" == e) return "";
            var i = e.indexOf("//"),
              r = e;
            -1 < i && (r = e.substring(i + 2));
            t = r;
            var o = r.split("/");
            return (
              o && 0 < o.length && (t = o[0]),
              (o = t.split(":")) && 0 < o.length && (t = o[0]),
              t
            );
          }),
          (C.exports.dingTalk = function () {
            var e = C.exports.USER_AGENT.toLowerCase();
            return /dingtalk/i.test(e);
          }),
          (C.exports.wechat = function () {
            var e = C.exports.USER_AGENT.toLowerCase();
            return /micromessenger/i.test(e);
          }),
          (C.exports.inIFrame = function () {
            return self != top;
          }),
          (C.exports.getReferer = function () {
            var t = document.referrer;
            if (C.exports.inIFrame())
              try {
                t = top.document.referrer;
              } catch (e) {
                t = document.referrer;
              }
            return t;
          }),
          (C.exports.getHref = function () {
            location.href;
            if (C.exports.inIFrame())
              try {
                top.location.href;
              } catch (e) {
                location.href;
              }
            return location.href;
          }),
          (a = C.exports),
          function (e, t) {
            var i = (this.os = {}),
              r = (this.browser = {}),
              o = e.match(/Web[kK]it[\/]{0,1}([\d.]+)/),
              n = e.match(/(Android);?[\s\/]+([\d.]+)?/),
              a = !!e.match(/\(Macintosh\; Intel /),
              s = e.match(/(iPad).*OS\s([\d_]+)/),
              l = e.match(/(iPod)(.*OS\s([\d_]+))?/),
              u = !s && e.match(/(iPhone\sOS)\s([\d_]+)/),
              c = e.match(/(webOS|hpwOS)[\s\/]([\d.]+)/),
              d = /Win\d{2}|Windows/.test(t),
              p = e.match(/Windows Phone ([\d.]+)/),
              h = c && e.match(/TouchPad/),
              f = e.match(/Kindle\/([\d.]+)/),
              _ = e.match(/Silk\/([\d._]+)/),
              g = e.match(/(BlackBerry).*Version\/([\d.]+)/),
              y = e.match(/(BB10).*Version\/([\d.]+)/),
              v = e.match(/(RIM\sTablet\sOS)\s([\d.]+)/),
              m = e.match(/PlayBook/),
              S = e.match(/Chrome\/([\d.]+)/) || e.match(/CriOS\/([\d.]+)/),
              T = e.match(/Firefox\/([\d.]+)/),
              b = e.match(
                /\((?:Mobile|Tablet); rv:([\d.]+)\).*Firefox\/[\d.]+/
              ),
              x =
                e.match(/MSIE\s([\d.]+)/) ||
                e.match(/Trident\/[\d](?=[^\?]+).*rv:([0-9.].)/),
              E = !S && e.match(/(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/),
              P =
                E ||
                e.match(
                  /Version\/([\d.]+)([^S](Safari)|[^M]*(Mobile)[^S]*(Safari))/
                );
            if (
              ((r.webkit = !!o) && (r.version = o[1]),
              n && ((i.android = !0), (i.version = n[2])),
              u &&
                !l &&
                ((i.ios = i.iphone = !0),
                (i.version = u[2].replace(/_/g, "."))),
              s &&
                ((i.ios = i.ipad = !0), (i.version = s[2].replace(/_/g, "."))),
              l &&
                ((i.ios = i.ipod = !0),
                (i.version = l[3] ? l[3].replace(/_/g, ".") : null)),
              p && ((i.wp = !0), (i.version = p[1])),
              c && ((i.webos = !0), (i.version = c[2])),
              h && (i.touchpad = !0),
              g && ((i.blackberry = !0), (i.version = g[2])),
              y && ((i.bb10 = !0), (i.version = y[2])),
              v && ((i.rimtabletos = !0), (i.version = v[2])),
              m && (r.playbook = !0),
              f && ((i.kindle = !0), (i.version = f[1])),
              _ && ((r.silk = !0), (r.version = _[1])),
              !_ && i.android && e.match(/Kindle Fire/) && (r.silk = !0),
              S && ((r.chrome = !0), (r.version = S[1])),
              T && ((r.firefox = !0), (r.version = T[1])),
              b && ((i.firefoxos = !0), (i.version = b[1])),
              x && ((r.ie = !0), (r.version = x[1])),
              P &&
                (a || i.ios || d || n) &&
                ((r.safari = !0), i.ios || (r.version = P[1])),
              E && (r.webview = !0),
              a)
            ) {
              var w = e.match(/[\d]*_[\d]*_[\d]*/);
              w &&
                0 < w.length &&
                w[0] &&
                (i.version = w[0].replace(/_/g, "."));
            }
            (i.tablet = !!(
              s ||
              m ||
              (n && !e.match(/Mobile/)) ||
              (T && e.match(/Tablet/)) ||
              (x && !e.match(/Phone/) && e.match(/Touch/))
            )),
              (i.phone = !(
                i.tablet ||
                i.ipod ||
                !(
                  n ||
                  u ||
                  c ||
                  g ||
                  y ||
                  (S && e.match(/Android/)) ||
                  (S && e.match(/CriOS\/([\d.]+)/)) ||
                  (T && e.match(/Mobile/)) ||
                  (x && e.match(/Touch/))
                )
              )),
              (i.pc = !i.tablet && !i.phone),
              a
                ? (i.name = "macOS")
                : d
                ? ((i.name = "windows"),
                  (i.version = (function () {
                    var e = navigator.userAgent,
                      t = "";
                    return (
                      (-1 < e.indexOf("Windows NT 5.0") ||
                        -1 < e.indexOf("Windows 2000")) &&
                        (t = "2000"),
                      (-1 < e.indexOf("Windows NT 5.1") ||
                        -1 < e.indexOf("Windows XP")) &&
                        (t = "XP"),
                      (-1 < e.indexOf("Windows NT 5.2") ||
                        -1 < e.indexOf("Windows 2003")) &&
                        (t = "2003"),
                      (-1 < e.indexOf("Windows NT 6.0") ||
                        -1 < e.indexOf("Windows Vista")) &&
                        (t = "Vista"),
                      (-1 < e.indexOf("Windows NT 6.1") ||
                        -1 < e.indexOf("Windows 7")) &&
                        (t = "7"),
                      (-1 < e.indexOf("Windows NT 6.2") ||
                        -1 < e.indexOf("Windows 8")) &&
                        (t = "8"),
                      (-1 < e.indexOf("Windows NT 6.3") ||
                        -1 < e.indexOf("Windows 8.1")) &&
                        (t = "8.1"),
                      (-1 < e.indexOf("Windows NT 10") ||
                        -1 < e.indexOf("Windows 10")) &&
                        (t = "10"),
                      t
                    );
                  })()))
                : (i.name = (function () {
                    var e = navigator.userAgent,
                      t = "other",
                      i = C.exports.os;
                    if (i.ios) return "iOS";
                    if (i.android) return "android";
                    if (-1 < e.indexOf("Baiduspider")) return "Baiduspider";
                    if (-1 < e.indexOf("PlayStation")) return "PS4";
                    var r =
                        "Win32" == navigator.platform ||
                        "Windows" == navigator.platform ||
                        -1 < e.indexOf("Windows"),
                      o =
                        "Mac68K" == navigator.platform ||
                        "MacPPC" == navigator.platform ||
                        "Macintosh" == navigator.platform ||
                        "MacIntel" == navigator.platform;
                    return (
                      o && (t = "macOS"),
                      "X11" != navigator.platform || r || o || (t = "Unix"),
                      -1 < String(navigator.platform).indexOf("Linux") &&
                        (t = "Linux"),
                      r ? "windows" : t
                    );
                  })()),
              (r.name = (function () {
                var e = navigator.userAgent.toLowerCase(),
                  t = C.exports.browser;
                return t.firefox
                  ? "Firefox"
                  : t.ie
                  ? /edge/.test(e)
                    ? "Edge"
                    : "IE"
                  : /micromessenger/.test(e)
                  ? "\u5fae\u4fe1\u5185\u7f6e\u6d4f\u89c8\u5668"
                  : /qqbrowser/.test(e)
                  ? "QQ\u6d4f\u89c8\u5668"
                  : t.webview
                  ? "webview"
                  : t.chrome
                  ? "Chrome"
                  : t.safari
                  ? "Safari"
                  : /baiduspider/.test(e)
                  ? "Baiduspider"
                  : /ucweb/.test(e) || /UCBrowser/.test(e)
                  ? "UC"
                  : /opera/.test(e)
                  ? "Opera"
                  : /ucweb/.test(e)
                  ? "UC"
                  : /360se/.test(e)
                  ? "360\u6d4f\u89c8\u5668"
                  : /bidubrowser/.test(e)
                  ? "\u767e\u5ea6\u6d4f\u89c8\u5668"
                  : /metasr/.test(e)
                  ? "\u641c\u72d7\u6d4f\u89c8\u5668"
                  : /lbbrowser/.test(e)
                  ? "\u730e\u8c79\u6d4f\u89c8\u5668"
                  : /playstation/.test(e)
                  ? "PS4\u6d4f\u89c8\u5668"
                  : void 0;
              })());
          }.call(a, navigator.userAgent, navigator.platform);
      },
      {},
    ],
    32: [
      function (e, t, i) {
        var s = e("./dom");
        (t.exports.getAbsoluteURL = function (e) {
          return (
            e.match(/^https?:\/\//) ||
              (e = s.createEl("div", { innerHTML: '<a href="' + e + '">x</a>' })
                .firstChild.href),
            e
          );
        }),
          (t.exports.parseUrl = function (e) {
            var t, i, r, o, n;
            (o = [
              "protocol",
              "hostname",
              "port",
              "pathname",
              "search",
              "hash",
              "host",
            ]),
              (r =
                "" === (i = s.createEl("a", { href: e })).host &&
                "file:" !== i.protocol) &&
                (((t = s.createEl("div")).innerHTML =
                  '<a href="' + e + '"></a>'),
                (i = t.firstChild),
                t.setAttribute("style", "display:none; position:absolute;"),
                document.body.appendChild(t)),
              (n = {});
            for (var a = 0; a < o.length; a++) n[o[a]] = i[o[a]];
            return (
              (n.segments = i.pathname.replace(/^\//, "").split("/")),
              r && document.body.removeChild(t),
              n
            );
          });
      },
      { "./dom": 18 },
    ],
    33: [
      function (e, r, t) {
        var i = e("./dom"),
          o = e("./ua"),
          n = e("./playerutil");
        (r.exports.formatTime = function (e) {
          var t,
            i,
            r,
            o = Math.floor(e);
          return (
            (t = Math.floor(o / 3600)),
            (o %= 3600),
            (i = Math.floor(o / 60)),
            (r = o % 60),
            !(
              t === 1 / 0 ||
              isNaN(t) ||
              i === 1 / 0 ||
              isNaN(i) ||
              r === 1 / 0 ||
              isNaN(r)
            ) &&
              ("00" === (t = 10 <= t ? t : "0" + t) ? "" : t + ":") +
                (i = 10 <= i ? i : "0" + i) +
                ":" +
                (r = 10 <= r ? r : "0" + r)
          );
        }),
          (r.exports.extractTime = function (e) {
            if (e) {
              var t = parseInt(e.getHours()),
                i = parseInt(e.getMinutes()),
                r = parseInt(e.getSeconds());
              return (
                ("00" === (t = 10 <= t ? t : "0" + t) ? "" : t + ":") +
                (i = 10 <= i ? i : "0" + i) +
                ":" +
                (r = 10 <= r ? r : "0" + r)
              );
            }
            return "";
          }),
          (r.exports.convertToTimestamp = function (e, t) {
            var i = "";
            return (
              e && (t ? (i = e.gettime()) : ((i = Date.parse(e)), (i /= 1e3))),
              i
            );
          }),
          (r.exports.convertToDate = function (e, t) {
            var i = "";
            if (e) {
              t || 1e3, (i = new Date()).setTime(1e3 * e);
            }
            return i;
          }),
          (r.exports.parseTime = function (e) {
            if (!e) return "00:00:00";
            var t = e.split(":"),
              i = 0,
              r = 0,
              o = 0;
            return (
              3 === t.length
                ? ((i = t[0]), (r = t[1]), (o = t[2]))
                : 2 === t.length
                ? ((r = t[0]), (o = t[1]))
                : 1 === t.length && (o = t[0]),
              3600 * (i = parseInt(i, 10)) +
                60 * (r = parseInt(r, 10)) +
                (o = Math.ceil(parseFloat(o)))
            );
          }),
          (r.exports.formatDate = function (e, t) {
            var i = {
              "M+": e.getMonth() + 1,
              "d+": e.getDate(),
              "H+": e.getHours(),
              "m+": e.getMinutes(),
              "s+": e.getSeconds(),
              "q+": Math.floor((e.getMonth() + 3) / 3),
              S: e.getMilliseconds(),
            };
            for (var r in (/(y+)/.test(t) &&
              (t = t.replace(
                RegExp.$1,
                (e.getFullYear() + "").substr(4 - RegExp.$1.length)
              )),
            i))
              new RegExp("(" + r + ")").test(t) &&
                (t = t.replace(
                  RegExp.$1,
                  1 == RegExp.$1.length
                    ? i[r]
                    : ("00" + i[r]).substr(("" + i[r]).length)
                ));
            return t;
          }),
          (r.exports.sleep = function (e) {
            for (var t = Date.now(); Date.now() - t <= e; );
          }),
          (r.exports.htmlEncodeAll = function (e) {
            return null == e
              ? ""
              : e
                  .replace(/\</g, "&lt;")
                  .replace(/\>/g, "&gt;")
                  .replace(/\&/g, "&amp;")
                  .replace(/"/g, "&quot;")
                  .replace(/'/g, "&apos;");
          }),
          (r.exports.toBinary = function (e) {
            if (!window.atob) return "";
            for (
              var t = atob(e), i = t.length, r = new Uint8Array(i), o = 0;
              o < i;
              o++
            )
              r[o] = t.charCodeAt(o);
            return r;
          }),
          (r.exports.readyBinary = function (e) {
            for (
              var t = new Uint8Array(e), i = t.length, r = "", o = 0;
              o < i;
              o++
            )
              r += t[o];
            return r;
          }),
          (r.exports.delayHide = function (e, t) {
            e &&
              (void 0 === t && (t = 1e3),
              e.delayHanlder && clearTimeout(e.delayHanlder),
              (e.delayHanlder = setTimeout(function () {
                i.css(e, "display", "none");
              }, t)));
          }),
          (r.exports.openInFile = function () {
            return -1 != window.location.protocol.toLowerCase().indexOf("file");
          }),
          (r.exports.contentProtocolMixed = function (e) {
            return !!(
              o.os.pc &&
              ((n.isHls(e) && !o.browser.safari) || n.isFlv(e)) &&
              "https:" == window.location.protocol.toLowerCase() &&
              e &&
              -1 < e.toLowerCase().indexOf("http://")
            );
          }),
          (r.exports.queryString = function (e) {
            var t, i, r, o, n;
            return 2 !== (i = (e = decodeURIComponent(e)).split("?")).length
              ? {}
              : ((n = i[1]),
                (t = n.split("&"))
                  ? ((r = {}),
                    (o = 0),
                    $(t).each(function () {
                      var e;
                      2 === (e = t[o].split("=")).length &&
                        (r[e[0]] = e[1].replace(/\+/g, " ")),
                        o++;
                    }),
                    r)
                  : {});
          }),
          (r.exports.log = function (e) {
            var t = window.location.href,
              i = r.exports.queryString(t);
            i && 1 == i.debug && console.log(e);
          });
      },
      { "./dom": 18, "./playerutil": 29, "./ua": 31 },
    ],
    34: [
      function (e, t, i) {
        var s = e("./vttparse"),
          l = function (e) {
            for (var t = 5381, i = e.length; i; )
              t = (33 * t) ^ e.charCodeAt(--i);
            return (t >>> 0).toString();
          },
          r = {
            parse: function (e, t, i) {
              var r,
                o = e
                  .trim()
                  .replace(/\r\n|\n\r|\n|\r/g, "\n")
                  .split("\n"),
                n = [],
                a = new s();
              (a.oncue = function (e) {
                (e.id = l(e.startTime) + l(e.endTime) + l(e.text)),
                  (e.text = decodeURIComponent(escape(e.text))),
                  (e.isBig = !1);
                var t = e.text.split("#xywh=");
                if (2 == t.length) {
                  var i = t[1].split(",");
                  (e.x = i[0]),
                    (e.y = i[1]),
                    (e.w = i[2]),
                    (e.h = i[3]),
                    (e.isBig = !0);
                }
                0 < e.endTime && n.push(e);
              }),
                (a.onparsingerror = function (e) {
                  r = e;
                }),
                (a.onflush = function () {
                  if (r && i) return i(r), void console.log(r);
                  t(n);
                }),
                o.forEach(function (e) {
                  a.parse(e + "\n");
                }),
                a.flush();
            },
          };
        t.exports = r;
      },
      { "./vttparse": 36 },
    ],
    35: [
      function (e, t, i) {
        t.exports = (function () {
          if ("undefined" != typeof window && window.VTTCue)
            return window.VTTCue;
          var S = { "": !0, lr: !0, rl: !0 },
            t = { start: !0, middle: !0, end: !0, left: !0, right: !0 };
          function T(e) {
            return (
              "string" == typeof e && !!t[e.toLowerCase()] && e.toLowerCase()
            );
          }
          function b(e) {
            for (var t = 1; t < arguments.length; t++) {
              var i = arguments[t];
              for (var r in i) e[r] = i[r];
            }
            return e;
          }
          function e(e, t, i) {
            var r = this,
              o = (function () {
                if ("undefined" != typeof navigator)
                  return /MSIE\s8\.0/.test(navigator.userAgent);
              })(),
              n = {};
            o ? (r = document.createElement("custom")) : (n.enumerable = !0),
              (r.hasBeenReset = !1);
            var a = "",
              s = !1,
              l = e,
              u = t,
              c = i,
              d = null,
              p = "",
              h = !0,
              f = "auto",
              _ = "start",
              g = 50,
              y = "middle",
              v = 50,
              m = "middle";
            if (
              (Object.defineProperty(
                r,
                "id",
                b({}, n, {
                  get: function () {
                    return a;
                  },
                  set: function (e) {
                    a = "" + e;
                  },
                })
              ),
              Object.defineProperty(
                r,
                "pauseOnExit",
                b({}, n, {
                  get: function () {
                    return s;
                  },
                  set: function (e) {
                    s = !!e;
                  },
                })
              ),
              Object.defineProperty(
                r,
                "startTime",
                b({}, n, {
                  get: function () {
                    return l;
                  },
                  set: function (e) {
                    if ("number" != typeof e)
                      throw new TypeError(
                        "Start time must be set to a number."
                      );
                    (l = e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "endTime",
                b({}, n, {
                  get: function () {
                    return u;
                  },
                  set: function (e) {
                    if ("number" != typeof e)
                      throw new TypeError("End time must be set to a number.");
                    (u = e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "text",
                b({}, n, {
                  get: function () {
                    return c;
                  },
                  set: function (e) {
                    (c = "" + e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "region",
                b({}, n, {
                  get: function () {
                    return d;
                  },
                  set: function (e) {
                    (d = e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "vertical",
                b({}, n, {
                  get: function () {
                    return p;
                  },
                  set: function (e) {
                    var t = (function (e) {
                      return (
                        "string" == typeof e &&
                        !!S[e.toLowerCase()] &&
                        e.toLowerCase()
                      );
                    })(e);
                    if (!1 === t)
                      throw new SyntaxError(
                        "An invalid or illegal string was specified."
                      );
                    (p = t), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "snapToLines",
                b({}, n, {
                  get: function () {
                    return h;
                  },
                  set: function (e) {
                    (h = !!e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "line",
                b({}, n, {
                  get: function () {
                    return f;
                  },
                  set: function (e) {
                    if ("number" != typeof e && "auto" !== e)
                      throw new SyntaxError(
                        "An invalid number or illegal string was specified."
                      );
                    (f = e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "lineAlign",
                b({}, n, {
                  get: function () {
                    return _;
                  },
                  set: function (e) {
                    var t = T(e);
                    if (!t)
                      throw new SyntaxError(
                        "An invalid or illegal string was specified."
                      );
                    (_ = t), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "position",
                b({}, n, {
                  get: function () {
                    return g;
                  },
                  set: function (e) {
                    if (e < 0 || 100 < e)
                      throw new Error("Position must be between 0 and 100.");
                    (g = e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "positionAlign",
                b({}, n, {
                  get: function () {
                    return y;
                  },
                  set: function (e) {
                    var t = T(e);
                    if (!t)
                      throw new SyntaxError(
                        "An invalid or illegal string was specified."
                      );
                    (y = t), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "size",
                b({}, n, {
                  get: function () {
                    return v;
                  },
                  set: function (e) {
                    if (e < 0 || 100 < e)
                      throw new Error("Size must be between 0 and 100.");
                    (v = e), (this.hasBeenReset = !0);
                  },
                })
              ),
              Object.defineProperty(
                r,
                "align",
                b({}, n, {
                  get: function () {
                    return m;
                  },
                  set: function (e) {
                    var t = T(e);
                    if (!t)
                      throw new SyntaxError(
                        "An invalid or illegal string was specified."
                      );
                    (m = t), (this.hasBeenReset = !0);
                  },
                })
              ),
              (r.displayState = void 0),
              o)
            )
              return r;
          }
          return (
            (e.prototype.getCueAsHTML = function () {
              return window.WebVTT.convertCueToDOMTree(window, this.text);
            }),
            e
          );
        })();
      },
      {},
    ],
    36: [
      function (e, t, i) {
        var s = e("./vttcue"),
          r = function () {
            return {
              decode: function (e) {
                if (!e) return "";
                if ("string" != typeof e)
                  throw new Error("Error - expected string data.");
                return decodeURIComponent(encodeURIComponent(e));
              },
            };
          };
        function o() {
          (this.window = window),
            (this.state = "INITIAL"),
            (this.buffer = ""),
            (this.decoder = new r()),
            (this.regionList = []);
        }
        function l() {
          this.values = Object.create(null);
        }
        function u(e, t, i, r) {
          var o = r ? e.split(r) : [e];
          for (var n in o)
            if ("string" == typeof o[n]) {
              var a = o[n].split(i);
              if (2 === a.length) t(a[0], a[1]);
            }
        }
        l.prototype = {
          set: function (e, t) {
            this.get(e) || "" === t || (this.values[e] = t);
          },
          get: function (e, t, i) {
            return i
              ? this.has(e)
                ? this.values[e]
                : t[i]
              : this.has(e)
              ? this.values[e]
              : t;
          },
          has: function (e) {
            return e in this.values;
          },
          alt: function (e, t, i) {
            for (var r = 0; r < i.length; ++r)
              if (t === i[r]) {
                this.set(e, t);
                break;
              }
          },
          integer: function (e, t) {
            /^-?\d+$/.test(t) && this.set(e, parseInt(t, 10));
          },
          percent: function (e, t) {
            return (
              !!(
                t.match(/^([\d]{1,3})(\.[\d]*)?%$/) &&
                0 <= (t = parseFloat(t)) &&
                t <= 100
              ) && (this.set(e, t), !0)
            );
          },
        };
        var c = new s(0, 0, 0),
          d = "middle" === c.align ? "middle" : "center";
        function p(t, e, a) {
          var i = t;
          function r() {
            var e = (function (e) {
              function t(e, t, i, r) {
                return 3600 * (0 | e) + 60 * (0 | t) + (0 | i) + (0 | r) / 1e3;
              }
              var i = e.match(/^(\d+):(\d{2})(:\d{2})?(\.\d{3})?/);
              if (!i) return null;
              var r = i[4];
              return (
                r && (r = r.replace(".", "")),
                i[3]
                  ? t(i[1], i[2], i[3].replace(":", ""), r)
                  : 59 < i[1]
                  ? t(i[1], i[2], 0, r)
                  : t(0, i[1], i[2], r)
              );
            })(t);
            if (null === e) throw new Error("Malformed timestamp: " + i);
            return (t = t.replace(/^[^\sa-zA-Z-]+/, "")), e;
          }
          function o() {
            t = t.replace(/^\s+/, "");
          }
          if ((o(), (e.startTime = r()), o(), "--\x3e" !== t.substr(0, 3)))
            throw new Error(
              "Malformed time stamp (time stamps must be separated by '--\x3e'): " +
                i
            );
          (t = t.substr(3)),
            o(),
            (e.endTime = r()),
            o(),
            (function (e, t) {
              var n = new l();
              u(
                e,
                function (e, t) {
                  switch (e) {
                    case "region":
                      for (var i = a.length - 1; 0 <= i; i--)
                        if (a[i].id === t) {
                          n.set(e, a[i].region);
                          break;
                        }
                      break;
                    case "vertical":
                      n.alt(e, t, ["rl", "lr"]);
                      break;
                    case "line":
                      var r = t.split(","),
                        o = r[0];
                      n.integer(e, o),
                        n.percent(e, o) && n.set("snapToLines", !1),
                        n.alt(e, o, ["auto"]),
                        2 === r.length &&
                          n.alt("lineAlign", r[1], ["start", d, "end"]);
                      break;
                    case "position":
                      (r = t.split(",")),
                        n.percent(e, r[0]),
                        2 === r.length &&
                          n.alt("positionAlign", r[1], [
                            "start",
                            d,
                            "end",
                            "line-left",
                            "line-right",
                            "auto",
                          ]);
                      break;
                    case "size":
                      n.percent(e, t);
                      break;
                    case "align":
                      n.alt(e, t, ["start", d, "end", "left", "right"]);
                  }
                },
                /:/,
                /\s/
              ),
                (t.region = n.get("region", null)),
                (t.vertical = n.get("vertical", ""));
              var i = n.get("line", "auto");
              "auto" === i && -1 === c.line && (i = -1),
                (t.line = i),
                (t.lineAlign = n.get("lineAlign", "start")),
                (t.snapToLines = n.get("snapToLines", !0)),
                (t.size = n.get("size", 100)),
                (t.align = n.get("align", d));
              var r = n.get("position", "auto");
              "auto" === r &&
                50 === c.position &&
                (r =
                  "start" === t.align || "left" === t.align
                    ? 0
                    : "end" === t.align || "right" === t.align
                    ? 100
                    : 50),
                (t.position = r);
            })(t, e);
        }
        (o.prototype = {
          parse: function (e) {
            var r = this;
            function t() {
              var e = r.buffer,
                t = 0;
              for (
                e = (function (e) {
                  return e.replace(/<br(?: \/)?>/gi, "\n");
                })(e);
                t < e.length && "\r" !== e[t] && "\n" !== e[t];

              )
                ++t;
              var i = e.substr(0, t);
              return (
                "\r" === e[t] && ++t,
                "\n" === e[t] && ++t,
                (r.buffer = e.substr(t)),
                i
              );
            }
            e && (r.buffer += r.decoder.decode(e, { stream: !0 }));
            try {
              var i;
              if ("INITIAL" === r.state) {
                if (!/\r\n|\n/.test(r.buffer)) return this;
                var o = (i = t()).match(/^WEBVTT([ \t].*)?$/);
                if (!o || !o[0]) throw new Error("Malformed WebVTT signature.");
                r.state = "HEADER";
              }
              for (var n = !1; r.buffer; ) {
                if (!/\r\n|\n/.test(r.buffer)) return this;
                switch ((n ? (n = !1) : (i = t()), r.state)) {
                  case "HEADER":
                    /:/.test(i)
                      ? u(
                          i,
                          function (e, t) {
                            switch (e) {
                              case "Region":
                                console.log("parse region", t);
                            }
                          },
                          /:/
                        )
                      : i || (r.state = "ID");
                    continue;
                  case "NOTE":
                    i || (r.state = "ID");
                    continue;
                  case "ID":
                    if (/^NOTE($|[ \t])/.test(i)) {
                      r.state = "NOTE";
                      break;
                    }
                    if (!i) continue;
                    if (
                      ((r.cue = new s(0, 0, "")),
                      (r.state = "CUE"),
                      -1 === i.indexOf("--\x3e"))
                    ) {
                      r.cue.id = i;
                      continue;
                    }
                  case "CUE":
                    try {
                      p(i, r.cue, r.regionList);
                    } catch (e) {
                      (r.cue = null), (r.state = "BADCUE");
                      continue;
                    }
                    r.state = "CUETEXT";
                    continue;
                  case "CUETEXT":
                    var a = -1 !== i.indexOf("--\x3e");
                    if (!i || (a && (n = !0))) {
                      r.oncue && r.oncue(r.cue),
                        (r.cue = null),
                        (r.state = "ID");
                      continue;
                    }
                    r.cue.text && (r.cue.text += "\n"), (r.cue.text += i);
                    continue;
                  case "BADCUE":
                    i || (r.state = "ID");
                    continue;
                }
              }
            } catch (e) {
              "CUETEXT" === r.state && r.cue && r.oncue && r.oncue(r.cue),
                (r.cue = null),
                (r.state = "INITIAL" === r.state ? "BADWEBVTT" : "BADCUE");
            }
            return this;
          },
          flush: function () {
            var e = this;
            try {
              if (
                ((e.buffer += e.decoder.decode()),
                (e.cue || "HEADER" === e.state) &&
                  ((e.buffer += "\n\n"), e.parse()),
                "INITIAL" === e.state)
              )
                throw new Error("Malformed WebVTT signature.");
            } catch (e) {
              throw e;
            }
            return e.onflush && e.onflush(), this;
          },
        }),
          (t.exports = o);
      },
      { "./vttcue": 35 },
    ],
    37: [
      function (e, t, i) {
        var o = e("../lib/io");
        e("../lib/storage");
        function r(e) {
          (this._uploadDuration = e.logDuration || 5),
            (this._uploadCount = e.logCount || 10),
            (this._logReportTo = e.logReportTo),
            (this._logs = []),
            (this._retry = 0),
            (this._disposed = !1),
            (this._supportLocalStorage = !0);
          var t = this;
          window &&
            (window.onbeforeunload = function (e) {
              if (0 < t._logs.length)
                if (t._supportLocalStorage)
                  localStorage.setItem(
                    "__aliplayer_log_data",
                    JSON.stringify(t._logs)
                  );
                else {
                  t._report();
                  !(function (e) {
                    for (var t = new Date().getTime(), i = t; i < t + e; )
                      i = new Date().getTime();
                  })(500);
                }
            });
          try {
            if (localStorage) {
              var i = localStorage.getItem("__aliplayer_log_data");
              localStorage.removeItem("__aliplayer_log_data"),
                i && (this._logs = JSON.parse(i));
            } else this._supportLocalStorage = !1;
          } catch (e) {
            this._supportLocalStorage = !1;
          }
          this._start();
        }
        (r.prototype.add = function (e) {
          var t = this._logs.length;
          if (
            ((e.__time__ = Math.round(new Date() / 1e3)),
            0 < t && "4001" == e.e)
          ) {
            var i = this._logs[t - 1];
            if ("4001" == i.e && i.__time__ - e.__time__ < 5) return;
          }
          this._logs.push(e),
            (this._logs.length > this._uploadCount ||
              "4001" == e.e ||
              "2002" == e.e) &&
              this._report();
        }),
          (r.prototype.dispose = function () {
            this._report(), (this._disposed = !0);
          }),
          (r.prototype._start = function () {
            this._disposed = !1;
            (this._retry = 0), this._report();
          }),
          (r.prototype._report = function (t) {}),
          (r.prototype._tick = function () {
            if (!this._disposed) {
              this._retry = 0;
              var e = this;
              this._logs.length > this._uploadCount
                ? e._report()
                : (this._tickHandler = setTimeout(function () {
                    e._report();
                  }, 1e3 * this._uploadDuration));
            }
          }),
          (t.exports = r);
      },
      { "../lib/io": 24, "../lib/storage": 30 },
    ],
    38: [
      function (e, t, i) {
        var r = e("../lib/oo"),
          u = e("../lib/object"),
          v = e("../lib/data"),
          c = e("../lib/io"),
          m = e("../lib/ua"),
          S = e("../config"),
          o = e("../player/base/event/eventtype"),
          T = e("./util"),
          b = e("./log"),
          n = 0,
          d = {
            STARTFETCHDATA: 1003,
            COMPLETEFETCHDATA: 1004,
            PREPARE: 1101,
            PREPAREEND: 1102,
            STARTPLAY: 2e3,
            PLAY: 2001,
            STOP: 2002,
            PAUSE: 2003,
            SEEK: 2004,
            FULLSREEM: 2005,
            QUITFULLSCREEM: 2006,
            RESOLUTION: 2007,
            RESOLUTION_DONE: 2008,
            RECOVER: 2010,
            SEEK_END: 2011,
            FETCHEDIP: 2020,
            CDNDETECT: 2021,
            DETECT: 2022,
            UNDERLOAD: 3002,
            LOADED: 3001,
            HEARTBEAT: 9001,
            ERROR: 4001,
            ERRORRETRY: 4002,
            SNAPSHOT: 2027,
            ROTATE: 2028,
            IMAGE: 2029,
            THUMBNAILSTART: 2031,
            THUMBNAILCOMPLETE: 2032,
            CCSTART: 2033,
            CCCOMPLETE: 2034,
            AUDIOTRACKSTART: 2033,
            AUDIOTRACKCOMPLETE: 2034,
          },
          a = r.extend({
            init: function (e, t, i) {
              void 0 === i && (i = !0),
                (this.trackLog = i),
                (this.player = e),
                (this.requestId = ""),
                (this.sessionId = v.guid()),
                (this.playId = 0),
                (this.firstPlay = !0),
                (this.osName = m.os.name),
                (this.osVersion = m.os.version || ""),
                (this.exName = m.browser.name),
                (this.exVersion = m.browser.version || ""),
                (this._logService = ""),
                t.logBatched && (this._logService = new b(S));
              var r = this.player.getOptions(),
                o = t.from ? t.from : "",
                n = (r.isLive, r.isLive ? "live" : "vod"),
                a = "pc";
              m.IS_IPAD ? (a = "pad") : m.os.phone && (a = "phone");
              var s = this.encodeURL(m.getReferer()),
                l = m.getHref(),
                u = this.encodeURL(l),
                c = "";
              l && (c = m.getHost(l));
              var d = S.h5Version,
                p = T.getUuid(),
                h = r.source ? this.encodeURL(r.source) : "",
                f = m.getHost(r.source),
                _ = r.userId ? r.userId + "" : "0",
                g = this.sessionId,
                y = new Date().getTime();
              this._userNetInfo = { cdnIp: "", localIp: "" };
              (this.opt = {
                APIVersion: "0.6.0",
                t: y,
                ll: "info",
                lv: "1.0",
                pd: "player",
                md: "saas_player",
                ui: "saas_player",
                sm: "play",
                os: this.osName,
                ov: this.osVersion,
                et: this.exName,
                ev: this.exVersion,
                uat: m.USER_AGENT,
                hn: "0.0.0.0",
                bi: o,
                ri: g,
                e: "0",
                args: "0",
                vt: n,
                tt: a,
                dm: "h5",
                av: d,
                uuid: p,
                vu: h,
                vd: f,
                ua: _,
                dn: "custom",
                cdn_ip: "0.0.0.0",
                app_n: c,
                r: s,
                pu: u,
              }),
                this.bindEvent();
            },
            updateVideoInfo: function (e) {
              var t = e.from ? e.from : "";
              (this.opt.bi = t + ""), this.updateSourceInfo();
            },
            updateSourceInfo: function () {
              var e = this.player.getOptions();
              if (e) {
                var t = e.source ? this.encodeURL(e.source) : "",
                  i = m.getHost(e.source);
                (this.opt.vu = t), (this.opt.vd = i);
              }
            },
            replay: function () {
              this.reset(),
                this.player.trigger(o.Video.LoadStart),
                this.player.trigger(o.Video.LoadedMetadata),
                this.player.trigger(o.Video.LoadedData);
            },
            bindEvent: function () {
              var t = this;
              this.player.on(o.Player.Init, function () {
                t._onPlayerInit();
              }),
                this.player.on(o.Video.LoadStart, function () {
                  t._onPlayerloadstart();
                }),
                this.player.on(o.Video.LoadedMetadata, function () {
                  t._onPlayerLoadMetadata();
                }),
                this.player.on(o.Video.LoadedData, function () {
                  t._onPlayerLoaddata();
                }),
                this.player.on(o.Video.Play, function () {
                  t._onPlayerPlay();
                }),
                this.player.on(o.Video.Playing, function () {
                  t._onPlayerReady();
                }),
                this.player.on(o.Video.Ended, function () {
                  t._onPlayerFinish();
                }),
                this.player.on(o.Video.Pause, function () {
                  t._onPlayerPause();
                }),
                this.player.on(o.Private.SeekStart, function (e) {
                  t._onPlayerSeekStart(e);
                }),
                this.player.on(o.Private.EndStart, function (e) {
                  t._seekEndData = e.paramData;
                }),
                this.player.on(o.Player.Waiting, function () {
                  t._waitingDelayLoadingShowHandle &&
                    (clearTimeout(t._waitingDelayLoadingShowHandle),
                    (t._waitingDelayLoadingShowHandle = null)),
                    (t._waitingDelayLoadingShowHandle = setTimeout(function () {
                      t._onPlayerLoaded();
                    }, 1e3 * t.player._options.delayLoadingShow));
                }),
                this.player.on(o.Video.CanPlayThrough, function () {}),
                this.player.on(o.Video.CanPlay, function () {
                  t._waitingDelayLoadingShowHandle &&
                    (clearTimeout(t._waitingDelayLoadingShowHandle),
                    (t._waitingDelayLoadingShowHandle = null)),
                    t._onPlayerUnderload(),
                    t._onPlayerCanplay();
                }),
                this.player.on(o.Video.TimeUpdate, function () {
                  t._waitingDelayLoadingShowHandle &&
                    (clearTimeout(t._waitingDelayLoadingShowHandle),
                    (t._waitingDelayLoadingShowHandle = null)),
                    t._seekEndData && t.seeking && t._onPlayerSeekEnd();
                }),
                this.player.on(o.Player.Error, function () {
                  t._onPlayerError();
                }),
                this.player.on(o.Player.RequestFullScreen, function () {
                  t._onFullscreenChange(1);
                }),
                this.player.on(o.Player.CancelFullScreen, function () {
                  t._onFullscreenChange(0);
                }),
                this.player.on(o.Private.PREPARE, function (e) {
                  (t._prepareTime = new Date().getTime()),
                    t._log("PREPARE", { dn: e.paramData });
                }),
                this.player.on(o.Player.Snapshoted, function () {
                  t._log("SNAPSHOT");
                }),
                setInterval(function () {
                  if (t.player.getCurrentTime()) {
                    var e = Math.floor(1e3 * t.player.getCurrentTime());
                    t.player.paused() ||
                      (30 <= ++n &&
                        (t._log("HEARTBEAT", { vt: e, interval: 1e3 * n }),
                        (n = 0)));
                  }
                }, 1e3);
            },
            removeEvent: function () {
              this.player.off("init"),
                this.player.off("ready"),
                this.player.off("ended"),
                this.player.off("play"),
                this.player.off("pause"),
                this.player.off("seekStart"),
                this.player.off("seekEnd"),
                this.player.off("canplaythrough"),
                this.player.off("playing"),
                this.player.off("timeupdate"),
                this.player.off("error"),
                this.player.off("fullscreenchange"),
                this.player.off(o.Private.PREPARE),
                this._logService && this._logService.dispose();
            },
            reset: function () {
              (this.startTimePlay = 0),
                (this.buffer_flag = 0),
                (this.firstPlay = !1),
                (this.playId = 0),
                (this.loadstarted = 0),
                (this._LoadedData = 0),
                (this._canPlay = 0);
            },
            encodeURL: function (e) {
              if (!e) return "";
              var t = this.player.getOptions();
              return t && !t.logBatched ? encodeURIComponent(e) : e;
            },
            _onFullscreenChange: function (e) {
              e ? this._log("FULLSREEM", {}) : this._log("QUITFULLSCREEM", {});
            },
            _onPlayerloadstart: function () {
              (this.loadstartTime = new Date().getTime()),
                (this.playId = v.guid()),
                !this.loadstarted &&
                  this.player._isPreload() &&
                  ((this.loadstarted = 1),
                  this._log("STARTPLAY", { vt: new Date().getTime() }));
            },
            _onPlayerLoadMetadata: function () {
              this.loadMetaDataCost = new Date().getTime() - this.loadstartTime;
            },
            _onPlayerLoaddata: function () {
              if (!this._LoadedData && !this.buffer_flag) {
                var e = 0,
                  t = 0;
                this.player.tag &&
                  ((e = this.player.tag.videoWidth),
                  (t = this.player.tag.videoHeight)),
                  this._log("PREPAREEND", {
                    tc: new Date().getTime() - this._prepareTime,
                    cc: new Date().getTime() - this.loadstartTime,
                    md: this.loadMetaDataCost,
                    mi: JSON.stringify({
                      type: "video",
                      definition: e + "*" + t,
                    }),
                  });
              }
              this._LoadedData = 1;
            },
            _onPlayerCanplay: function () {
              (this._canPlay = 1), this._reportPlay();
            },
            _onPlayerInit: function () {
              (this.buffer_flag = 0),
                (this.pause_flag = 0),
                (this.startTimePlay = 0),
                (this.loadstarted = 0),
                (this._LoadedData = 0),
                (this._canPlay = 0);
            },
            _onPlayerReady: function () {
              this.startTimePlay || (this.startTimePlay = new Date().getTime());
            },
            _onPlayerFinish: function () {
              this._log("STOP", {
                vt: Math.floor(1e3 * this.player.getCurrentTime()),
              }),
                this.reset();
            },
            _reportPlay: function () {
              return (
                !(
                  this.buffer_flag ||
                  !this._LoadedData ||
                  !this.playstartTime
                ) &&
                ((this.first_play_time = new Date().getTime()),
                this._log("PLAY", {
                  dsm: "fix",
                  tc: this.first_play_time - this.loadstartTime,
                  fc: this.first_play_time - this.playstartTime,
                }),
                (this.buffer_flag = 1),
                !0)
              );
            },
            _onPlayerPlay: function () {
              (this.playstartTime = new Date().getTime()),
                0 == this.playId && (this.playId = v.guid()),
                this.firstPlay ||
                  0 != this.pause_flag ||
                  this.seeking ||
                  (this.sessionId = v.guid()),
                this.player._isPreload() ||
                  (this._log("STARTPLAY", { vt: new Date().getTime() }),
                  (this.loadstartTime = new Date().getTime())),
                (this._canPlay && this._reportPlay()) ||
                  (this.buffer_flag &&
                    this.pause_flag &&
                    ((this.pause_flag = 0),
                    (this.pauseEndTime = new Date().getTime()),
                    this._log("RECOVER", {
                      vt: Math.floor(1e3 * this.player.getCurrentTime()),
                      cost: this.pauseEndTime - this.pauseTime,
                    })));
            },
            _onPlayerPause: function () {
              this.buffer_flag &&
                this.startTimePlay &&
                (this.seeking ||
                  ((this.pause_flag = 1),
                  (this.pauseTime = new Date().getTime()),
                  this._log("PAUSE", {
                    vt: Math.floor(1e3 * this.player.getCurrentTime()),
                  })));
            },
            _onPlayerSeekStart: function (e) {
              (this.seekStartTime = e.paramData.fromTime),
                (this.seeking = !0),
                (this.startTimePlay = 0),
                (this.seekStartStamp = new Date().getTime());
            },
            _onPlayerSeekEnd: function () {
              (this.seekEndStamp = new Date().getTime()),
                this._log("SEEK", {
                  drag_from_timestamp: Math.floor(1e3 * this.seekStartTime),
                  drag_to_timestamp: Math.floor(1e3 * this._seekEndData.toTime),
                }),
                this._log("SEEK_END", {
                  vt: Math.floor(1e3 * this.player.getCurrentTime()),
                  cost: this.seekEndStamp - this.seekStartStamp,
                }),
                (this.seeking = !1),
                (this._seekEndData = null);
            },
            _onPlayerLoaded: function () {
              this.buffer_flag &&
                this.startTimePlay &&
                (this.stucking ||
                  this.seeking ||
                  ((this.stuckStartTime = new Date().getTime()),
                  this.stuckStartTime - this.startTimePlay <= 1e3 ||
                    ((this.stucking = !0),
                    this._log("UNDERLOAD", {
                      vt: Math.floor(1e3 * this.player.getCurrentTime()),
                    }),
                    (this.stuckStartTime = new Date().getTime()))));
            },
            _onPlayerUnderload: function () {
              if (
                (this.buffer_flag ||
                  !this.player._options ||
                  !this.player._options.autoplay) &&
                this.stucking &&
                !this.seeking
              ) {
                var e = Math.floor(1e3 * this.player.getCurrentTime()),
                  t = this.stuckStartTime || new Date().getTime(),
                  i = Math.floor(new Date().getTime() - t);
                0 < i && this._log("LOADED", { vt: e, cost: i }),
                  (this.stucking = !1);
              }
            },
            _onPlayerHeartBeat: function () {
              if (!this.seeking) {
                var e = Math.floor(1e3 * this.player.getCurrentTime()),
                  t = this;
                this.timer ||
                  (this.timer = setTimeout(function () {
                    !t.seeking && t._log("HEARTBEAT", { progress: e }),
                      clearTimeout(t.timer),
                      (t.timer = null);
                  }, 6e4)),
                  console.log("timeupdate");
              }
            },
            _onPlayerError: function () {
              (this.playId = 0),
                (this._LoadedData = 1),
                this.buffer_flag || this._reportPlay();
            },
            _log: function (e, t) {
              if (this.trackLog) {
                this.updateSourceInfo();
                var i = u.copy(this.opt);
                this.requestId = v.guid();
                var r = S.logReportTo;
                (i.e = d[e] + ""),
                  (i.ri = this.sessionId),
                  (i.t = new Date().getTime() + ""),
                  (i.cdn_ip = this._userNetInfo.cdnIp),
                  (i.hn = this._userNetInfo.localIp);
                var o = this.player.getCurrentQuality();
                "" != o && (i.definition = o.definition);
                var n = [];
                u.each(t, function (e, t) {
                  n.push(e + "=" + t);
                });
                var a = "",
                  s = this.player.getOptions();
                s && s.vid && (a = s.vid), n.push("vid=" + a);
                try {
                  Aliplayer &&
                    Aliplayer.__logCallback__ &&
                    ((i.args = n), Aliplayer.__logCallback__(i));
                } catch (e) {
                  console.log(e);
                }
                if (
                  ("" == (n = n.join("&")) && (n = "0"),
                  (i.args = this.encodeURL(n)),
                  this._logService)
                )
                  this._logService.add(i);
                else {
                  var l = [];
                  u.each(i, function (e, t) {
                    l.push(e + "=" + t);
                  }),
                    (l = l.join("&")),
                    c.jsonp(
                      r + "?" + l,
                      function () {},
                      function () {}
                    );
                }
                return this.sessionId;
              }
            },
          });
        t.exports = a;
      },
      {
        "../config": 5,
        "../lib/data": 17,
        "../lib/io": 24,
        "../lib/object": 26,
        "../lib/oo": 27,
        "../lib/ua": 31,
        "../player/base/event/eventtype": 43,
        "./log": 37,
        "./util": 39,
      },
    ],
    39: [
      function (e, t, i) {
        var r = e("../lib/cookie"),
          o = e("../lib/data"),
          n = e("../lib/ua");
        (t.exports.getUuid = function () {
          var e = r.get("p_h5_u");
          return e || ((e = o.guid()), r.set("p_h5_u", e, 730)), e;
        }),
          (t.exports.getTerminalType = function () {
            var e = "pc";
            return (
              n.IS_IPAD
                ? (e = "pad")
                : n.IS_ANDROID
                ? (e = "android")
                : n.IS_IOS && (e = "iphone"),
              e
            );
          }),
          (t.exports.returnUTCDate = function (e) {
            var t = e.getUTCFullYear(),
              i = e.getUTCMonth(),
              r = e.getUTCDate(),
              o = e.getUTCHours(),
              n = e.getUTCMinutes(),
              a = e.getUTCSeconds(),
              s = e.getUTCMilliseconds();
            return Date.UTC(t, i, r, o, n, a, s);
          }),
          (t.exports.getRfc822 = function (e) {
            return e.toUTCString().replace("UTC", "GMT");
          });
      },
      { "../lib/cookie": 16, "../lib/data": 17, "../lib/ua": 31 },
    ],
    40: [
      function (e, t, i) {
        var s = e("./base/player"),
          l = e("./flash/flashplayer"),
          u = e("./saas/mtsplayer"),
          c = e("./saas/player"),
          d = e("./taotv/taotvplayer"),
          p = e("./audio/audioplayer"),
          h = e("./hls/hlsplayer"),
          f = e("./flv/flvplayer"),
          _ = e("./drm/drmplayer"),
          g = e("../lib/ua"),
          y = e("../lib/playerutil"),
          v = (e("../lib/dom"), e("../lib/io"), e("../lang/index"));
        t.exports.create = function (e, t) {
          "function" != typeof t && (t = function () {}),
            (e.readyCallback = t),
            v.setCurrentLanguage(e.language, "h5", e.languageTexts);
          var i = y.handleOption(e),
            r = i.source,
            o = y.isAudio(r);
          o && (i.mediaType = "audio");
          var n,
            a = y.createWrapper(i);
          return a.player
            ? a.player
            : (o
                ? (n = new p(a, i))
                : !i.useFlashPrism && y.isFlv(r) && y.isSupportFlv()
                ? (n = new f(a, i))
                : g.IS_MOBILE || (!i.useFlashPrism && !y.isRTMP(r))
                ? i.vid && !i.source
                  ? (n = i.authInfo
                      ? new u(a, i)
                      : i.playauth || (i.accessKeyId && i.accessKeySecret)
                      ? new c(a, i)
                      : new d(a, i))
                  : y.isDash(r) && y.isSupportMSE()
                  ? (n = new _(a, i))
                  : y.isHls(r)
                  ? y.canPlayHls()
                    ? (n =
                        y.isSupportHls() &&
                        (y.isUsedHlsPluginOnMobile() ||
                          y.isSafariUsedHlsPlugin(i.useHlsPluginForSafari))
                          ? new h(a, i)
                          : new s(a, i))
                    : y.isSupportHls()
                    ? (n = new h(a, i))
                    : g.os.pc
                    ? i.userH5Prism || i.useH5Prism || (n = new l(a, i))
                    : (n = new s(a, i))
                  : (n = (g.os.pc, new s(a, i)))
                : (n = new l(a, i)),
              n);
        };
      },
      {
        "../lang/index": 11,
        "../lib/dom": 18,
        "../lib/io": 24,
        "../lib/playerutil": 29,
        "../lib/ua": 31,
        "./audio/audioplayer": 41,
        "./base/player": 62,
        "./drm/drmplayer": 69,
        "./flash/flashplayer": 70,
        "./flv/flvplayer": 72,
        "./hls/hlsplayer": 74,
        "./saas/mtsplayer": 78,
        "./saas/player": 84,
        "./taotv/taotvplayer": 93,
      },
    ],
    41: [
      function (e, t, i) {
        var r = e("../base/player"),
          o = e("../../ui/component"),
          n = e("../../lib/dom"),
          a = e("../../lib/object"),
          s = e("../../lib/playerutil"),
          l = r.extend({
            init: function (e, t) {
              (this._isAudio = !0),
                void 0 === t.skinLayout &&
                  (t.skinLayout = s.defaultAudioLayout),
                r.call(this, e, t);
            },
          });
        (l.prototype.createEl = function () {
          "AUDIO" !== this.tag.tagName &&
            ((this._el = this.tag),
            (this.tag = o.prototype.createEl.call(this, "audio")));
          var t = this._el,
            e = this.tag;
          e.player = this;
          var i = n.getElementAttributes(e);
          return (
            a.each(i, function (e) {
              t.setAttribute(e, i[e]);
            }),
            this.setVideoAttrs(),
            e.parentNode && e.parentNode.insertBefore(t, e),
            n.insertFirst(e, t),
            t
          );
        }),
          (t.exports = l);
      },
      {
        "../../lib/dom": 18,
        "../../lib/object": 26,
        "../../lib/playerutil": 29,
        "../../ui/component": 94,
        "../base/player": 62,
      },
    ],
    42: [
      function (e, t, i) {
        var a = e("../../../lib/event"),
          s = e("./eventtype"),
          r = e("../eventHandler/video/index"),
          o = e("../eventHandler/player/index");
        (t.exports.offAll = function (e) {
          var t = e.tag,
            i = e._el;
          for (var r in s.Video) a.off(t, s.Video[r]);
          for (var o in s.Player) a.off(i, s.Player[o]);
          for (var n in s.Private) a.off(i, s.Private[n]);
        }),
          (t.exports.onAll = function (e) {
            r.bind(e), o.bind(e);
          });
      },
      {
        "../../../lib/event": 19,
        "../eventHandler/player/index": 47,
        "../eventHandler/video/index": 56,
        "./eventtype": 43,
      },
    ],
    43: [
      function (e, t, i) {
        t.exports = {
          Video: {
            TimeUpdate: "timeupdate",
            Play: "play",
            Playing: "playing",
            Pause: "pause",
            CanPlay: "canplay",
            Waiting: "waiting",
            Ended: "ended",
            Error: "error",
            Suspend: "suspend",
            Stalled: "stalled",
            LoadStart: "loadstart",
            DurationChange: "durationchange",
            LoadedData: "loadeddata",
            LoadedMetadata: "loadedmetadata",
            Progress: "progress",
            CanPlayThrough: "canplaythrough",
            ContextMenu: "contextmenu",
            Seeking: "seeking",
            Seeked: "seeked",
            ManualEnded: "manualended",
          },
          Player: {
            TimeUpdate: "timeupdate",
            DurationChange: "durationchange",
            Init: "init",
            Ready: "ready",
            Play: "play",
            Pause: "pause",
            CanPlay: "canplay",
            Waiting: "waiting",
            Ended: "ended",
            Error: "error",
            RequestFullScreen: "requestFullScreen",
            CancelFullScreen: "cancelFullScreen",
            Snapshoted: "snapshoted",
            Snapshoting: "snapshoting",
            OnM3u8Retry: "onM3u8Retry",
            LiveStreamStop: "liveStreamStop",
            AutoPlayPrevented: "autoPlayPrevented",
            AutoPlay: "autoplay",
            StartSeek: "startSeek",
            CompleteSeek: "completeSeek",
            TextTrackReady: "textTrackReady",
            AudioTrackReady: "audioTrackReady",
            AudioTrackUpdated: "audioTrackUpdated",
            LevelsLoaded: "levelsLoaded",
            AudioTrackSwitch: "audioTrackSwitch",
            AudioTrackSwitched: "audioTrackSwitched",
            LevelSwitch: "levelSwitch",
            LevelSwitched: "levelSwitched",
            MarkerDotOver: "markerDotOver",
            MarkerDotOut: "markerDotOut",
          },
          Private: {
            Play_Btn_Show: "play_btn_show",
            UiH5Ready: "uiH5Ready",
            Error_Hide: "error_hide",
            Error_Show: "error_show",
            Info_Show: "info_show",
            Info_Hide: "info_hide",
            H5_Loading_Show: "h5_loading_show",
            H5_Loading_Hide: "h5_loading_hide",
            HideProgress: "hideProgress",
            CancelHideProgress: "cancelHideProgress",
            Click: "click",
            MouseOver: "mouseover",
            MouseOut: "mouseout",
            MouseEnter: "mouseenter",
            MouseLeave: "mouseleave",
            TouchStart: "touchstart",
            TouchMove: "touchmove",
            TouchEnd: "touchend",
            HideBar: "hideBar",
            ShowBar: "showBar",
            ReadyState: "readyState",
            SourceLoaded: "sourceloaded",
            QualityChange: "qualitychange",
            Play_Btn_Hide: "play_btn_hide",
            Cover_Hide: "cover_hide",
            Cover_Show: "cover_show",
            SeekStart: "seekStart",
            EndStart: "endStart",
            UpdateProgressBar: "updateProgressBar",
            LifeCycleChanged: "lifeCycleChanged",
            Dispose: "dispose",
            Created: "created",
            Snapshot_Hide: "snapshot_hide",
            AutoStreamShow: "auto_stream_show",
            AutoStreamHide: "auto_stream_hide",
            VolumnChanged: "volumnchanged",
            LiveShiftQueryCompleted: "liveShiftQueryCompleted",
            StreamSelectorHide: "streamSelectorHide",
            SpeedSelectorHide: "speedSelectorHide",
            SettingShow: "settingShow",
            SettingHide: "settingHide",
            SelectorShow: "selectorShow",
            SelectorHide: "selectorHide",
            SettingListShow: "settingListShow",
            SettingListHide: "settingListHide",
            ThumbnailHide: "thumbnailHide",
            ThumbnailShow: "thumbnailShow",
            ThumbnailLoaded: "thumbnailLoaded",
            TooltipShow: "tooltipShow",
            TooltipHide: "tooltipHide",
            SelectorUpdateList: "selectorUpdateList",
            SelectorValueChange: "selectorValueChange",
            VolumeVisibilityChange: "volumeVisibilityChange",
            ChangeURL: "changeURL",
            UpdateToSettingList: "updateToSettingList",
            CCChanged: "CCChanged",
            CCStateChanged: "CCStateChanged",
            PlayClick: "click",
            ProgressMarkerLoaded: "progressMarkerLoaded",
            MarkerTextShow: "markerTextShow",
            MarkerTextHide: "markerTextHide",
            PREPARE: "prepare",
            ProgressMarkerChanged: "progressMarkerChanged",
          },
        };
      },
      {},
    ],
    44: [
      function (e, t, i) {
        e("../../event/eventtype");
        var r = e("../../../../lib/dom"),
          o = e("../../../../lib/ua");
        t.exports.handle = function () {
          o.IS_IOS || r.removeClass(this.el(), "prism-fullscreen");
        };
      },
      {
        "../../../../lib/dom": 18,
        "../../../../lib/ua": 31,
        "../../event/eventtype": 43,
      },
    ],
    45: [
      function (e, t, i) {
        var r = e("../../event/eventtype");
        t.exports.handle = function (e) {
          var t = this;
          this._enteredProgressMarker &&
            t.one(r.Player.CanPlay, function () {
              t.pause();
            }),
            (t._seeking = !1),
            t.trigger(r.Player.CompleteSeek, e.paramData.toTime);
        };
      },
      { "../../event/eventtype": 43 },
    ],
    46: [
      function (e, t, i) {
        var r = e("../../event/eventtype"),
          o =
            (e("../../../../lib/constants"),
            e("../../../../lang/index"),
            e("../../../../monitor/util"));
        t.exports.handle = function (e) {
          var t = this,
            i = e.paramData;
          t.trigger(r.Private.H5_Loading_Hide),
            t.trigger(r.Private.Cover_Hide),
            t.trigger(r.Private.Play_Btn_Hide),
            t.trigger(r.Private.SettingListHide),
            t.trigger(r.Private.SelectorHide),
            t.trigger(r.Private.VolumeVisibilityChange, ""),
            (i = i || {}),
            t._monitor &&
              ((i.uuid = o.getUuid()),
              (i.requestId = t._serverRequestId),
              (i.cdnIp = t._monitor._userNetInfo.cdnIp),
              (i.localIp = t._monitor._userNetInfo.localIp)),
            (t._isError = !0),
            t.trigger(r.Private.Error_Show, i),
            t.trigger(r.Private.LifeCycleChanged, {
              type: r.Player.Error,
              data: i,
            });
        };
      },
      {
        "../../../../lang/index": 11,
        "../../../../lib/constants": 15,
        "../../../../monitor/util": 39,
        "../../event/eventtype": 43,
      },
    ],
    47: [
      function (e, t, i) {
        var r = e("../../event/eventtype"),
          o = e("../../../../lib/event"),
          n = e("./lifecyclecommon"),
          a = {
            endStart: e("./endstart"),
            seekStart: e("./seekstart"),
            requestFullScreen: e("./requestfullscreen"),
            cancelFullScreen: e("./cancelfullscreen"),
            error: e("./error"),
          },
          s = [
            r.Private.EndStart,
            r.Private.SeekStart,
            r.Player.RequestFullScreen,
            r.Player.CancelFullScreen,
            r.Player.Error,
            r.Player.Ready,
            r.Private.Dispose,
            r.Private.Created,
          ],
          l = function (t, i, r) {
            var e = t.el();
            o.on(e, i, function (e) {
              (r && r.handle ? r.handle : n.handle).call(t, e, i);
            });
          };
        t.exports.bind = function (e) {
          e.el();
          for (var t = 0; t < s.length; t++) {
            var i = s[t];
            "undefined" != a[i] && l(e, i, a[i]);
          }
        };
      },
      {
        "../../../../lib/event": 19,
        "../../event/eventtype": 43,
        "./cancelfullscreen": 44,
        "./endstart": 45,
        "./error": 46,
        "./lifecyclecommon": 48,
        "./requestfullscreen": 49,
        "./seekstart": 50,
      },
    ],
    48: [
      function (e, t, i) {
        var r = e("../../event/eventtype");
        t.exports.handle = function (e, t) {
          this.trigger(r.Private.LifeCycleChanged, { type: t, data: e });
        };
      },
      { "../../event/eventtype": 43 },
    ],
    49: [
      function (e, t, i) {
        e("../../event/eventtype");
        var r = e("../../../../lib/dom"),
          o = e("../../../../lib/ua");
        t.exports.handle = function () {
          o.IS_IOS || r.addClass(this.el(), "prism-fullscreen");
        };
      },
      {
        "../../../../lib/dom": 18,
        "../../../../lib/ua": 31,
        "../../event/eventtype": 43,
      },
    ],
    50: [
      function (e, t, i) {
        var r = e("../../event/eventtype");
        t.exports.handle = function (e) {
          (this._seeking = !0),
            this.trigger(r.Player.StartSeek, e.paramData.fromTime);
        };
      },
      { "../../event/eventtype": 43 },
    ],
    51: [
      function (e, t, i) {
        var r = e("../../event/eventtype");
        t.exports.handle = function (e) {
          var t = this;
          (t._retrySwitchUrlCount = 0),
            (t._liveRetryCount = 0),
            t._clearLiveErrorHandle();
          var i = new Date().getTime() - t.readyTime;
          t._options.autoplay ||
            t._options._autoplay ||
            !t.paused() ||
            (t.trigger(r.Private.H5_Loading_Hide),
            t.trigger(r.Private.Play_Btn_Show)),
            t.trigger(r.Player.CanPlay, { loadtime: i });
        };
      },
      { "../../event/eventtype": 43 },
    ],
    52: [
      function (e, t, i) {
        var r = e("../../event/eventtype"),
          o = e("../../../../lib/dom"),
          n = e("../../../../lib/ua");
        t.exports.handle = function (e) {
          var t = this.tag;
          "none" === t.style.display &&
            n.IS_IOS &&
            setTimeout(function () {
              o.css(t, "display", "block");
            }, 100),
            this.trigger(r.Video.CanPlayThrough);
        };
      },
      {
        "../../../../lib/dom": 18,
        "../../../../lib/ua": 31,
        "../../event/eventtype": 43,
      },
    ],
    53: [
      function (e, t, i) {
        t.exports.handle = function (e, t) {
          var i = "";
          e && e.paramData && (i = e.paramData), this.trigger(t, i);
        };
      },
      {},
    ],
    54: [
      function (e, t, i) {
        var r = e("../../event/eventtype");
        e("../../../../lang/index");
        t.exports.handle = function (e) {
          var t = this;
          (t.waiting = !1),
            (t._ended = !0),
            t._monitor && t._monitor._onPlayerInit(),
            t._options.rePlay
              ? (t.seek(0), t.tag.play())
              : t._options.isLive && t.trigger(r.Private.H5_Loading_Hide),
            t.trigger(r.Private.Play_Btn_Show),
            t.trigger(r.Player.Ended);
        };
      },
      { "../../../../lang/index": 11, "../../event/eventtype": 43 },
    ],
    55: [
      function (e, t, i) {
        var c = e("../../event/eventtype"),
          d =
            (e("../../../../lib/ua"),
            e("../../../../lib/playerutil"),
            e("../../../../lib/constants")),
          p = e("../../../../lang/index");
        t.exports.handle = function (e) {
          var t = this;
          if (((t.waiting = !1), t._clearTimeout(), t.checkOnline())) {
            var i,
              r = "",
              o = e.target || e.srcElement,
              n = o.error.message;
            r = "";
            if (
              (o.error.code &&
                ((i = o.error.code),
                (r = d.VideoErrorCode[o.error.code]),
                (n = i + " || " + n)),
              t._options.isLive)
            )
              t._options.liveRetry > t._liveRetryCount
                ? t._reloadAndPlayForM3u8()
                : ((t._liveRetryCount = 0),
                  t.trigger(c.Player.LiveStreamStop),
                  (t._liveErrorHandle = setTimeout(function () {
                    var e = {
                      mediaId: "ISLIVE",
                      error_code: r,
                      error_msg:
                        p.get("Error_Play_Text") +
                        "\uff0c" +
                        p.get("Error_Retry_Text"),
                    };
                    t.logError(e), t.trigger("error", e);
                  })));
            else if (t._reloadForVod());
            else {
              var a = p.get("Error_Play_Text"),
                s = !1;
              if (i < 4) {
                if (3 == i && t._firstDecodeError) {
                  var l = t.getCurrentTime() + 1;
                  return (
                    t._loadByUrlInner(t._options.source, l, !0),
                    void (t._firstDecodeError = !1)
                  );
                }
                a = d.VideoErrorCodeText[i];
              } else
                t._eventState == d.SUSPEND
                  ? ((a = p.get("Error_Load_Abort_Text")),
                    (r = d.ErrorCode.RequestDataError))
                  : t._eventState == d.LOAD_START
                  ? ((a = p.get("Error_Network_Text")),
                    0 < t._options.source.indexOf("auth_key") &&
                      (a = a + "\uff0c" + p.get("Error_AuthKey_Text")),
                    (r = d.ErrorCode.StartLoadData))
                  : t._eventState == d.LOADED_METADATA &&
                    ((a = p.get("Error_Play_Text")),
                    (r = d.ErrorCode.PlayingError));
              (a = a + "\uff0c" + p.get("Error_Retry_Text")),
                1 < t._urls.length &&
                  t._retrySwitchUrlCount < 3 &&
                  -1 == t._options.source.indexOf(".mpd") &&
                  (t.switchUrl(), (s = !0));
              var u = {
                mediaId: t._options.vid ? t._options.vid : "",
                error_code: r,
                error_msg: n,
              };
              s ||
                (t.logError(u),
                (u.display_msg = a),
                t.trigger(c.Player.Error, u));
            }
          }
        };
      },
      {
        "../../../../lang/index": 11,
        "../../../../lib/constants": 15,
        "../../../../lib/playerutil": 29,
        "../../../../lib/ua": 31,
        "../../event/eventtype": 43,
      },
    ],
    56: [
      function (e, t, i) {
        var o = e("../../../../lib/event"),
          n = e("../../event/eventtype"),
          r = {
            canplay: e("./canplay"),
            canplaythrough: e("./canplaythrough"),
            common: e("./common"),
            ended: e("./ended"),
            error: e("./error"),
            pause: e("./pause"),
            play: e("./play"),
            playing: e("./playing"),
            waiting: e("./waiting"),
            timeupdate: e("./timeupdate"),
            manualended: e("./ended"),
          },
          a = function (t, i, r) {
            var e = t.tag;
            o.on(e, i, function (e) {
              r.handle.call(t, e, i),
                i != n.Video.Error &&
                  (i == n.Video.ManualEnded && (i = n.Video.Ended),
                  t.trigger(n.Private.LifeCycleChanged, { type: i, data: e }));
            });
          };
        t.exports.bind = function (e) {
          e.tag;
          for (var t in n.Video) {
            var i = n.Video[t];
            a(e, i, void 0 !== r[i] ? r[i] : r.common);
          }
        };
      },
      {
        "../../../../lib/event": 19,
        "../../event/eventtype": 43,
        "./canplay": 51,
        "./canplaythrough": 52,
        "./common": 53,
        "./ended": 54,
        "./error": 55,
        "./pause": 57,
        "./play": 58,
        "./playing": 59,
        "./timeupdate": 60,
        "./waiting": 61,
      },
    ],
    57: [
      function (e, t, i) {
        var r = e("../../event/eventtype");
        t.exports.handle = function (e) {
          var t = this;
          t._clearTimeout(),
            t.trigger(r.Private.AutoStreamHide),
            t.trigger(r.Player.Pause),
            t._isManualPause &&
              (t.trigger(r.Private.Play_Btn_Show),
              t.trigger(r.Private.H5_Loading_Hide)),
            (t.waiting = !1);
        };
      },
      { "../../event/eventtype": 43 },
    ],
    58: [
      function (e, t, i) {
        var r = e("../../event/eventtype");
        t.exports.handle = function (e) {
          var t = this;
          t.trigger(r.Private.Error_Hide),
            t.trigger(r.Private.Cover_Hide),
            t.trigger(r.Private.AutoStreamHide),
            (t.waiting = !1),
            t.trigger(r.Player.Play);
        };
      },
      { "../../event/eventtype": 43 },
    ],
    59: [
      function (e, t, i) {
        var o = e("../../event/eventtype");
        t.exports.handle = function (e) {
          var t = this;
          t.trigger(o.Private.H5_Loading_Hide),
            t.trigger(o.Private.Cover_Hide),
            t.trigger(o.Private.Info_Hide),
            (t.waiting = !1),
            (t._ended = !1),
            (t._liveRetryCount = 0),
            (t._vodRetryCount = 0),
            (t._firstDecodeError = !0);
          var i = t.getCurrentTime();
          if (
            (t._waitingReloadTime != i && (t._waitingTimeoutCount = 0),
            t._checkTimeoutHandle &&
              (clearTimeout(t._checkTimeoutHandle),
              (t._checkTimeoutHandle = null)),
            t._waitingLoadedHandle &&
              (clearTimeout(t._waitingLoadedHandle),
              (t._waitingLoadedHandle = null)),
            t._waitingDelayLoadingShowHandle &&
              (clearTimeout(t._waitingDelayLoadingShowHandle),
              (t._waitingDelayLoadingShowHandle = null)),
            t._waitingTimeoutHandle &&
              (clearTimeout(t._waitingTimeoutHandle),
              (t._waitingTimeoutHandle = null),
              t._ccService && t._options.isLive))
          ) {
            var r = t._ccService.getCurrentSubtitle();
            (t._setDefaultCC = !0), r && t._ccService["switch"](r);
          }
          t.trigger(o.Private.AutoStreamHide),
            t.trigger(o.Player.Playing),
            t.trigger(o.Private.Play_Btn_Hide),
            t.trigger(o.Private.Error_Hide);
        };
      },
      { "../../event/eventtype": 43 },
    ],
    60: [
      function (e, t, i) {
        var n = e("../../event/eventtype"),
          a = e("../../../../lib/ua"),
          s = e("../../../../lib/event"),
          l = e("../../plugin/status");
        t.exports.handle = function (e) {
          var i = this;
          i.trigger(n.Player.TimeUpdate, e.timeStamp);
          var t = i.getCurrentTime();
          if (
            (i.waiting && !i._TimeUpdateStamp && (i._TimeUpdateStamp = t),
            (0 != i.waiting && i._TimeUpdateStamp == t) ||
              (i.trigger(n.Private.H5_Loading_Hide),
              i.trigger(n.Private.AutoStreamHide),
              i._checkTimeoutHandle && clearTimeout(i._checkTimeoutHandle),
              i._waitingTimeoutHandle && clearTimeout(i._waitingTimeoutHandle),
              i._waitingLoadedHandle && clearTimeout(i._waitingLoadedHandle),
              (i.waiting = !1)),
            (i._TimeUpdateStamp = t),
            !i._options.isLive)
          ) {
            var r = i.getDuration(),
              o = !1;
            r < t && !i.paused()
              ? (o = !0)
              : r - t < 0.2 &&
                0 <= a.browser.version.indexOf("49.") &&
                !i.paused()
              ? (o = !0)
              : i.exceedPreviewTime(t) && (o = !0),
              o &&
                !i._ended &&
                (i.pause(), s.trigger(i.tag, n.Video.ManualEnded));
          }
          i._playingSlientPause &&
            (clearTimeout(i._playingSlientPause),
            (i._playingSlientPause = null)),
            (i._playingSlientPause = setTimeout(function () {
              if (i._status == l.playing) {
                var e = i.getCurrentTime(),
                  t = i._options.isLive ? 0 : e;
                i._loadByUrlInner(i._options.source, t, !0);
              }
            }, 2e3));
        };
      },
      {
        "../../../../lib/event": 19,
        "../../../../lib/ua": 31,
        "../../event/eventtype": 43,
        "../../plugin/status": 66,
      },
    ],
    61: [
      function (e, t, i) {
        var n = e("../../event/eventtype"),
          a = e("../../../../lib/constants"),
          s = e("../../../../lib/event"),
          l = e("../../../../lang/index");
        t.exports.handle = function (e) {
          var i = this;
          if (!i._options.isLive) {
            var t = this.getCurrentTime(),
              r = this.getDuration();
            if (r - t < 0.5 || r < t)
              return (
                i.pause(),
                (i._ended = !0),
                void s.trigger(this.tag, n.Video.ManualEnded)
              );
          }
          i.waiting = !0;
          var o = function () {
            i._checkTimeoutHandle &&
              (clearTimeout(i._checkTimeoutHandle),
              (i._checkTimeoutHandle = null)),
              i._waitingTimeoutHandle &&
                (clearTimeout(i._waitingTimeoutHandle),
                (i._waitingTimeoutHandle = null)),
              i._waitingLoadedHandle &&
                (clearTimeout(i._waitingLoadedHandle),
                (i._waitingLoadedHandle = null)),
              i._waitingDelayLoadingShowHandle &&
                (clearTimeout(i._waitingDelayLoadingShowHandle),
                (i._waitingDelayLoadingShowHandle = null));
          };
          o(),
            (i._waitingDelayLoadingShowHandle = setTimeout(function () {
              i.trigger(n.Private.H5_Loading_Show);
            }, 1e3 * i._options.delayLoadingShow)),
            (i._TimeUpdateStamp = null),
            (i._checkTimeoutHandle = setTimeout(function () {
              i.trigger(n.Private.AutoStreamShow);
            }, 1e3 * i._options.loadDataTimeout)),
            i.trigger(n.Player.Waiting),
            (i._waitingTimeoutHandle = setTimeout(function () {
              if (i.tag && i._options) {
                i.pause();
                var e = {
                  mediaId: i._options.vid ? i._options.vid : "",
                  error_code: a.ErrorCode.LoadingTimeout,
                  error_msg: l.get("Error_Waiting_Timeout_Text"),
                };
                i.logError(e), i.trigger("error", e);
              }
            }, 1e3 * i._options.waitingTimeout)),
            (i._waitingLoadedHandle = setTimeout(function () {
              var e = i.getCurrentTime();
              if (0 == i._waitingTimeoutCount && e != i._waitingReloadTime) {
                (i._waitingTimeoutCount = 1), (i._waitingReloadTime = e);
                var t = i._options.isLive ? 0 : e;
                i._loadByUrlInner(i._options.source, t, !0);
              }
            }, (i._options.waitingTimeout / 2) * 1e3)),
            i.on("error", function () {
              o();
            });
        };
      },
      {
        "../../../../lang/index": 11,
        "../../../../lib/constants": 15,
        "../../../../lib/event": 19,
        "../../event/eventtype": 43,
      },
    ],
    62: [
      function (e, t, i) {
        var n = e("../../ui/component"),
          a = e("../../lib/object"),
          o = e("../../lib/dom"),
          s = e("../../lib/event"),
          l = (e("../../lib/io"), e("../../ui/exports")),
          u = e("../../monitor/monitor"),
          r = e("../../lib/ua"),
          c = e("../../lib/constants"),
          d = e("../../lib/util"),
          p = (e("../../config"), e("../../lib/playerutil")),
          h = e("./x5play"),
          f = e("../../lib/cookie"),
          _ = e("../../lang/index"),
          g = e("../../feature/autoPlayDelay"),
          y = e("./event/eventmanager"),
          v = e("../../ui/component/cover"),
          m = e("../../ui/component/play-animation"),
          S = e("../../commonui/autostreamselector"),
          T = e("./event/eventtype"),
          b = e("./plugin/lifecyclemanager"),
          x = e("../service/export"),
          E = e("../../ui/component/progressmarker"),
          P = n.extend({
            init: function (e, t) {
              if (
                ((this.tag = e),
                (this.loaded = !1),
                (this.played = !1),
                (this.waiting = !1),
                (this._urls = []),
                (this._currentPlayIndex = 0),
                (this._retrySwitchUrlCount = 0),
                (this._isError = !1),
                (this._isHls = !1),
                (this._liveRetryCount = 0),
                (this._vodRetryCount = 0),
                (this._seeking = !1),
                (this._serverRequestId = 0),
                (this._waitingTimeoutCount = 0),
                (this._waitingReloadTime = 0),
                (this._created = !1),
                (this._firstDecodeError = !0),
                (this._enteredProgressMarker = !1),
                (this._liveShiftSeekStartTime = 0),
                (this._duration = 0),
                (this.__disposed = !1),
                void 0 === t.skinLayout && (t.skinLayout = p.defaultH5Layout),
                n.call(this, this, t),
                this.addClass("prism-player"),
                t.plugins &&
                  a.each(
                    t.plugins,
                    function (e, t) {
                      this[e](t);
                    },
                    this
                  ),
                this._createService(),
                (this.UI = {}),
                t.useNativeControls
                  ? this.tag.setAttribute("controls", "controls")
                  : (this.UI = l),
                this.initChildren(),
                y.onAll(this),
                (this._lifeCycleManager = new b(this)),
                this._options.trackLog &&
                  (this._monitor = new u(
                    this,
                    {
                      video_id: 0,
                      album_id: 0,
                      from: this._options.from,
                      source: this._options.source,
                      logBatched: this._options.logBatched,
                    },
                    this._options.trackLog
                  )),
                this._overrideNativePlay(),
                !this._liveshiftService || this._liveshiftService.validate())
              ) {
                if (this._options.extraInfo) {
                  var i = this._options.extraInfo;
                  i.liveRetry && (this._options.liveRetry = i.liveRetry);
                }
                if (
                  (this.on(T.Private.ReadyState, function () {
                    this.trigger(T.Player.Ready);
                  }),
                  this._thumbnailService &&
                    this._options.thumbnailUrl &&
                    this._thumbnailService.get(this._options.thumbnailUrl),
                  0 < this._options.progressMarkers.length &&
                    this.trigger(
                      T.Private.ProgressMarkerLoaded,
                      this._options.progressMarkers
                    ),
                  this._options.source &&
                    this._options._native &&
                    this._executeReadyCallback(),
                  this._options.autoplay || this._options.preload
                    ? this.trigger(T.Private.H5_Loading_Show)
                    : this.trigger(T.Private.Play_Btn_Show),
                  this._extraMultiSources(),
                  this._options.source)
                )
                  if (
                    (this.trigger(T.Private.PREPARE, "custom"),
                    this._options.autoPlayDelay)
                  ) {
                    this._autoPlayDelay = new g(this);
                    var r = this;
                    this._autoPlayDelay.handle(function () {
                      r.initPlay();
                    });
                  } else this.initPlay();
              } else {
                var o = {
                  mediaId: this._options.vid ? this._options.vid : "",
                  error_code: c.ErrorCode.InvalidParameter,
                  error_msg: _.get("ShiftLiveTime_Error"),
                };
                this.trigger(T.Player.Error, o);
              }
            },
          });
        (P.prototype.initPlay = function (e) {
          this._initPlayBehavior(e, this._options.source);
        }),
          (P.prototype.initChildren = function () {
            var e = this.options(),
              t = e.skinLayout;
            if (!1 !== t && !a.isArray(t))
              throw new Error(
                "PrismPlayer Error: skinLayout should be false or type of array!"
              );
            !1 !== t &&
              0 !== t.length &&
              (this.options({ children: t }),
              n.prototype.initChildren.call(this)),
              (this.UI.cover = v),
              this.addChild("cover", e),
              (this.UI.playanimation = m),
              this.addChild("playanimation", e),
              (this.UI.autoStreamSelector = S),
              this.addChild("autoStreamSelector", e),
              (this.UI.progressMarker = E),
              this.addChild("progressMarker", e),
              this.trigger(T.Private.UiH5Ready);
          }),
          (P.prototype.createEl = function () {
            var e = !1;
            "VIDEO" !== this.tag.tagName
              ? ((this._el = this.tag),
                (this.tag = n.prototype.createEl.call(this, "video")),
                this._options.playsinline &&
                  (this.tag.setAttribute("webkit-playsinline", ""),
                  this.tag.setAttribute("playsinline", ""),
                  this.tag.setAttribute("x-webkit-airplay", ""),
                  this.tag.setAttribute("x5-playsinline", "")))
              : ((e = !0), (this._el = this.tag.parentNode));
            var t = this._el,
              i = this.tag;
            this._options.enableSystemMenu ||
              (i.addEventListener
                ? i.addEventListener(
                    "contextmenu",
                    function (e) {
                      e.preventDefault();
                    },
                    !1
                  )
                : i.attachEvent("oncontextmenu", function () {
                    window.event.returnValue = !1;
                  })),
              (i.player = this);
            var r = o.getElementAttributes(i);
            return (
              a.each(r, function (e) {
                t.setAttribute(e, r[e]);
              }),
              this.setVideoAttrs(),
              e ||
                (i.parentNode && i.parentNode.insertBefore(t, i),
                o.insertFirst(i, t)),
              t
            );
          }),
          (P.prototype.setVideoAttrs = function () {
            var e = this._options.preload,
              t = this._options.autoplay;
            if (
              ((this.tag.style.width = this._options.videoWidth || "100%"),
              (this.tag.style.height = this._options.videoHeight || "100%"),
              e && this.tag.setAttribute("preload", "preload"),
              t &&
                !this._isEnabledAILabel() &&
                this.tag.setAttribute("autoplay", "autoplay"),
              r.IS_IOS &&
                this.tag.setAttribute(
                  "poster",
                  "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAMZJREFUeAHt0DEBAAAAwqD1T20LL4hAYcCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMCAAQMGDBgwYMDAc2CcpAABaODCqQAAAABJRU5ErkJggg=="
                ),
              this._options.extraInfo)
            )
              for (var i in this._options.extraInfo)
                this.tag.setAttribute(i, this._options.extraInfo[i]);
            h.adaptX5Play(this);
          }),
          (P.prototype.checkOnline = function () {
            if (!this._options || this._options.debug) return !0;
            if (0 != navigator.onLine) return !0;
            var e = {
              mediaId: this._options.vid ? this._options.vid : "",
              error_code: c.ErrorCode.NetworkUnavaiable,
              error_msg: _.get("Error_Offline_Text"),
            };
            return (
              (e.display_msg = _.get("Error_Offline_Text")),
              this.trigger(T.Player.Error, e),
              !1
            );
          }),
          (P.prototype.id = function () {
            return this.el().id;
          }),
          (P.prototype.renderUI = function () {}),
          (P.prototype.switchUrl = function () {
            if (0 != this._urls.length) {
              (this._currentPlayIndex = this._currentPlayIndex + 1),
                this._urls.length <= this._currentPlayIndex &&
                  ((this._currentPlayIndex = 0), this._retrySwitchUrlCount++);
              var e = this._urls[this._currentPlayIndex];
              f.set(c.SelectedStreamLevel, e.definition, 365),
                this.trigger(
                  T.Private.QualityChange,
                  _.get("Quality_Change_Fail_Switch_Text")
                );
              var t = this.getCurrentTime();
              (this._vodRetryCount = 0),
                (this._originalSource = ""),
                this._loadByUrlInner(e.Url, t, !0);
            }
          }),
          (P.prototype.setControls = function () {
            var e = this.options();
            if (e.useNativeControls)
              this.tag.setAttribute("controls", "controls");
            else if ("object" == typeof e.controls) {
              var t = this._initControlBar(e.controls);
              this.addChild(t);
            }
          }),
          (P.prototype._initControlBar = function (e) {
            return new ControlBar(this, e);
          }),
          (P.prototype.getMetaData = function () {
            var t = this,
              i = this.tag;
            t._readyStateTimer && clearInterval(t._readyStateTimer),
              (t._readyStateTimer = window.setInterval(function (e) {
                t.tag
                  ? i &&
                    0 < i.readyState &&
                    ((t._duration = i.duration < 1 ? 0 : i.duration),
                    t.trigger(T.Private.ReadyState),
                    clearInterval(t._readyStateTimer))
                  : clearInterval(t._readyStateTimer);
              }, 100));
          }),
          (P.prototype.getReadyTime = function () {
            return this.readyTime;
          }),
          (P.prototype.readyState = function () {
            return this.tag.readyState;
          }),
          (P.prototype.getError = function () {
            return this.tag.error;
          }),
          (P.prototype.getRecentOccuredEvent = function () {
            return this._eventState;
          }),
          (P.prototype.getSourceUrl = function () {
            return this._options ? this._options.source : "";
          }),
          (P.prototype.getMonitorInfo = function () {
            return this._monitor ? this._monitor.opt : {};
          }),
          (P.prototype.getCurrentQuality = function () {
            if (0 < this._urls.length) {
              var e = this._urls[this._currentPlayIndex];
              return { width: e.width, url: e.Url, definition: e.definition };
            }
            return "";
          }),
          (P.prototype.setSpeed = function (e) {
            this.tag &&
              ((this._originalPlaybackRate = e), (this.tag.playbackRate = e));
          }),
          (P.prototype.play = function (e) {
            return (
              this.tag &&
                (this.tag.ended || this._ended
                  ? this.replay()
                  : (((this._options.preload || this.loaded) && this.tag.src) ||
                      this._initLoad(this._options.source),
                    this.trigger(T.Private.Cover_Hide),
                    this.tag.play())),
              (this._isManualPlay = e || !1),
              this
            );
          }),
          (P.prototype.replay = function () {
            return (
              this._monitor && this._monitor.replay(),
              this.seek(0),
              this.tag.play(),
              this
            );
          }),
          (P.prototype.pause = function (e) {
            return (
              this.tag && this.tag.pause(),
              (this._isManualPause = e || !1),
              this
            );
          }),
          (P.prototype.stop = function () {
            return this.tag.setAttribute("src", null), this;
          }),
          (P.prototype.paused = function () {
            if (this.tag) return !1 !== this.tag.paused;
          }),
          (P.prototype.getDuration = function () {
            var e = 0;
            return (
              this.tag &&
                (e = this.isPreview()
                  ? this._vodDuration || this.tag.duration
                  : this._duration && this._duration != 1 / 0
                  ? this._duration
                  : this.tag.duration),
              e
            );
          }),
          (P.prototype.getDisplayDuration = function () {
            var e = 0;
            return this.tag && (e = this._vodDuration || this.getDuration()), e;
          }),
          (P.prototype.getCurrentTime = function () {
            return this.tag ? this.tag.currentTime : 0;
          }),
          (P.prototype.seek = function (e) {
            e === this.tag.duration && e--;
            var t = this._originalPlaybackRate || this.tag.playbackRate;
            try {
              var i = this;
              (this.tag.currentTime = e),
                setTimeout(function () {
                  i.tag && (i.tag.playbackRate = t);
                });
            } catch (e) {
              console.log(e);
            }
            return this;
          }),
          (P.prototype.firstNewUrlloadByUrl = function (e, t) {
            this._clearTimeout(),
              (this._options.vid = 0),
              (this._options.source = e),
              this._monitor &&
                this._monitor.updateVideoInfo({
                  video_id: 0,
                  album_id: 0,
                  source: e,
                  from: this._options.from,
                }),
              this.trigger(T.Private.ChangeURL),
              this.initPlay(),
              this._options.autoplay && this.trigger(T.Private.Cover_Hide),
              this._options.autoplay
                ? this.trigger(T.Player.Play)
                : this.trigger(T.Player.Pause),
              t || (t = 0),
              (!t && 0 != t) || isNaN(t) || this.seek(t);
          }),
          (P.prototype._loadByUrlInner = function (e, t, i) {
            this.loadByUrl(e, t, i, !0);
          }),
          (P.prototype.loadByUrl = function (e, t, i, r) {
            this._monitor && !r && this._monitor.reset(),
              (this._isError = !1),
              (this._duration = 0),
              this._clearTimeout(),
              this.trigger(T.Private.Error_Hide),
              (this._options.vid = 0),
              (this._options.source = e),
              this._monitor &&
                this._monitor.updateVideoInfo({
                  video_id: 0,
                  album_id: 0,
                  source: e,
                  from: this._options.from,
                }),
              r ||
                (this.trigger(T.Private.ChangeURL), (this._vodRetryCount = 0)),
              (this._options._autoplay = i),
              this.initPlay(i),
              (this._options.autoplay || i) &&
                this.trigger(T.Private.Cover_Hide),
              this._options.autoplay || i
                ? this.trigger(T.Player.Play)
                : this.trigger(T.Player.Pause);
            var o = this;
            this._options.isLive ||
              s.one(this.tag, T.Video.CanPlay, function (e) {
                (!t && 0 != t) || isNaN(t) || o.seek(t);
              });
          }),
          (P.prototype.dispose = function () {
            (this.__disposed = !0),
              this.trigger(T.Private.Dispose),
              this.tag.pause(),
              y.offAll(this),
              this._monitor &&
                (this._monitor.removeEvent(), (this._monitor = null)),
              this._autoPlayDelay && this._autoPlayDelay.dispose(),
              this._checkTimeoutHandle &&
                (clearTimeout(this._checkTimeoutHandle),
                (this._checkTimeoutHandle = null)),
              this._waitingTimeoutHandle &&
                (clearTimeout(this._waitingTimeoutHandle),
                (this._waitingTimeoutHandle = null)),
              this._playingSlientPause &&
                (clearTimeout(this._playingSlientPause),
                (this._playingSlientPause = null)),
              this._waitingLoadedHandle &&
                (clearTimeout(this._waitingLoadedHandle),
                (this._waitingLoadedHandle = null)),
              this._readyStateTimer &&
                (clearInterval(this._readyStateTimer),
                (this._readyStateTimer = null)),
              this._vodRetryCountHandle &&
                (clearTimeout(this._vodRetryCountHandle),
                (this._vodRetryCountHandle = null)),
              this._waitingDelayLoadingShowHandle &&
                (clearTimeout(this._waitingDelayLoadingShowHandle),
                (this._waitingDelayLoadingShowHandle = null)),
              this._disposeService(),
              this._clearLiveErrorHandle(),
              (this._el.innerHTML = ""),
              this.destroy(),
              (this.tag = null),
              (this._options.recreatePlayer = null),
              (this._options = null);
          }),
          (P.prototype.mute = function () {
            this._muteInner(), (this._originalVolumn = this.tag.volume);
            var e = _.get("Volume_Mute");
            return (
              this._player.trigger(T.Private.Info_Show, {
                text: e,
                duration: 1e3,
                align: "lb",
              }),
              this._setInnerVolume(0),
              this
            );
          }),
          (P.prototype._muteInner = function () {
            (this.tag.muted = !0), this.trigger(T.Private.VolumnChanged, -1);
          }),
          (P.prototype.unMute = function () {
            this._unMuteInner();
            var e = _.get("Volume_UnMute");
            return (
              this._player.trigger(T.Private.Info_Show, {
                text: e,
                duration: 1e3,
                align: "lb",
              }),
              this._setInnerVolume(this._originalVolumn || 0.5),
              this
            );
          }),
          (P.prototype._unMuteInner = function () {
            (this.tag.muted = !1), this.trigger(T.Private.VolumnChanged, -2);
          }),
          (P.prototype.muted = function () {
            return this.tag.muted;
          }),
          (P.prototype.getVolume = function () {
            return this.tag.volume;
          }),
          (P.prototype.getOptions = function () {
            return this._options;
          }),
          (P.prototype.setVolume = function (e, t) {
            0 != e ? this._unMuteInner() : 0 == e && this._muteInner(),
              this._setInnerVolume(e);
            var i =
              _.get("Curent_Volume") +
              "<span>" +
              (100 * e).toFixed() +
              "%</span>";
            this._player.trigger(T.Private.Info_Show, {
              text: i,
              duration: 1e3,
              align: "lb",
            });
          }),
          (P.prototype._setInnerVolume = function (e) {
            (this.tag.volume = e), this.trigger(T.Private.VolumnChanged, e);
          }),
          (P.prototype.hideProgress = function () {
            this.trigger(T.Private.HideProgress);
          }),
          (P.prototype.cancelHideProgress = function () {
            this.trigger(T.Private.CancelHideProgress);
          }),
          (P.prototype.setPlayerSize = function (e, t) {
            (this._el.style.width = e), (this._el.style.height = t);
          }),
          (P.prototype.getBuffered = function () {
            return this.tag.buffered;
          }),
          (P.prototype.setRotate = function (e) {
            this.tag &&
              ((this._rotate = e),
              this._setTransform(),
              this.log("ROTATE", { rotation: e }));
          }),
          (P.prototype.getRotate = function (e) {
            return void 0 === this._rotate ? 0 : this._rotate;
          }),
          (P.prototype.setImage = function (e) {
            this.tag &&
              ((this._image = e),
              this._setTransform(),
              this.log("IMAGE", { mirror: "horizon" == e ? 2 : 1, text: e }));
          }),
          (P.prototype.getImage = function () {
            return this._image;
          }),
          (P.prototype.cancelImage = function () {
            this.tag &&
              ((this._image = ""),
              this._setTransform(),
              this.log("IMAGE", { mirror: 0 }));
          }),
          (P.prototype.setCover = function (e) {
            var t = document.querySelector("#" + this.id() + " .prism-cover");
            t &&
              e &&
              ((t.style.backgroundImage = "url(" + e + ")"),
              (this._options.cover = e),
              this.trigger(T.Private.Cover_Show));
          }),
          (P.prototype._setTransform = function () {
            this._transformProp ||
              (this._transformProp = o.getTransformName(this.tag));
            var e = " translate(-50%, -50%)";
            this._rotate && (e += " rotate(" + this._rotate + "deg)"),
              this._image &&
                ("vertical" == this._image
                  ? (e += " scaleY(-1)")
                  : "horizon" == this._image && (e += " scaleX(-1)")),
              (this.tag.style[this._transformProp] = e);
          }),
          (P.prototype._startPlay = function () {
            this.tag.paused && this.tag.play();
          }),
          (P.prototype._initPlayBehavior = function (e, t) {
            if (this._checkSupportVideoType()) return !1;
            if (p.validateSource(t))
              return (
                void 0 === e && (e = !1),
                this._created ||
                  ((this._created = !0), this.trigger(T.Private.Created)),
                this.loaded || this.trigger(T.Player.Init),
                this._options.autoplay ||
                this._options._autoplay ||
                this._options.preload ||
                e
                  ? ((this._options._preload = !0),
                    this._initLoad(t),
                    (this._options.autoplay || this._options._autoplay) &&
                      this._startPlay())
                  : this.trigger(T.Private.Play_Btn_Show),
                !0
              );
            var i = {
              mediaId: this._options.vid ? this._options.vid : "",
              error_code: c.ErrorCode.InvalidSourceURL,
              error_msg: "InvalidSourceURL",
            };
            return (
              (i.display_msg = _.get("Error_Invalidate_Source")),
              this.trigger(T.Player.Error, i),
              !1
            );
          }),
          (P.prototype._isPreload = function () {
            return (
              this._options.autoplay ||
              this._options.preload ||
              this._options._preload
            );
          }),
          (P.prototype._initLoad = function (e) {
            this.getMetaData(),
              e &&
                (this._isPreload() && !r.IS_MOBILE
                  ? this.trigger(T.Private.H5_Loading_Show)
                  : (this.trigger(T.Private.H5_Loading_Hide),
                    this.trigger(T.Private.Play_Btn_Show)),
                this.tag.setAttribute("src", e),
                (this.loaded = !0));
          }),
          (P.prototype._clearLiveErrorHandle = function () {
            this._liveErrorHandle &&
              (clearTimeout(this._liveErrorHandle),
              (this._liveErrorHandle = null));
          }),
          (P.prototype._reloadAndPlayForM3u8 = function () {
            0 == this._liveRetryCount && this.trigger(T.Player.OnM3u8Retry);
            var e = this._options,
              t = e.liveRetryInterval + e.liveRetryStep * this._liveRetryCount;
            d.sleep(1e3 * t),
              this._liveRetryCount++,
              this.tag.load(this._options.source),
              this.tag.play();
          }),
          (P.prototype._checkSupportVideoType = function () {
            if (!this.tag.canPlayType || !this._options.source || !r.IS_MOBILE)
              return "";
            var e = this._options.source,
              t = "";
            if (
              (0 < e.indexOf("m3u8")
                ? "" != this.tag.canPlayType("application/x-mpegURL") ||
                  p.isSupportHls() ||
                  (t = _.get("Error_Not_Support_M3U8_Text"))
                : 0 < e.indexOf("mp4")
                ? "" == this.tag.canPlayType("video/mp4") &&
                  (t = _.get("Error_Not_Support_MP4_Text"))
                : (p.isRTMP(e) || p.isFlv(e)) &&
                  r.IS_MOBILE &&
                  (t = _.get("Error_Not_Support_Format_On_Mobile")),
              t)
            ) {
              var i = {
                mediaId: this._options.vid ? this._options.vid : "",
                error_code: c.ErrorCode.FormatNotSupport,
                error_msg: t,
              };
              this.logError(i),
                (i.display_msg = t),
                this.trigger(T.Player.Error, i);
            }
            return t;
          }),
          (P.prototype.getComponent = function (e) {
            return this._lifeCycleManager.getComponent(e);
          }),
          (P.prototype.logError = function (e, t) {
            e || (e = {}),
              (e.vt = this.getCurrentTime()),
              (this._serverRequestId = this.log(t ? "ERRORRETRY" : "ERROR", e));
          }),
          (P.prototype.log = function (e, t) {
            var i = 0,
              r = 0;
            if (this._monitor)
              return (
                this._options &&
                  ((i = this._options.vid || "0"),
                  (r = this._options.from || "0")),
                this._monitor.updateVideoInfo({
                  video_id: i,
                  album_id: 0,
                  source: this._options.source,
                  from: r,
                }),
                this._monitor._log(e, t)
              );
          }),
          (P.prototype.setSanpshotProperties = function (e, t, i) {
            if (
              (this._snapshotMatric || (this._snapshotMatric = {}),
              (this._snapshotMatric.width = e),
              (this._snapshotMatric.height = t),
              1 < i)
            )
              throw new Error("rate doesn't allow more than 1");
            this._snapshotMatric.rate = i;
          }),
          (P.prototype.getStatus = function () {
            return this._status ? this._status : "init";
          }),
          (P.prototype.enterProgressMarker = function () {
            this._enteredProgressMarker = !0;
          }),
          (P.prototype.isInProgressMarker = function () {
            return this._enteredProgressMarker;
          }),
          (P.prototype.exitProgressMarker = function () {
            this._enteredProgressMarker = !1;
          }),
          (P.prototype.setProgressMarkers = function (e) {
            e || (e = []), this.trigger(T.Private.ProgressMarkerChanged, e);
          }),
          (P.prototype.getProgressMarkers = function () {
            return this._progressMarkerService
              ? this._progressMarkerService.progressMarkers
              : [];
          }),
          (P.prototype.setPreviewTime = function (e) {
            this._options.playConfig || (this._options.playConfig = {}),
              (this._options.playConfig.PreviewTime = e);
          }),
          (P.prototype.getPreviewTime = function () {
            var e = 0;
            return (
              this._options.playConfig &&
                (e = this._options.playConfig.PreviewTime),
              e
            );
          }),
          (P.prototype.exceedPreviewTime = function (e) {
            return (
              this.isPreview() && e >= this._options.playConfig.PreviewTime
            );
          }),
          (P.prototype.isPreview = function () {
            var e = this._options.playConfig.PreviewTime,
              t = this._vodDuration || this.tag.duration;
            return 0 < e && e < t;
          }),
          (P.prototype._getSanpshotMatric = function () {
            return (
              this._snapshotMatric || (this._snapshotMatric = {}),
              this._snapshotMatric
            );
          }),
          (P.prototype._overrideNativePlay = function () {
            var r = this.tag.play,
              o = this;
            this.tag.play = function () {
              if ((console.log("do play"), !o._options.source)) {
                var e = {
                  mediaId: o._options.vid ? o._options.vid : "",
                  error_code: c.ErrorCode.InvalidSourceURL,
                  error_msg: "InvalidSourceURL",
                };
                return (
                  o._options.vid
                    ? (e.display_msg = _.get("Error_Vid_Empty_Source"))
                    : (e.display_msg = _.get("Error_Empty_Source")),
                  void o.trigger(T.Player.Error, e)
                );
              }
              o.readyTime = new Date().getTime();
              var t = r.apply(o.tag);
              void 0 !== t &&
                t
                  .then(function () {
                    o.trigger(T.Player.AutoPlay, !0),
                      console.log("do play successfully");
                  })
                  ["catch"](function (e) {
                    console.log("do play failed"),
                      !o.tag ||
                        !o.tag.paused ||
                        o._isError ||
                        o._options._autoplay ||
                        o._switchedLevel ||
                        (o.trigger(T.Private.Play_Btn_Show),
                        o.trigger(T.Private.H5_Loading_Hide),
                        o.trigger(T.Player.AutoPlayPrevented),
                        o.trigger(T.Player.AutoPlay, !1),
                        o._options.cover && o.trigger(T.Private.Cover_Show));
                  });
              var i = o._originalPlaybackRate || o.tag.playbackRate;
              setTimeout(function () {
                o.tag && (o.tag.playbackRate = i);
              });
            };
          }),
          (P.prototype._extraMultiSources = function () {
            var e = this._options.source;
            if (e && -1 < e.indexOf("{") && -1 < e.indexOf("}")) {
              var t = "";
              try {
                t = JSON.parse(e);
              } catch (e) {
                console.error(e),
                  console.error(
                    "\u5730\u5740json\u4e32\u683c\u5f0f\u4e0d\u5bf9"
                  );
              }
              var i = [];
              for (var r in t) {
                var o = c.QualityLevels[r];
                i.push({ definition: r, Url: t[r], desc: o || r });
              }
              if (0 < i.length) {
                this._currentPlayIndex = p.findSelectedStreamLevel(i);
                var n = i[this._currentPlayIndex];
                (this._urls = i),
                  (this._options.source = n.Url),
                  this.trigger(T.Private.SourceLoaded, n);
              }
            }
          }),
          (P.prototype._isEnabledAILabel = function () {
            return this._options.ai && this._options.ai.label;
          }),
          (P.prototype._createService = function () {
            if (x)
              for (var e = x.length, t = 0; t < e; t++) {
                var i = x[t],
                  r = i.condition;
                void 0 === r
                  ? (r = !0)
                  : "function" == typeof r && (r = r.call(this)),
                  r && (this[i.name] = new i.service(this));
              }
          }),
          (P.prototype._disposeService = function () {
            if (x)
              for (var e = x.length, t = 0; t < e; t++) {
                var i = this[x[t].name];
                void 0 !== i && i.dispose && i.dispose();
              }
          }),
          (P.prototype._executeReadyCallback = function () {
            try {
              this._options.autoplay ||
                this._options.preload ||
                (this.trigger(T.Private.H5_Loading_Hide),
                this.trigger(T.Private.Play_Btn_Show)),
                this._options.readyCallback(this);
            } catch (e) {
              console.log(e);
            }
          }),
          (P.prototype._clearTimeout = function () {
            this._checkTimeoutHandle &&
              (clearTimeout(this._checkTimeoutHandle),
              (this._checkTimeoutHandle = null)),
              this._waitingTimeoutHandle &&
                (clearTimeout(this._waitingTimeoutHandle),
                (this._waitingTimeoutHandle = null)),
              this._clearLiveErrorHandle();
          }),
          (P.prototype._reloadForVod = function () {
            if (
              (this._originalSource ||
                (this._originalSource = this._options.source),
              this._vodRetryCount < this._options.vodRetry && navigator.onLine)
            ) {
              var e = this.getCurrentTime(),
                t = this._originalSource;
              t.indexOf("auth_key=") < 0 &&
                (t =
                  t && 0 < t.indexOf("?")
                    ? t + "&_t=" + new Date().valueOf()
                    : t + "?_t=" + new Date().valueOf()),
                this._vodRetryCountHandle &&
                  clearTimeout(this._vodRetryCountHandle);
              var i = this;
              return (
                console.log("_reloadForVod"),
                (this._vodRetryCountHandle = setTimeout(function () {
                  console.log("reload vod because failed"),
                    i._loadByUrlInner(t, e, !0);
                }, 100 * this._vodRetryCount)),
                (this._vodRetryCount = this._vodRetryCount + 1),
                !0
              );
            }
            return !1;
          }),
          (t.exports = P);
      },
      {
        "../../commonui/autostreamselector": 2,
        "../../config": 5,
        "../../feature/autoPlayDelay": 7,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/cookie": 16,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/io": 24,
        "../../lib/object": 26,
        "../../lib/playerutil": 29,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../../monitor/monitor": 38,
        "../../ui/component": 94,
        "../../ui/component/cover": 98,
        "../../ui/component/play-animation": 104,
        "../../ui/component/progressmarker": 107,
        "../../ui/exports": 124,
        "../service/export": 87,
        "./event/eventmanager": 42,
        "./event/eventtype": 43,
        "./plugin/lifecyclemanager": 65,
        "./x5play": 67,
      },
    ],
    63: [
      function (e, t, i) {
        var r = e("../../../lib/oo").extend({});
        t.exports = r;
      },
      { "../../../lib/oo": 27 },
    ],
    64: [
      function (e, t, i) {
        t.exports = {
          createEl: "createEl",
          created: "created",
          ready: "ready",
          loading: "loading",
          play: "play",
          pause: "pause",
          playing: "playing",
          waiting: "waiting",
          timeUpdate: "timeupdate",
          error: "error",
          ended: "ended",
          dispose: "dispose",
          markerDotOver: "markerDotOver",
          markerDotOut: "markerDotOut",
        };
      },
      {},
    ],
    65: [
      function (e, t, i) {
        var s = e("../../../lib/object"),
          u = e("../event/eventtype"),
          c = e("./lifecycle"),
          r = e("./status"),
          o = function (t) {
            ((this._player = t)._status = "init"), (this.components = []);
            var e = t.getOptions().components;
            if (e && s.isArray(e) && 0 < e.length)
              for (var i = 0; i < e.length; i++) {
                var r = e[i];
                if (!r)
                  return void console.log(
                    "The " + i + " custome component is " + r
                  );
                if (
                  ((constr = void 0 === r.type ? r : r.type),
                  (args = void 0 === r.args ? [] : r.args),
                  (name = void 0 === r.name ? "" : r.name),
                  !constr)
                )
                  return void console.log(name + " compenent is " + constr);
                args && 0 < args.length
                  ? (args = [].concat.call([constr], args))
                  : (args = []);
                var o = new (Function.prototype.bind.apply(constr, args))(),
                  n = o[c.createEl];
                n && "function" == typeof n && n.call(o, t.el(), t),
                  this.components.push({ name: name, obj: o });
              }
            var a = this;
            t.on(u.Private.LifeCycleChanged, function (e) {
              0 != a.components.length && l.call(a, t, e);
            });
          };
        o.prototype.getComponent = function (e) {
          var t = null,
            i = this.components.length;
          if (e)
            for (var r = 0; r < i; r++)
              if (this.components[r].name == e) {
                t = this.components[r].obj;
                break;
              }
          return t;
        };
        var l = function (e, t) {
            if (t) {
              var i = t.paramData,
                r = i.type,
                o = i.data;
              (function (e) {
                return (
                  e == u.Video.LoadStart ||
                  e == u.Video.LoadedData ||
                  e == u.Video.LoadedMetadata
                );
              })(r) && (r = c.loading),
                d(e, r);
              for (var n = this.components.length, a = 0; a < n; a++) {
                var s = this.components[a].obj,
                  l = s[r];
                l && "function" == typeof l && l.call(s, e, o);
              }
              r == u.Private.Dispose && (this.components = []);
            }
          },
          d = function (e, t) {
            void 0 !== r[t] &&
              (t != r.pause ||
                (e._status != r.error && e._status != r.ended)) &&
              (e._status = t);
          };
        t.exports = o;
      },
      {
        "../../../lib/object": 26,
        "../event/eventtype": 43,
        "./lifecycle": 64,
        "./status": 66,
      },
    ],
    66: [
      function (e, t, i) {
        t.exports = {
          init: "init",
          ready: "ready",
          loading: "loading",
          play: "play",
          pause: "pause",
          playing: "playing",
          waiting: "waiting",
          error: "error",
          ended: "ended",
        };
      },
      {},
    ],
    67: [
      function (e, t, i) {
        var r = e("../../lib/ua"),
          o = e("../../lib/dom"),
          n = function (e, t) {
            var i = e.el().style.height,
              r = e.el().style.width;
            e.originalLayout = {
              container: { height: i, width: r },
              video: { width: e.tag.style.width, height: e.tag.style.height },
            };
            var o =
                document.body.clientHeight * (window.devicePixelRatio || 1) +
                "px",
              n = document.body.clientWidth + "px";
            t
              ? ((height = o), (width = n))
              : ((height = i.indexOf("%") ? i : i + "px"),
                (width = r.indexOf("%") ? r : r + "px")),
              (e.tag.style.width = n),
              (e.tag.style.height = o),
              (e.el().style.height = t ? o : height);
          };
        (t.exports.isAndroidX5 = function () {
          return (r.os.android && r.is_X5) || r.dingTalk();
        }),
          (t.exports.adaptX5Play = function (e) {
            r.os.android &&
              r.is_X5 &&
              ("h5" == e._options.x5_type &&
                (e.tag.setAttribute("x5-video-player-type", e._options.x5_type),
                (window.onresize = function () {
                  n(
                    e,
                    e._options.x5_fullscreen ||
                      "center" == e._options.x5_video_position
                  ),
                    (function (e) {
                      if ("landscape" == e._x5VideoOrientation) {
                        (e._originalTagWidth = e.tag.style.width),
                          (e._originalTagHeight = e.tag.style.height);
                        var t = document.querySelector(
                          "#" + e.id() + " .prism-controlbar"
                        );
                        t && parseFloat(t.offsetHeight),
                          (e.tag.style.height = "100%"),
                          (e.tag.style.width = window.screen.width + "px");
                      }
                    })(e);
                }),
                e.tag.addEventListener("x5videoenterfullscreen", function () {
                  n(
                    e,
                    e._options.x5_fullscreen ||
                      "center" == e._options.x5_video_position
                  ),
                    e.trigger("x5requestFullScreen");
                }),
                e.tag.addEventListener("x5videoexitfullscreen", function () {
                  !(function (e, t) {
                    if (e.originalLayout) {
                      var i = e.originalLayout;
                      (e.el().style.height = i.container.height),
                        (e.el().style.width = i.container.width),
                        (e.tag.style.width = i.video.width),
                        (e.tag.style.height = i.video.height);
                    }
                  })(e),
                    e.trigger("x5cancelFullScreen"),
                    e.fullscreenService.getIsFullScreen() &&
                      e.fullscreenService.cancelFullScreen();
                }),
                e.on("requestFullScreen", function () {
                  "top" == e._options.x5_video_position &&
                    o.removeClass(e.tag, "x5-top-left"),
                    r.os.android &&
                      r.is_X5 &&
                      e._options.x5LandscapeAsFullScreen &&
                      (e.tag.setAttribute("x5-video-orientation", "landscape"),
                      (e._x5VideoOrientation = "landscape"));
                }),
                e.on("cancelFullScreen", function () {
                  "top" == e._options.x5_video_position &&
                    o.addClass(e.tag, "x5-top-left"),
                    r.os.android &&
                      r.is_X5 &&
                      e._options.x5LandscapeAsFullScreen &&
                      (e.tag.setAttribute("x5-video-orientation", "portrait"),
                      n(
                        e,
                        e._options.x5_fullscreen ||
                          "center" == e._options.x5_video_position
                      ),
                      (e._x5VideoOrientation = "portrait"));
                })),
              void 0 !== e._options.x5_fullscreen &&
                e._options.x5_fullscreen &&
                (e.tag.setAttribute(
                  "x5-video-player-fullscreen",
                  e._options.x5_fullscreen
                ),
                o.addClass(e.tag, "x5-full-screen")),
              "top" == e._options.x5_video_position &&
                o.addClass(e.tag, "x5-top-left"),
              void 0 !== e._options.x5_orientation &&
                e.tag.setAttribute(
                  "x5-video-orientation",
                  e._options.x5_orientation
                ));
          });
      },
      { "../../lib/dom": 18, "../../lib/ua": 31 },
    ],
    68: [
      function (e, t, i) {
        var c = e("../../lib/io"),
          d = e("../../config"),
          p = e("../../lib/constants"),
          h = e("../../lib/util"),
          f = e("../../lib/playerutil"),
          _ = (e("../../lib/dom"), e("../../lang/index")),
          g = e("../base/event/eventtype"),
          y = e("../saas/drm");
        t.exports.inject = function (e, t, i, r, a, o, n) {
          var s = r.source;
          if (
            o ||
            (function (e, t) {
              return !(e._drm || !f.isDash(t));
            })(e, s)
          ) {
            (t.prototype._checkDrmReady = function () {
              if (null == e._drm)
                throw new Error("please invoke this method after ready event");
            }),
              (e._isDrm = !0),
              (e._drm = null),
              (e._isLoadedDrm = !1),
              (t.prototype.play = function (e) {
                this._checkDrmReady(), (this._isManualPlay = e || !1);
                if ((this.trigger(g.Private.Cover_Hide), this.tag.ended))
                  this.replay();
                else {
                  this.getCurrentTime();
                  this.tag.paused && this.tag.play();
                }
                return this;
              }),
              (t.prototype.replay = function () {
                if (this.tag.paused) {
                  this._monitor && this._monitor.replay();
                  var e = this;
                  this._drm
                    .load(this._options.source)
                    .then(function () {
                      (e._options._autoplay = !0),
                        e._initPlayBehavior(!0),
                        console.log("The video has now been loaded!");
                    })
                    ["catch"](u);
                }
                return this;
              }),
              (t.prototype.pause = function (e) {
                return (
                  this._checkDrmReady(),
                  (this._isManualPause = e || !1),
                  this.tag.pause(),
                  this
                );
              }),
              (t.prototype.stop = function () {
                return (
                  this._checkDrmReady(),
                  this.tag.setAttribute("src", null),
                  this
                );
              }),
              (t.prototype.initPlay = function (e) {
                if (h.contentProtocolMixed(s)) {
                  var t = {
                    mediaId: this._options.vid ? this._options.vid : "",
                    error_code: p.ErrorCode.InvalidSourceURL,
                    error_msg: "InvalidSourceURL",
                  };
                  return (
                    (t.display_msg = _.get("Request_Block_Text")),
                    void this.trigger(g.Player.Error, t)
                  );
                }
                function i(i, t) {
                  var r = !i._drm,
                    o = function () {
                      l(i, i._drm);
                      var e = {
                        drm: {
                          requestLicenseKey: y.requestLicenseKey(i),
                          servers: {},
                        },
                      };
                      p.DRMKeySystem[4] &&
                        ((e.drm.servers[p.DRMKeySystem[5]] =
                          "https://foo.bar/drm/widevine"),
                        (e.drm.servers[p.DRMKeySystem[4]] =
                          "https://foo.bar/drm/playready")),
                        i._drm.configure(e),
                        a && a(i._drm),
                        r && i._executeReadyCallback(),
                        i._drm
                          .load(i._options.source)
                          .then(function () {
                            i._initPlayBehavior(t),
                              console.log("The video has now been loaded!");
                          })
                          ["catch"](function (e) {
                            u(i, e);
                          });
                    },
                    n = function (e) {
                      if (!e || (i.__support && i.__support.drm[e])) o();
                      else {
                        var t = {
                          mediaId: i._options.vid ? i._options.vid : "",
                          error_code: p.ErrorCode.EncrptyVideoNotSupport,
                          error_msg: _.get("Not_Support_DRM"),
                        };
                        i.trigger(g.Player.Error, t);
                      }
                    };
                  i.destroy(function (t) {
                    try {
                      t._drm = new shaka.Player(t.tag);
                      var e = t._getItemBySource();
                      if (e) {
                        var i = p.DRMKeySystem[e.encryptionType];
                        t.__support
                          ? n(i)
                          : shaka.Player.probeSupport().then(function (e) {
                              (t.__support = e), n(i);
                            });
                      } else o();
                    } catch (e) {
                      console.log(e);
                    }
                  });
                }
                (that = this)._isLoadedDrm && "undefined" != typeof shaka
                  ? i(this, e)
                  : (this.trigger(g.Private.H5_Loading_Show),
                    function (e) {
                      var t = "aliplayer-drm-min.js",
                        i =
                          "https://" +
                          d.domain +
                          "/de/prismplayer/" +
                          d.h5Version +
                          "/drm/" +
                          t;
                      d.domain
                        ? -1 < d.domain.indexOf("g-assets.daily")
                          ? (i =
                              "http://" +
                              d.domain +
                              "/de/prismplayer/" +
                              d.h5Version +
                              "/drm/" +
                              t)
                          : -1 < d.domain.indexOf("localhost") &&
                            (i = "http://" + d.domain + "/build/drm/" + t)
                        : (i = "de/prismplayer/" + d.h5Version + "/drm/" + t);
                      var r = this;
                      c.loadJS(i, function () {
                        shaka.polyfill.installAll(), e.apply(r);
                      });
                    }.call(that, function () {
                      (this._isLoadedDrm = !0), i(this, e);
                    }));
              }),
              (t.prototype.destroy = function (e) {
                if (this._drm) {
                  var t = this;
                  this._drm.destroy().then(function () {
                    (t._drm = null), e(t);
                  });
                } else e(this);
              }),
              (t.prototype.dispose = function () {
                i.dispose.call(this), this.destroy();
              }),
              (t.prototype._getDRMEncryptItem = function () {
                var e = this._urls;
                if (e && 0 < e.length) {
                  for (var t = e.length, i = 0; i < t; i++) {
                    var r = e[i];
                    if (r.Url == this._options.source && 1 * r.encryption)
                      return r;
                  }
                  return "";
                }
                return "";
              }),
              (t.prototype._getItemBySource = function () {
                var e = this._urls;
                if (e && 0 < e.length) {
                  for (var t = e.length, i = 0; i < t; i++) {
                    var r = e[i];
                    if (r.Url == this._options.source) return r;
                  }
                  return "";
                }
                return "";
              });
            var l = function (t, e) {
              e.addEventListener("error", function (e) {
                !(function (e, t) {
                  u(e, t.detail);
                })(t, e);
              });
            };
          }
          function u(t, i) {
            var r = "Error code:" + i.code + "message:" + i.message;
            console.log(r);
            var o = p.ErrorCode.OtherError;
            r = _.get("Error_Play_Text");
            i.code == shaka.util.Error.Code.EXPIRED
              ? ((o = p.ErrorCode.AuthKeyExpired),
                (r = _.get("DRM_License_Expired")))
              : i.code == shaka.util.Error.Code.HTTP_ERROR
              ? ((o = p.ErrorCode.NetworkError), (r = _.get("Http_Error")))
              : i.code == shaka.util.Error.Code.HTTP_ERROR
              ? ((o = p.ErrorCode.LoadingTimeout), (r = _.get("Http_Timeout")))
              : i.category == shaka.util.Error.NETWORK &&
                ((o = p.ErrorCode.NetworkError),
                (r = _.get("Error_Network_Text")));
            !(function () {
              if (
                (setTimeout(function () {
                  t.trigger(g.Private.Play_Btn_Hide);
                }),
                t.checkOnline())
              ) {
                var e = {
                  mediaId: t._options.vid ? t._options.vid : "",
                  error_code: o,
                  error_msg: i.message,
                };
                t.logError(e),
                  (e.display_msg = i.code + "|" + r),
                  t.trigger(g.Player.Error, e);
              }
            })();
          }
        };
      },
      {
        "../../config": 5,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/dom": 18,
        "../../lib/io": 24,
        "../../lib/playerutil": 29,
        "../../lib/util": 33,
        "../base/event/eventtype": 43,
        "../saas/drm": 76,
      },
    ],
    69: [
      function (e, t, i) {
        var r = e("../base/player"),
          o = e("./drminjector"),
          n = r.extend({
            init: function (e, t) {
              o.inject(this, n, r.prototype, t, function (e) {}),
                (t._native = !1),
                r.call(this, e, t);
            },
          });
        t.exports = n;
      },
      { "../base/player": 62, "./drminjector": 68 },
    ],
    70: [
      function (e, t, i) {
        var o = e("../../ui/component"),
          n = e("../../lib/data"),
          s = e("../../lib/ua"),
          a = e("../../lib/constants"),
          l = e("../../lib/dom"),
          u = e("../../lib/object"),
          c = e("../../config"),
          d = e("../../lang/index"),
          p = e("../../lib/playerutil"),
          h = e("../../lib/util"),
          r = e("../../ui/component/info-display"),
          f = e("../../ui/component/error-display"),
          _ = e("../../feature/autoPlayDelay"),
          g = e("../../commonui/autostreamselector"),
          y = e("../base/event/eventtype"),
          v = e("../saas/ststoken"),
          m = o.extend({
            init: function (e, t) {
              if (
                (void 0 === t.skinLayout &&
                  (t.skinLayout = p.defaultFlashLayout),
                o.call(this, this, t),
                (this._id = "prism-player-" + n.guid()),
                (this.tag = e),
                (this._el = this.tag),
                (this._childrenUI = [f]),
                this.initChildren(),
                (this.id = this._id),
                (window[this.id] = this),
                d.setCurrentLanguage(
                  this._options.language,
                  "flash",
                  this._options.languageTexts
                ),
                h.openInFile())
              ) {
                var i = {
                  mediaId: this._options.vid ? this._options.vid : "",
                  error_code: a.ErrorCode.FormatNotSupport,
                  error_msg: d.get("Open_Html_By_File", "flash"),
                };
                this.trigger(y.Private.Error_Show, i);
              } else if (s.IS_MOBILE)
                this.trigger(y.Private.Error_Show, {
                  mediaId: this._options.vid ? this._options.vid : "",
                  error_code: a.ErrorCode.FormatNotSupport,
                  error_msg: d.get("Cant_Use_Flash_On_Mobile", "flash"),
                });
              else {
                if (
                  this._options.vid &&
                  this._options.accessKeyId &&
                  this._options.securityToken &&
                  this._options.accessKeySecret
                ) {
                  var r = this;
                  v.getPlayAuth(
                    this._options,
                    function (e) {
                      (r._options.playauth = e), r._createPlayer();
                    },
                    function (e) {
                      var t = {
                        mediaId: r._options.vid,
                        error_code: e.Code,
                        error_msg: e.Message,
                      };
                      e.sri && (t.sri = e.sri),
                        (t.display_msg = e.display_msg),
                        r.trigger(y.Private.Error_Show, t);
                    },
                    "flash"
                  );
                } else this._createPlayer();
                this._status = "init";
              }
            },
            _createPlayer: function () {
              if (this._options.autoPlayDelay) {
                var e = new _(this),
                  t = this;
                e.handle(function () {
                  (t._options.autoplay = !0),
                    t._initPlayer(),
                    (t._childrenUI = [r, g]),
                    t.initChildren();
                });
              } else
                this._initPlayer(),
                  (this._childrenUI = [r, g]),
                  this.initChildren();
              if (!s.HAS_FLASH) {
                var i = d.get("Flash_Not_Ready", "flash");
                this.trigger(y.Private.Info_Show, {
                  text: i,
                  align: "tc",
                  isBlack: !1,
                });
              }
            },
            _initPlayer: function () {
              var e =
                "//" +
                c.domain +
                "/de/prismplayer-flash/" +
                c.flashVersion +
                "/PrismPlayer.swf";
              this._options.playerSwfPath
                ? (e = this._options.playerSwfPath)
                : c.domain
                ? -1 < c.domain.indexOf("localhost") &&
                  (e = "//" + c.domain + "/build/flash//PrismPlayer.swf")
                : (e =
                    "de/prismplayer-flash/" +
                    c.flashVersion +
                    "/PrismPlayer.swf");
              var t = this._comboFlashVars(),
                i = this._options.wmode ? this._options.wmode : "opaque";
              this.tag.innerHTML =
                '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="//download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0" width="100%" height="100%" id="' +
                this.id +
                '"><param name=movie value="' +
                e +
                '"><param name=quality value=High><param name="FlashVars" value="' +
                t +
                '"><param name="WMode" value="' +
                i +
                '"><param name="AllowScriptAccess" value="always"><param name="AllowFullScreen" value="true"><param name="AllowFullScreenInteractive" value="true"><embed name="' +
                this.id +
                '" src="' +
                e +
                '" quality=high pluginspage="//www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" width="100%" height="100%" AllowScriptAccess="always" AllowFullScreen="true" AllowFullScreenInteractive="true" WMode="' +
                i +
                '" FlashVars="' +
                t +
                '"></embed></object>';
            },
            _getPlayer: function (e) {
              return -1 != navigator.appName.indexOf("Microsoft")
                ? document.getElementById(e)
                : document[e];
            },
            _getLowerQualityLevel: function () {
              var e = this._getVideoUrls();
              if (!e) return "";
              var t = e.Urls,
                i = e.index;
              return (t && 0 == t.length) || -1 == i
                ? ""
                : 0 < i
                ? { item: t[i - 1], index: i - 1 }
                : "";
            },
            _comboFlashVars: function () {
              var e = encodeURIComponent(s.getReferer()),
                t = s.getHref(),
                i = encodeURIComponent(t),
                r = "";
              t && (r = s.getHost(t));
              var o = this._options,
                n = {
                  autoPlay: o.autoplay ? 1 : 0,
                  isInner: 0,
                  actRequest: 1,
                  vid: o.vid,
                  diagnosisButtonVisible: o.diagnosisButtonVisible ? 1 : 0,
                  domain: o.domain ? o.domain : "//tv.taobao.com",
                  statisticService: o.statisticService
                    ? o.statisticService
                    : c.logReportTo,
                  videoInfoService: o.videoInfoService
                    ? o.videoInfoService
                    : "/player/json/getBaseVideoInfo.do",
                  disablePing: o.trackLog ? 0 : 1,
                  namespace: this.id,
                  barMode: 0 != o.barMode ? 1 : 0,
                  isLive: o.isLive ? 1 : 0,
                  waterMark: o.waterMark,
                  environment: o.environment,
                  vurl: o.source ? encodeURIComponent(o.source) : "",
                  plugins: o.plugins ? o.plugins : "",
                  snapShotShow: o.snapshot ? 1 : 0,
                  accessId: o.accId ? o.accId : "",
                  accessKey: o.accSecret ? o.accSecret : "",
                  apiKey: o.apiKey ? o.apiKey : "",
                  flashApiKey: o.flashApiKey ? o.flashApiKey : "",
                  disableSeek: o.disableSeek ? 1 : 0,
                  disableFullScreen: o.disableFullScreen ? 1 : 0,
                  stsToken: o.stsToken ? o.stsToken : "",
                  domainRegion: o.domainRegion ? o.domainRegion : "",
                  authInfo: o.authInfo ? encodeURIComponent(o.authInfo) : "",
                  playDomain: o.playDomain ? o.playDomain : "",
                  stretcherZoomType: o.stretcherZoomType
                    ? o.stretcherZoomType
                    : "",
                  playauth: o.playauth ? o.playauth.replace(/\+/g, "%2B") : "",
                  prismType: o.prismType ? o.prismType : 0,
                  formats: o.formats ? o.formats : "",
                  notShowTips: o.notShowTips ? 1 : 0,
                  showBarTime: o.showBarTime ? o.showBarTime : 0,
                  showBuffer: 0 == o.showBuffer ? 0 : 1,
                  rePlay: o.rePlay ? 1 : 0,
                  encryp: o.encryp ? o.encryp : "",
                  secret: o.secret ? o.secret : "",
                  mediaType: "video",
                  logInfo: {
                    ud: s.getHost(o.source),
                    os: s.os.name,
                    ov: s.os.version || "",
                    et: s.browser.name,
                    ev: s.browser.version || "",
                    uat: s.USER_AGENT,
                    r: e,
                    pu: i,
                    app_n: r,
                  },
                },
                a = [];
              return (
                void 0 !== o.rtmpBufferTime &&
                  (n.rtmpBufferTime = o.rtmpBufferTime),
                o.cover && (n.cover = o.cover),
                o.extraInfo &&
                  (n.extraInfo = encodeURIComponent(
                    JSON.stringify(o.extraInfo)
                  )),
                n.logInfo &&
                  (n.logInfo = encodeURIComponent(JSON.stringify(n.logInfo))),
                (n.languageData = encodeURIComponent(
                  JSON.stringify(d.getLanguageData("flash"))
                )),
                (n.language = d.getCurrentLanguage()),
                u.each(n, function (e, t) {
                  a.push(e + "=" + t);
                }),
                a.join("&")
              );
            },
            initChildren: function () {
              for (var e = this._childrenUI.length, t = 0; t < e; t++) {
                var i = new this._childrenUI[t](this, this._options),
                  r = i.el();
                (r.id = i.id()), this.contentEl().appendChild(r), i.bindEvent();
              }
              var o = document.querySelector(
                "#" + this._options.id + " .prism-info-display"
              );
              l.css(o, "display", "none");
            },
            flashReady: function () {
              (this.flashPlayer = this._getPlayer(this.id)),
                (this._isReady = !0);
              var e,
                t = this._options.skinRes,
                i = this._options.skinLayout;
              if (!1 !== i && !u.isArray(i))
                throw new Error(
                  "PrismPlayer Error: skinLayout should be false or type of array!"
                );
              if ("string" != typeof t)
                throw new Error("PrismPlayer Error: skinRes should be string!");
              (e = 0 != i && 0 !== i.length && { skinRes: t, skinLayout: i }),
                this.flashPlayer.setPlayerSkin(e),
                this.trigger("ready");
              var r = this;
              window.addEventListener("beforeunload", function () {
                try {
                  r.flashPlayer.setPlayerCloseStatus();
                } catch (e) {}
              });
            },
            jsReady: function () {
              return !0;
            },
            snapshoted: function (e) {
              var t = h.toBinary(e),
                i = "data:image/jpeg;base64," + e;
              this.trigger("snapshoted", {
                time: this.getCurrentTime(),
                base64: i,
                binary: t,
              });
            },
            uiReady: function () {
              (this._status = "ready"), this.trigger("uiReady");
            },
            loadedmetadata: function () {
              "ended" != this._status &&
                ((this._status = "loading"), this.trigger("loadedmetadata"));
            },
            onPlay: function () {
              (this._status = "play"),
                this.trigger("play"),
                this._clearTimeoutHandle(),
                this.trigger(y.Private.AutoStreamHide);
            },
            onEnded: function () {
              this._clearTimeoutHandle(),
                (this._status = "ended"),
                this.trigger("ended");
            },
            onPause: function () {
              (this._status = "pause"),
                this._clearTimeoutHandle(),
                this.trigger(y.Private.AutoStreamHide),
                this.trigger("pause");
            },
            onBulletScreenReady: function () {
              this.trigger("bSReady");
            },
            onBulletScreenMsgSend: function (e) {
              this.trigger("bSSendMsg", e);
            },
            onVideoRender: function (e) {
              this._clearTimeoutHandle(),
                this.trigger("videoRender"),
                this.trigger("canplay", { loadtime: e });
            },
            onVideoError: function (e) {
              this._clearTimeoutHandle(),
                (this._status = "error"),
                this.trigger("error", { errortype: e });
            },
            onM3u8Retry: function () {
              this.trigger("m3u8Retry");
            },
            hideBar: function () {
              this.trigger("hideBar");
            },
            showBar: function () {
              this.trigger("showBar");
            },
            liveStreamStop: function () {
              this.trigger("liveStreamStop");
            },
            stsTokenExpired: function () {
              (this._status = "error"), this.trigger("stsTokenExpired");
            },
            onVideoBuffer: function () {
              if ("pause" != this._status) {
                (this._status = "waiting"),
                  this.trigger("waiting"),
                  this._clearTimeoutHandle();
                var e = this;
                (this._checkTimeoutHandle = setTimeout(function () {
                  e.trigger(y.Private.AutoStreamShow);
                }, 1e3 * this._options.loadDataTimeout)),
                  this._checkVideoStatus();
              }
            },
            startSeek: function (e) {
              this.trigger("startSeek", e);
            },
            completeSeek: function (e) {
              this.trigger("completeSeek", e);
            },
            _invoke: function () {
              var e = arguments[0],
                t = arguments;
              if ((Array.prototype.shift.call(t), !this.flashPlayer))
                throw new Error(
                  "PrismPlayer Error: flash player is not ready\uff0cplease use api after ready event occured!"
                );
              if ("function" != typeof this.flashPlayer[e])
                throw new Error(
                  "PrismPlayer Error: function " + e + " is not found!"
                );
              return this.flashPlayer[e].apply(this.flashPlayer, t);
            },
            play: function () {
              this._invoke("playVideo");
            },
            replay: function () {
              this._invoke("replayVideo");
            },
            pause: function () {
              this._invoke("pauseVideo");
            },
            stop: function () {
              this._invoke("stopVideo");
            },
            seek: function (e) {
              this._invoke("seekVideo", e);
            },
            getCurrentTime: function () {
              return this._invoke("getCurrentTime");
            },
            getDuration: function () {
              return this._invoke("getDuration");
            },
            getStatus: function () {
              return this._status;
            },
            _getVideoUrls: function () {
              var e = this._invoke("getVideoUrls"),
                t = [];
              if (e && e.Urls)
                for (var i = 0; i < e.Urls.length; i++) {
                  var r = e.Urls[i].value,
                    o = r.desc.indexOf("_"),
                    n = d.get(r.definition, "flash");
                  (r.desc = 0 < o ? n + "_" + r.height : n), t.push(r);
                }
              return { Urls: t, index: e.index };
            },
            _getVideoStatus: function () {
              return this._invoke("getVideoStatus");
            },
            _checkVideoStatus: function () {
              if (this.flashPlayer && !this._checkVideoStatusHandler) {
                var t = this,
                  i = function () {
                    t._checkVideoStatusHandler = setTimeout(function () {
                      var e = t._getVideoStatus();
                      "playing" == e.videoStatus &&
                      "bufferFull" == e.bufferStatus
                        ? ((t._status = "playing"), t._clearTimeoutHandle())
                        : "videoPlayOver" == e.videoStatus &&
                          ((t._status = "ended"), t._clearTimeoutHandle()),
                        i();
                    }, 500);
                  };
                i();
              }
            },
            _clearTimeoutHandle: function () {
              this._checkTimeoutHandle &&
                (clearTimeout(this._checkTimeoutHandle),
                (this._checkTimeoutHandle = null));
            },
            _changeStream: function (e) {
              return this._invoke("changeStream", e);
            },
            mute: function () {
              this.setVolume(0);
            },
            unMute: function () {
              this.setVolume(0.5);
            },
            getVolume: function () {
              return this._invoke("getVolume");
            },
            setVolume: function (e) {
              this._invoke("setVolume", e);
            },
            loadByVid: function (e) {
              this._invoke("loadByVid", e, !1);
            },
            loadByUrl: function (e, t) {
              this._invoke("loadByUrl", e, t);
            },
            dispose: function () {
              this._clearTimeoutHandle(),
                this._checkVideoStatusHandler &&
                  (clearTimeout(this._checkVideoStatusHandler),
                  (this._checkVideoStatusHandler = null)),
                this._invoke("pauseVideo");
              var e = this;
              setTimeout(function () {
                e.off("completeSeek"),
                  e.off("startSeek"),
                  e.off("stsTokenExpired"),
                  e.off("liveStreamStop"),
                  e.off("showBar"),
                  e.off("hideBar"),
                  e.off("m3u8Retry"),
                  e.off("error"),
                  e.off("canplay"),
                  e.off("pause"),
                  e.off("ended"),
                  e.off("play"),
                  e.off("loadedmetadata"),
                  e.off("snapshoted"),
                  e.off("uiReady"),
                  e.off("ready"),
                  (e.flashPlayer = null),
                  e._el && (e._el.innerHTML = "");
              });
            },
            showBSMsg: function (e) {
              this._invoke("showBSMsg", e);
            },
            setToastEnabled: function (e) {
              this._invoke("setToastEnabled", e);
            },
            setLoadingInvisible: function () {
              this._invoke("setLoadingInvisible");
            },
            setPlayerSize: function (e, t) {
              (this._el.style.width = e), (this._el.style.height = t);
            },
          });
        t.exports = m;
      },
      {
        "../../commonui/autostreamselector": 2,
        "../../config": 5,
        "../../feature/autoPlayDelay": 7,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/data": 17,
        "../../lib/dom": 18,
        "../../lib/object": 26,
        "../../lib/playerutil": 29,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../../ui/component": 94,
        "../../ui/component/error-display": 99,
        "../../ui/component/info-display": 102,
        "../base/event/eventtype": 43,
        "../saas/ststoken": 81,
      },
    ],
    71: [
      function (e, t, i) {
        var a = e("../../lib/io"),
          d = e("../../config"),
          p = e("../../lib/constants"),
          h = e("../../lib/util"),
          u = e("../../lib/playerutil"),
          c = (e("../../lib/dom"), e("../../lib/ua")),
          f = e("../../lang/index"),
          _ = e("../base/event/eventtype");
        e("../base/player");
        t.exports.inject = function (e, t, i, r, s, o) {
          var n = r.source;
          if (
            o ||
            (function (e, t) {
              return !(e._flv || !u.isFlv(t));
            })(e, n)
          ) {
            (e._Type = t),
              (e._superType = i),
              (e._superPt = i.prototype),
              (e._disposed = !1),
              (t.prototype._checkFlvReady = function () {
                if (null == e._flv)
                  throw new Error(
                    "please invoke this method after ready event"
                  );
              }),
              (e._isFlv = !0),
              (e._flv = null),
              (e._isLoadedFlv = !1),
              (e._originalUrl = ""),
              (t.prototype.play = function (e) {
                this._checkFlvReady(), (this._isManualPlay = e || !1);
                if (
                  (this.trigger(_.Private.Cover_Hide),
                  this._options.isLive && e)
                )
                  this._loadByUrlInner(this._options.source, 0, liveForceLoad);
                else if (this.tag.ended || this._ended) this.replay();
                else {
                  if (0 == this._seeking) {
                    var t = 0;
                    this.tag.ended ||
                      this._ended ||
                      (0 == (t = this.getCurrentTime()) && (t = -1)),
                      -1 != t && this.seek(t);
                  }
                  this.tag.paused &&
                    (this._hasLoaded || (this.getMetaData(), this._flv.load()),
                    this._flv.play());
                }
                return this;
              }),
              (t.prototype.seek = function (e) {
                this._checkFlvReady(), e === this.tag.duration && e--;
                try {
                  this._flv.currentTime = e;
                } catch (e) {
                  console.log(e);
                }
                return this;
              }),
              (t.prototype.pause = function (e) {
                return (
                  this._checkFlvReady(),
                  (this._isManualPause = e || !1),
                  this._flv.pause(),
                  this
                );
              }),
              (t.prototype.getProgramDateTime = function () {
                if ((this._checkFlvReady(), !this._metadata)) return "";
                var e = this._flv.getFirstSample(),
                  t = e && e.pts ? e.pts : 0;
                return (
                  console.log(
                    "\u63a8\u6d41\u65f6\u95f4\uff1a" + this._metadata.NtpTime
                  ),
                  console.log("\u9996\u5e27PTS\uff1a" + t),
                  this._metadata.NtpTime + t
                );
              }),
              (t.prototype.initPlay = function (e) {
                if (
                  (c.browser.safari && this.trigger(_.Private.Snapshot_Hide),
                  h.contentProtocolMixed(n))
                ) {
                  var t = {
                    mediaId: this._options.vid ? this._options.vid : "",
                    error_code: p.ErrorCode.InvalidSourceURL,
                    error_msg: "InvalidSourceURL",
                  };
                  return (
                    (t.display_msg = f.get("Request_Block_Text")),
                    void this.trigger(_.Player.Error, t)
                  );
                }
                function i(t, e) {
                  var i = !t._flv;
                  t._destroyFlv();
                  var r = t._options.isLive,
                    o = {
                      isLive: r,
                      enableWorker: t._options.enableWorker,
                      stashInitialSize: 2048,
                    },
                    n = { type: "flv", isLive: r, url: t._options.source };
                  for (var a in (r
                    ? ((o.enableStashBuffer =
                        t._options.enableStashBufferForFlv),
                      (stashInitialSize = t._options.stashInitialSizeForFlv),
                      (o.autoCleanupSourceBuffer = !1))
                    : (o.lazyLoadMaxDuration = 600),
                  t._options.flvOption))
                    "cors" == a ||
                    "hasAudio" == a ||
                    "withCredentials" == a ||
                    "hasVideo" == a ||
                    "type" == a
                      ? (n[a] = t._options.flvOption[a])
                      : (o[a] = t._options.flvOption[a]);
                  (t._originalUrl = t._options.source),
                    (flvjs.LoggingControl.enableAll = t._options.debug),
                    (t._flv = flvjs.createPlayer(n, o)),
                    l(t, t._flv),
                    t._flv.on(flvjs.Events.MEDIA_INFO, function (e) {
                      t._metadata = e.metadata;
                    }),
                    t._flv.attachMediaElement(t.tag),
                    t._initPlayBehavior(e) &&
                      ((t._options.preload || t._options.autoplay) &&
                        ((t._hasLoaded = !0), t._flv.load()),
                      t._options.autoplay && !t.tag.paused && t._flv.play(),
                      s && s(t._flv),
                      i && t._executeReadyCallback());
                }
                (that = this)._isLoadedFlv && "undefined" != typeof Hls
                  ? setTimeout(function () {
                      i(that, e);
                    }, 1e3)
                  : (this.trigger(_.Private.H5_Loading_Show),
                    function (e, t) {
                      var i = "aliplayer-flv-min.js",
                        r =
                          "https://" +
                          d.domain +
                          "/de/prismplayer/" +
                          d.h5Version +
                          "/flv/" +
                          i;
                      d.domain
                        ? -1 < d.domain.indexOf("g-assets.daily")
                          ? (r =
                              "http://" +
                              d.domain +
                              "/de/prismplayer/" +
                              d.h5Version +
                              "/flv/" +
                              i)
                          : -1 < d.domain.indexOf("localhost") &&
                            (r = "http://" + d.domain + "/build/flv/" + i)
                        : (r = "de/prismplayer/" + d.h5Version + "/flv/" + i);
                      var o = this;
                      a.loadJS(r, function () {
                        e.apply(o);
                      });
                    }.call(
                      that,
                      function () {
                        (this._isLoadedFlv = !0), i(that, e);
                      },
                      this._options.debug
                    ));
              }),
              (t.prototype._destroyFlv = function () {
                try {
                  this._flv && (this._flv.pause(), this._flv.destroy());
                } catch (e) {
                  console.log(e);
                }
                (this.loaded = !1), (this._hasLoaded = !1), (this._flv = null);
              }),
              (t.prototype.dispose = function () {
                this._disposed ||
                  ((this._disposed = !0),
                  this._superPt && this._superPt.dispose.call(this),
                  this._destroyFlv(),
                  this._superPt &&
                    ((t.prototype.play = this._superPt.play),
                    (t.prototype.pause = this._superPt.pause),
                    (t.prototype.initPlay = this._superPt.initPlay),
                    (t.prototype.seek = this._superPt.seek),
                    (t.prototype.canSeekable = this._superPt.canSeekable)));
              }),
              (t.prototype.canSeekable = function (e) {
                var t = this._flv.mediaInfo;
                return !(
                  !this._flv._isTimepointBuffered(e) &&
                  t &&
                  !t.hasKeyframesIndex
                );
              });
            var l = function (u, e) {
              var c = !1;
              e.on(flvjs.Events.ERROR, function (e, t, i) {
                var r = p.ErrorCode.OtherError,
                  o = f.get("Error_Play_Text");
                if (t == flvjs.ErrorDetails.NETWORK_EXCEPTION) {
                  var n = u.getOptions().source;
                  !n ||
                  (0 != n.toLowerCase().indexOf("http://") &&
                    0 != n.toLowerCase().indexOf("https://"))
                    ? ((r = p.ErrorCode.InvalidSourceURL),
                      (o = f.get("Error_Invalidate_Source_Widthout_Protocal")),
                      (c = !0))
                    : (o = navigator.onLine
                        ? ((r = p.ErrorCode.RequestDataError),
                          f.get("Maybe_Cors_Error"))
                        : ((r = p.ErrorCode.NetworkError),
                          f.get("Error_Network_Text")));
                } else t == flvjs.ErrorDetails.NETWORK_STATUS_CODE_INVALID ? ("404" == i.code ? ((r = p.ErrorCode.NotFoundSourceURL), (o = f.get("Error_Not_Found"))) : "403" == i.code ? ((r = p.ErrorCode.AuthKeyExpired), (o = f.get("Error_AuthKey_Text")), (c = !0)) : ((r = p.ErrorCode.NetworkError), (o = f.get("Error_Network_Text")))) : t == flvjs.ErrorDetails.NETWORK_TIMEOUT ? ((r = p.ErrorCode.LoadingTimeout), (o = f.get("Error_Waiting_Timeout_Text"))) : (t != flvjs.ErrorDetails.MEDIA_FORMAT_UNSUPPORTED && t != flvjs.ErrorDetails.MEDIA_CODEC_UNSUPPORTED) || ((r = p.ErrorCode.FormatNotSupport), (o = f.get("Error_H5_Not_Support_Text")), (c = !0));
                var a = function () {
                  if (
                    (setTimeout(function () {
                      u.trigger(_.Private.Play_Btn_Hide);
                    }),
                    u.checkOnline())
                  ) {
                    var e = {
                      mediaId:
                        u._options && u._options.vid ? u._options.vid : "",
                      error_code: r,
                      error_msg: i.msg,
                    };
                    u.logError(e),
                      (e.display_msg = o),
                      d.cityBrain && (u.flv = null),
                      u.trigger(_.Player.Error, e);
                  }
                };
                if (u._options && u._options.isLive && !c) {
                  var s = u._options;
                  if (s.liveRetry > u._liveRetryCount) {
                    0 == u._liveRetryCount && u.trigger(_.Player.OnM3u8Retry);
                    var l =
                      s.liveRetryInterval + s.liveRetryStep * u._liveRetryCount;
                    u._liveRetryCount++,
                      h.sleep(1e3 * l),
                      u._loadByUrlInner(s.source);
                  } else
                    u._liveErrorHandle && clearTimeout(u._liveErrorHandle),
                      u.trigger(_.Player.LiveStreamStop),
                      (u._liveErrorHandle = setTimeout(a, 500));
                } else {
                  if (u._reloadForVod()) return;
                  a();
                }
              });
            };
          }
        };
      },
      {
        "../../config": 5,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/dom": 18,
        "../../lib/io": 24,
        "../../lib/playerutil": 29,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../base/event/eventtype": 43,
        "../base/player": 62,
      },
    ],
    72: [
      function (e, t, i) {
        var r = e("../base/player"),
          o = e("./flvinjector"),
          n = r.extend({
            init: function (e, t) {
              o.inject(this, n, r, t, function (e) {}),
                (t._native = !1),
                r.call(this, e, t);
            },
          });
        t.exports = n;
      },
      { "../base/player": 62, "./flvinjector": 71 },
    ],
    73: [
      function (e, t, i) {
        var c = e("../../lib/io"),
          d = e("../../config"),
          p = e("../../lib/constants"),
          h = e("../../lib/util"),
          f = e("../../lib/playerutil"),
          _ = (e("../../lib/dom"), e("../../lib/ua")),
          g = e("../../lang/index"),
          y = e("../base/event/eventtype");
        e("../base/player");
        t.exports.inject = function (e, t, i, r, n, o) {
          var a = r.source,
            s = r.useHlsPluginForSafari,
            l = r.useHlsPlugOnMobile;
          if (
            n ||
            o ||
            (function (e, t, i, r) {
              return !(
                e._hls ||
                !f.isHls(t) ||
                !(
                  !f.canPlayHls() ||
                  f.isSafariUsedHlsPlugin(i) ||
                  (r && f.isUsedHlsPluginOnMobile())
                )
              );
            })(e, a, s, l)
          ) {
            (e._Type = t),
              (e._superType = i),
              (e._superPt = i.prototype),
              (e._disposed = !1),
              (t.prototype._checkHlsReady = function () {
                if (null == e._hls)
                  throw new Error(
                    "please invoke this method after ready event"
                  );
              }),
              (e._isHls = !0),
              (e._hls = null),
              (e._isLoadedHls = !1),
              (e._stopLoadAsPaused = !0),
              (t.prototype.play = function (e) {
                this._checkHlsReady(), (this._isManualPlay = e || !1);
                if (
                  (this.trigger(y.Private.Cover_Hide),
                  this._options.autoplay ||
                    this._options.preload ||
                    this._loadSourced ||
                    ((this._loadSourced = !0),
                    (this._options._autoplay = !0),
                    this._hls.loadSource(this._options.source)),
                  this.tag.ended || this._ended)
                )
                  this.replay();
                else if (
                  this.tag.paused &&
                  (this.tag.play(), this._stopLoadAsPaused)
                ) {
                  var t = this.getCurrentTime();
                  this._hls.startLoad(t);
                }
                return this;
              }),
              (t.prototype.replay = function () {
                return (
                  this._monitor && this._monitor.replay(),
                  this._hls.startLoad(0),
                  this.tag.play(),
                  this
                );
              }),
              (t.prototype.pause = function (e) {
                return (
                  this.tag &&
                    (this._checkHlsReady(),
                    this.tag.pause(),
                    this._stopLoadAsPaused && this._hls.stopLoad()),
                  (this._isManualPause = e || !1),
                  this
                );
              }),
              (t.prototype.stop = function () {
                return (
                  this._checkHlsReady(),
                  this.tag.setAttribute("src", null),
                  this._hls.stopLoad(),
                  this
                );
              }),
              (t.prototype.seek = function (e) {
                this._checkHlsReady();
                try {
                  this._superPt.seek.call(this, e),
                    this.tag.paused &&
                      this._stopLoadAsPaused &&
                      this._hls.startLoad(e);
                } catch (e) {
                  console.log(e);
                }
                return this;
              }),
              (t.prototype.getProgramDateTime = function () {
                if ((this._checkHlsReady(), -1 == this._hls.currentLevel))
                  return "";
                var e = this._hls.currentLevel,
                  t = this._hls.levels[e].details;
                if (t) {
                  var i = t.programDateTime;
                  if ((console.log("ProgramDateTime=" + i), i))
                    return new Date(i).valueOf();
                }
                return 0;
              }),
              (t.prototype._reloadAndPlayForM3u8 = function () {
                0 == this._liveRetryCount && this.trigger(y.Player.OnM3u8Retry),
                  this._liveRetryCount++;
              }),
              (t.prototype._switchLevel = function (e) {
                this.trigger(y.Player.LevelSwitch);
                for (var t = this._hls.levels, i = 0; i < t.length; i++)
                  if (t[i].url == e) {
                    this._hls.currentLevel = i;
                    break;
                  }
                this._switchedLevel = !0;
                var r = this;
                setTimeout(function () {
                  r.trigger(y.Player.LevelSwitched), (this._switchedLevel = !1);
                }, 1e3);
              }),
              (t.prototype.initPlay = function (e) {
                if (h.contentProtocolMixed(a)) {
                  var t = {
                    mediaId: this._options.vid ? this._options.vid : "",
                    error_code: p.ErrorCode.InvalidSourceURL,
                    error_msg: "InvalidSourceURL",
                  };
                  return (
                    (t.display_msg = g.get("Request_Block_Text")),
                    void this.trigger(y.Player.Error, t)
                  );
                }
                function i(a, e) {
                  var t = !a._hls;
                  a._destroyHls();
                  var i = {
                      xhrSetup: function (e, t) {
                        e.withCredentials = a._options.withCredentials || !1;
                      },
                    },
                    r =
                      a._options.loadingTimeOut || a._options.hlsLoadingTimeOut;
                  for (var o in (r &&
                    ((i.manifestLoadingTimeOut = r),
                    (i.levelLoadingTimeOut = r),
                    (i.fragLoadingTimeOut = r)),
                  a._options.nudgeMaxRetry &&
                    (i.nudgeMaxRetry = a._options.nudgeMaxRetry),
                  a._options.maxMaxBufferLength &&
                    (i.maxMaxBufferLength = a._options.maxMaxBufferLength),
                  a._options.maxBufferSize &&
                    (i.maxBufferSize = a._options.maxBufferSize),
                  a._options.maxBufferLength &&
                    (i.maxBufferLength = a._options.maxBufferLength),
                  n && (i._sce_dlgtqredxx = n),
                  (i.enableWorker = a._options.enableWorker),
                  (i.debug = a._options.debug),
                  (a._stopLoadAsPaused = a._options.hlsOption.stopLoadAsPaused),
                  a._options.hlsOption))
                    i[o] = a._options.hlsOption[o];
                  _.IS_IE11 && n && (i.enableWorker = !1),
                    (a._hls = new Hls(i)),
                    u(a, a._hls),
                    (a._loadSourced = !1),
                    a._hls.attachMedia(a.tag),
                    a._hls.on(Hls.Events.MEDIA_ATTACHED, function () {
                      (a._options.autoplay || a._options.preload || e) &&
                        ((a._loadSourced = !0),
                        a._hls.loadSource(a._options.source)),
                        a._hls.on(Hls.Events.MANIFEST_PARSED, function () {
                          a._initPlayBehavior(e || a._loadSourced);
                        }),
                        a._hls.on(
                          Hls.Events.AUDIO_TRACKS_UPDATED,
                          function (e, t) {
                            a.trigger(y.Player.AudioTrackUpdated, t);
                          }
                        ),
                        a._hls.on(Hls.Events.MANIFEST_LOADED, function (e, t) {
                          a.trigger(y.Player.LevelsLoaded, t);
                        }),
                        a._hls.on(Hls.Events.LEVEL_SWITCHED, function (e, t) {
                          if (a._qualityService) {
                            for (
                              var i = a._hls.levels[t.level].url,
                                r = a._qualityService.levels,
                                o = "",
                                n = 0;
                              n < r.length;
                              n++
                            )
                              if (r[n].Url == i) {
                                o = r[n].desc;
                                break;
                              }
                            o &&
                              a.trigger(y.Private.QualityChange, {
                                levelSwitch: !0,
                                url: i,
                                desc: o,
                              });
                          }
                        }),
                        a._hls.on(
                          Hls.Events.AUDIO_TRACK_SWITCH,
                          function (e, t) {
                            a.trigger(y.Player.AudioTrackSwitch, t),
                              setTimeout(function () {
                                a.trigger(y.Player.AudioTrackSwitched, t);
                              }, 1e3);
                          }
                        ),
                        t && a._executeReadyCallback();
                    });
                }
                this._isLoadedHls && "undefined" != typeof Hls
                  ? i(this, e)
                  : (this.trigger(y.Private.H5_Loading_Show),
                    function (e, t, i) {
                      var r = "aliplayer-hls-min.js",
                        o = "/iyplayer/default/js/hls.js";
                      var n = this;
                      c.loadJS(o, function () {
                        e.apply(n);
                      });
                    }.call(
                      this,
                      function () {
                        (this._isLoadedHls = !0), i(this, e);
                      },
                      this._options.debug
                    ));
              }),
              (t.prototype._destroyHls = function () {
                this._hls && this._hls.destroy(), (this._hls = null);
              }),
              (t.prototype.dispose = function () {
                this._disposed ||
                  ((this._disposed = !0),
                  this._superPt && this._superPt.dispose.call(this),
                  this._destroyHls(),
                  this._superPt &&
                    ((t.prototype.play = this._superPt.play),
                    (t.prototype.pause = this._superPt.pause),
                    (t.prototype.initPlay = this._superPt.initPlay),
                    (t.prototype.replay = this._superPt.replay),
                    (t.prototype.stop = this._superPt.stop),
                    (t.prototype.seek = this._superPt.seek)));
              });
            var u = function (l, e) {
              e.on(Hls.Events.ERROR, function (e, t) {
                if (
                  l._options &&
                  t.details != Hls.ErrorDetails.FRAG_LOOP_LOADING_ERROR &&
                  1 != l._seeking &&
                  (0 != t.fatal || t.type == Hls.ErrorTypes.NETWORK_ERROR)
                ) {
                  l._clearTimeout();
                  var i = p.ErrorCode.LoadedMetadata,
                    r = g.get("Error_Play_Text"),
                    o = !1;
                  if (t.details == Hls.ErrorDetails.MANIFEST_LOAD_ERROR) {
                    o = !0;
                    t.networkDetails;
                    r = t.response
                      ? "404" == t.response.code
                        ? ((i = p.ErrorCode.NotFoundSourceURL),
                          g.get("Error_Not_Found"))
                        : "403" == t.response.code
                        ? ((i = p.ErrorCode.AuthKeyExpired),
                          g.get("Error_AuthKey_Text"))
                        : "0" == t.response.code && navigator.onLine
                        ? ((i = p.ErrorCode.RequestDataError),
                          r + "\uff0c" + g.get("Maybe_Cors_Error"))
                        : g.get("Error_Load_M3U8_Failed_Text")
                      : g.get("Error_Load_M3U8_Failed_Text");
                  } else
                    t.details == Hls.ErrorDetails.MANIFEST_LOAD_TIMEOUT
                      ? ((o = !0), (r = g.get("Error_Load_M3U8_Timeout_Text")))
                      : t.details == Hls.ErrorDetails.MANIFEST_PARSING_ERROR ||
                        t.details ==
                          Hls.ErrorDetails.MANIFEST_INCOMPATIBLE_CODECS_ERROR
                      ? ((o = !0), (r = g.get("Error_M3U8_Decode_Text")))
                      : t.type == Hls.ErrorTypes.NETWORK_ERROR
                      ? ((i = p.ErrorCode.NetworkError),
                        (r = g.get("Error_Network_Text")))
                      : (t.type != Hls.ErrorTypes.MUX_ERROR &&
                          t.type != Hls.ErrorTypes.MEDIA_ERROR) ||
                        ((i = p.ErrorCode.PlayDataDecode),
                        (r = g.get("Error_TX_Decode_Text")));
                  r = r + "(" + t.details + ")";
                  var n = function () {
                    if (
                      (l.pause(),
                      setTimeout(function () {
                        l.trigger(y.Private.Play_Btn_Hide);
                      }),
                      l.checkOnline())
                    ) {
                      var e = {
                        mediaId:
                          l._options && l._options.vid ? l._options.vid : "",
                        error_code: i,
                        error_msg: t.details,
                      };
                      l.logError(e),
                        (e.display_msg = r),
                        l.trigger(y.Player.Error, e);
                    }
                  };
                  if (l._options && l._options.isLive) {
                    var a = l._options;
                    if (a.liveRetry > l._liveRetryCount) {
                      0 == l._liveRetryCount && l.trigger(y.Player.OnM3u8Retry);
                      var s =
                        a.liveRetryInterval +
                        a.liveRetryStep * l._liveRetryCount;
                      l._liveRetryCount++,
                        h.sleep(1e3 * s),
                        o && l._loadByUrlInner(l._options.source, 0, !0);
                    } else
                      l._liveErrorHandle && clearTimeout(l._liveErrorHandle),
                        l.trigger(y.Player.LiveStreamStop),
                        (l._liveErrorHandle = setTimeout(n, 500));
                  } else {
                    if (l._reloadForVod()) return;
                    n();
                  }
                }
              });
            };
          }
        };
      },
      {
        "../../config": 5,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/dom": 18,
        "../../lib/io": 24,
        "../../lib/playerutil": 29,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../base/event/eventtype": 43,
        "../base/player": 62,
      },
    ],
    74: [
      function (e, t, i) {
        var r = e("../base/player"),
          o = e("./hlsinjector"),
          n = r.extend({
            init: function (e, t) {
              (t._native = !1), o.inject(this, n, r, t), r.call(this, e, t);
            },
          });
        t.exports = n;
      },
      { "../base/player": 62, "./hlsinjector": 73 },
    ],
    75: [
      function (e, t, i) {
        var r = e("../../lib/constants"),
          o = e("../../lib/oo").extend({
            init: function (e) {
              (this.player = e), (this.tickhandle = null);
            },
          });
        (o.prototype.tick = function (e, t) {
          var i = this;
          this.tickhandle = setTimeout(function () {
            i.player && i.player.trigger(r.AuthKeyExpiredEvent), t && t();
          }, 1e3 * e);
        }),
          (o.prototype.clearTick = function (e) {
            this.tickhandle && clearTimeout(this.tickhandle);
          }),
          (t.exports = o);
      },
      { "../../lib/constants": 15, "../../lib/oo": 27 },
    ],
    76: [
      function (e, t, i) {
        var l = e("../../lib/io"),
          u = (e("../../lib/ua"), e("../../lib/bufferbase64")),
          c = e("../../lib/constants"),
          d = e("./signature"),
          p = e("./util"),
          h = e("../../lang/index"),
          f = function (e, r, o) {
            var t = d.randomUUID(),
              i = "https://mts." + e.domainRegion + ".aliyuncs.com/?",
              n = {
                AccessKeyId: e.accessId,
                Action: "GetLicense",
                MediaId: e.vid,
                LicenseUrl: i,
                data: e.data,
                SecurityToken: e.stsToken,
                Format: "JSON",
                Type: e.encryptionType,
                Version: "2014-06-18",
                SignatureMethod: "HMAC-SHA1",
                SignatureVersion: "1.0",
                SignatureNonce: t,
              };
            e.header && (n.Header = e.header);
            var a =
                i +
                ("Signature=" +
                  d.AliyunEncodeURI(
                    d.makeChangeSiga(n, e.accessSecret, "POST")
                  )),
              s = d.makeUTF8sort(n, "=", "&");
            l.post(
              a,
              s,
              function (e) {
                if (e) {
                  var t = JSON.parse(e);
                  if (r) {
                    var i = t.License;
                    r(i);
                  }
                } else
                  o && o(p.createError("MPS\u83b7\u53d6License\u5931\u8d25"));
              },
              function (e) {
                if (o) {
                  var t = {
                    Code: "",
                    Message: h.get("Error_MTS_Fetch_Urls_Text"),
                  };
                  try {
                    t = JSON.parse(e);
                  } catch (e) {}
                  o({
                    Code: c.ErrorCode.ServerAPIError,
                    Message: t.Code + "|" + t.Message,
                    sri: t.requestId || "",
                  });
                }
              }
            );
          };
        t.exports.requestLicenseKey = function (e) {
          var l = e;
          return (
            l._options.vid && (l.__vid = l._options.vid),
            function (e, i) {
              var t = l._options,
                r = l._getDRMEncryptItem();
              if (r) {
                var o = {
                  vid: l.__vid,
                  accessId: t.accId,
                  accessSecret: t.accSecret,
                  stsToken: t.stsToken,
                  domainRegion: t.domainRegion,
                  authInfo: t.authInfo,
                  encryptionType: r.encryptionType,
                };
                if (r.encryptionType == c.EncryptionType.Widevine)
                  o.data = u.encode(e.message);
                else if (r.encryptionType == c.EncryptionType.PlayReady) {
                  var n = u.unpackPlayReady(e.message);
                  (o.data = n.changange),
                    n.header && (o.header = JSON.stringify(n.header));
                }
                console.log(o.data);
                var a = l.__licenseKeys,
                  s = l.__vid + r.Url;
                a && a[s],
                  f(
                    o,
                    function (e) {
                      l.__licenseKeys || (l.__licenseKeys = {}),
                        10 < o.data.length && (l.__licenseKeys[s] = e);
                      var t = u.decode(e);
                      i(t);
                    },
                    function (e) {
                      var t = {
                        mediaId: l.__vid,
                        error_code: e.Code,
                        error_msg: e.Message,
                      };
                      l.logError(t), l.trigger("error", t);
                    }
                  );
              }
            }
          );
        };
      },
      {
        "../../lang/index": 11,
        "../../lib/bufferbase64": 13,
        "../../lib/constants": 15,
        "../../lib/io": 24,
        "../../lib/ua": 31,
        "./signature": 80,
        "./util": 82,
      },
    ],
    77: [
      function (e, t, i) {
        var n = e("../../lib/io"),
          u = e("../../lib/constants"),
          c = e("./signature"),
          d = e("./util"),
          p = e("../../lang/index"),
          h = e("../../lib/ua");
        var f = function (e, o) {
            var t = "";
            e.sort(function (e, t) {
              var i = parseInt(e.bitrate),
                r = parseInt(t.bitrate);
              if ("desc" == o) {
                if (r < i) return -1;
                if (i < r) return 1;
              } else {
                if (i < r) return -1;
                if (r < i) return 1;
              }
            });
            for (var i = e.length, r = 0; r < i; r++) {
              var n = e[r],
                a = u.QualityLevels[n.definition],
                s = "";
              (s = void 0 === a ? n.bitrate : t == a ? a + n.bitrate : a),
                (n.desc = s),
                (t = a);
            }
          },
          _ = function (e, o) {
            var t = "";
            e.sort(function (e, t) {
              var i = parseInt(e.width),
                r = parseInt(t.width);
              if ("desc" == o) {
                if (r < i) return -1;
                if (i < r) return 1;
              } else {
                if (i < r) return -1;
                if (r < i) return 1;
              }
            });
            for (var i = e.length, r = 0; r < i; r++) {
              var n = e[r],
                a = u.QualityLevels[n.definition],
                s = "";
              (s = void 0 === a ? "" : t == a ? a + n.height : a),
                (n.desc = s),
                (t = a);
            }
          };
        t.exports.getDataByAuthInfo = function (e, a, s, l) {
          c.returnUTCDate(), c.randomUUID();
          var t = c.randomUUID(),
            i = {
              AccessKeyId: e.accessId,
              Action: "PlayInfo",
              MediaId: e.vid,
              Formats: e.format,
              AuthInfo: e.authInfo,
              AuthTimeout: e.authTimeout || u.AuthKeyExpired,
              IncludeSnapshotList: e.includeSnapshotList,
              Rand: e.rand,
              SecurityToken: e.stsToken,
              Format: "JSON",
              Version: "2014-06-18",
              SignatureMethod: "HMAC-SHA1",
              SignatureVersion: "1.0",
              Terminal: h.IS_CHROME
                ? "Chrome"
                : h.IS_EDGE
                ? "Edge"
                : h.IS_IE11
                ? "IE"
                : h.IS_SAFARI
                ? "Safari"
                : h.IS_FIREFOX
                ? "Firefox"
                : "",
              SignatureNonce: t,
            },
            r =
              c.makeUTF8sort(i, "=", "&") +
              "&Signature=" +
              c.AliyunEncodeURI(c.makeChangeSiga(i, e.accessSecret)),
            o = "https://mts." + e.domainRegion + ".aliyuncs.com/?" + r;
          n.get(
            o,
            function (e) {
              if (e) {
                var t = JSON.parse(e),
                  i = t.PlayInfoList.PlayInfo,
                  r = t.SnapshotList ? t.SnapshotList.Snapshot : [],
                  o = "";
                r && 0 < r.length && (o = r[0].Url);
                var n = (function (e, t) {
                  for (
                    var i = [], r = [], o = [], n = [], a = e.length - 1;
                    0 <= a;
                    a--
                  ) {
                    var s = e[a];
                    "mp4" == s.format
                      ? r.push(s)
                      : "mp3" == s.format
                      ? o.push(s)
                      : "m3u8" == s.format
                      ? i.push(s)
                      : n.push(s);
                  }
                  return 0 < o.length
                    ? (f(o, t), o)
                    : 0 < r.length
                    ? (_(r, t), r)
                    : 0 < i.length
                    ? (_(i, t), i)
                    : (_(n, t), n);
                })(i, a);
                s && s({ requestId: t.RequestId, urls: n, thumbnailUrl: o });
              } else
                l &&
                  l(d.createError("MPS\u83b7\u53d6\u53d6\u6570\u5931\u8d25"));
            },
            function (e) {
              if (l) {
                var t = {
                  Code: "",
                  Message: p.get("Error_MTS_Fetch_Urls_Text"),
                };
                try {
                  t = JSON.parse(e);
                } catch (e) {}
                l({
                  Code: u.ErrorCode.ServerAPIError,
                  Message: t.Code + "|" + t.Message,
                  sri: t.requestId || "",
                });
              }
            }
          );
        };
      },
      {
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/io": 24,
        "../../lib/ua": 31,
        "./signature": 80,
        "./util": 82,
      },
    ],
    78: [
      function (e, t, i) {
        var r = e("./saasplayer"),
          o = (e("../../lib/constants"), e("./mts")),
          n = r.extend({
            init: function (e, t) {
              r.call(this, e, t), (this.service = o), this.loadByMts();
            },
          });
        (n.prototype.loadByMts = function (e) {
          var t = {
            vid: this._options.vid,
            accessId: this._options.accId,
            accessSecret: this._options.accSecret,
            stsToken: this._options.stsToken,
            domainRegion: this._options.domainRegion,
            authInfo: this._options.authInfo,
            format: this._options.format,
            includeSnapshotList: this._options.includeSnapshotList || !1,
            defaultDefinition: this._options.defaultDefinition,
            authTimeout: this._options.authTimeout,
          };
          this.loadData(t, e);
        }),
          (n.prototype.replayByVidAndAuthInfo = function (e, t, i, r, o, n) {
            this.trigger("error_hide"),
              (this._options.source = ""),
              (this._isError = !1),
              (this._duration = 0),
              (this._options.cover = ""),
              (this._vodRetryCount = 0),
              this._clearTimeout(),
              this.reloadNewVideoInfo(e, t, i, r, o, n);
          }),
          (n.prototype.reloadNewVideoInfo = function (e, t, i, r, o, n) {
            if (
              (this.trigger("error_hide"),
              (this._options.source = ""),
              e &&
                ((this._options.vid = e),
                (this._options.accId = t),
                (this._options.accessSecret = i),
                (this._options.stsToken = r),
                (this._options.domainRegion = n),
                (this._options.authInfo = o)),
              !(
                this._options.vid &&
                this._options.accId &&
                this._options.accessSecret &&
                this._options.stsToken &&
                this._options.domainRegion &&
                this._options.authInfo
              ))
            )
              throw new Error(
                "\u9700\u8981\u63d0\u4f9bvid\u3001accId\u3001accessSecret\u3001stsToken\u3001domainRegion\u548cauthInfo\u53c2\u6570"
              );
            this.log(
              "STARTFETCHDATA",
              JSON.stringify({ it: "mps", pa: { vid: e } })
            ),
              this.loadByMts(!0);
          }),
          (t.exports = n);
      },
      { "../../lib/constants": 15, "./mts": 77, "./saasplayer": 79 },
    ],
    79: [
      function (e, t, i) {
        var c = e("../base/player"),
          r = e("../audio/audioplayer"),
          n = (e("../../lib/event"), e("../../lib/io")),
          d = e("../../lib/constants"),
          o = e("./signature"),
          a = e("./authkeyexpiredhandle"),
          p = e("../hls/hlsinjector"),
          h = e("../flv/flvinjector"),
          f = e("../drm/drminjector"),
          _ = (e("../../lib/cookie"), e("../../lang/index")),
          s = e("../../config"),
          g = e("../../lib/playerutil"),
          y = e("../base/event/eventtype"),
          v = c.extend({
            init: function (e, t) {
              (this._authKeyExpiredHandle = new a(this)),
                c.prototype._videoCreateEl ||
                  (c.prototype._videoCreateEl = c.prototype.createEl),
                "mp3" == t.format
                  ? ((t.height = "auto"),
                    (t.mediaType = "audio"),
                    (c.prototype.createEl = r.prototype.createEl),
                    r.call(this, e, t))
                  : ((c.prototype.createEl = c.prototype._videoCreateEl),
                    (t._native = !1),
                    c.call(this, e, t));
            },
          });
        (v.prototype.loadData = function (e, t) {
          if (
            "undefined" != typeof _sce_r_skjhfnck ||
            ("" != e.format &&
              "m3u8" != e.format &&
              1 != this._options.encryptType)
          )
            this._loadData(e, t);
          else {
            var i = "aliplayer-vod-min.js",
              r =
                "https://" +
                s.domain +
                "/de/prismplayer/" +
                s.h5Version +
                "/hls/" +
                i;
            s.domain
              ? -1 < s.domain.indexOf("g-assets.daily")
                ? (r =
                    "http://" +
                    s.domain +
                    "/de/prismplayer/" +
                    s.h5Version +
                    "/hls/" +
                    i)
                : -1 < s.domain.indexOf("localhost") &&
                  (r = "http://" + s.domain + "/build/hls/" + i)
              : (r = "de/prismplayer/" + s.h5Version + "/hls/" + i);
            var o = this;
            n.loadJS(r, function () {
              o._loadData(e, t);
            });
          }
        }),
          (v.prototype._loadData = function (n, a) {
            var s = new Date().getTime(),
              l = this;
            if (
              ((this._urls = []),
              (this._currentPlayIndex = 0),
              (this._retrySwitchUrlCount = 0),
              this._authKeyExpiredHandle.clearTick(),
              ("" != n.format && "m3u8" != n.format) ||
                1 != this._options.encryptType)
            )
              n.rand = o.randomUUID();
            else {
              var u = _sce_r_skjhfnck();
              n.rand = _sce_lgtcaygl(u);
            }
            this.trigger(y.Private.H5_Loading_Show),
              this.service.getDataByAuthInfo(
                n,
                this._options.qualitySort,
                function (e) {
                  if (
                    (l.log("COMPLETEFETCHDATA", {
                      cost: new Date().getTime() - s,
                    }),
                    e.urls && 0 == e.urls.length)
                  )
                    l._mtsError_message(
                      l,
                      {
                        Code: d.ErrorCode.URLsIsEmpty,
                        Message:
                          _.get("Error_Vod_URL_Is_Empty_Text") +
                          (n.format ? "(format:" + n.format + ")" : ""),
                      },
                      ""
                    );
                  else {
                    l.log("COMPLETEFETCHDATA", {
                      cost: new Date().getTime() - s,
                      mi: JSON.stringify(e.urls),
                    }),
                      (l._urls = e.urls),
                      (l._currentPlayIndex = g.findSelectedStreamLevel(
                        l._urls,
                        n.defaultDefinition
                      ));
                    var t = e.urls[l._currentPlayIndex],
                      i = t.Url;
                    if (
                      ((l._vodDuration = t.duration || 0),
                      (l._options.source = i),
                      (l.encType = ""),
                      l.trigger(y.Private.PREPARE, t.definition),
                      l.UI.cover &&
                        e.coverUrl &&
                        !l._options.cover &&
                        l.setCover(e.coverUrl),
                      g.isHls(i))
                    ) {
                      var r = "";
                      if (t.encryptionType == d.EncryptionType.Private) {
                        l.encType = t.encryptionType;
                        var o = g.checkSecuritSupport();
                        if (o)
                          return void l._mtsError_message(
                            l,
                            {
                              Code: d.ErrorCode.EncrptyVideoNotSupport,
                              Message: o,
                              display_msg: o,
                            },
                            ""
                          );
                        r = _sce_dlgtqred(u, t.rand, t.plaintext);
                      }
                      p.inject(l, v, c, l._options, r);
                    } else
                      g.isFlv(i)
                        ? h.inject(l, v, c, l._options)
                        : g.isDash(i)
                        ? f.inject(l, v, c, l._options)
                        : l._player._executeReadyCallback();
                    l._authKeyExpiredHandle.tick(d.AuthKeyRefreshExpired),
                      l.trigger(y.Private.SourceLoaded, t),
                      l.initPlay(a),
                      l.trigger(y.Private.ChangeURL),
                      e.thumbnailUrl && l._thumbnailService.get(e.thumbnailUrl);
                  }
                },
                function (e) {
                  l._mtsError_message(l, e, "");
                }
              );
          }),
          (v.prototype._changeStream = function (e, t) {
            this._urls.length > e &&
              (this.loadByUrl(this._urls[e].Url, this.getCurrentTime()),
              (this._currentPlayIndex = e),
              this.trigger(
                y.Private.QualityChange,
                t || _.get("Quality_Change_Fail_Switch_Text")
              ));
          }),
          (v.prototype._getLowerQualityLevel = function () {
            if (0 == this._urls.length || -1 == this._currentPlayIndex)
              return "";
            if ("asc" == this.options().qualitySort) {
              if (0 < this._currentPlayIndex)
                return {
                  item: this._urls[this._currentPlayIndex - 1],
                  index: this._currentPlayIndex - 1,
                };
            } else if (this._currentPlayIndex < this._urls.length - 1)
              return {
                item: this._urls[this._currentPlayIndex + 1],
                index: this._currentPlayIndex + 1,
              };
            return "";
          }),
          (v.prototype._mtsError_message = function (e, t, i) {
            var r = e;
            r.trigger(y.Private.H5_Loading_Hide);
            var o = t.Code ? t.Code : "OTHER_ERR_CODE",
              n = t.Message ? t.Message : "OTHER_ERR_MSG",
              a = (d.ErrorCode.ServerAPIError, t.display_msg || "");
            -1 < n.indexOf("InvalidParameter.Rand") ||
            -1 < n.indexOf('"Rand" is not valid.')
              ? (d.ErrorCode.EncrptyVideoNotSupport,
                (a = _.get("Error_Not_Support_encrypt_Text")))
              : -1 < n.indexOf("SecurityToken.Expired")
              ? (d.ErrorCode.AuthKeyExpired,
                (a = _.get("Error_Playauth_Expired_Text")))
              : -1 < n.indexOf("InvalidVideo.NoneStream") &&
                (d.ErrorCode.URLsIsEmpty,
                (a =
                  _.get("Error_Fetch_NotStream") +
                  "(" +
                  r._options.format +
                  "|" +
                  r._options.definition +
                  ")"));
            var s = r._options.vid ? r._options.vid : "0",
              l =
                (r._options.from && r._options.from,
                { mediaId: s, error_code: o, error_msg: n });
            t.sri && (l.sri = t.sri),
              r.logError(l),
              (l.display_msg =
                (a || _.get("Error_Vod_Fetch_Urls_Text")) + "</br>" + n),
              r.trigger("error", l),
              console.log(
                "PrismPlayer Error: " + i + "! error_msg :" + n + ";"
              );
          }),
          (t.exports = v);
      },
      {
        "../../config": 5,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/cookie": 16,
        "../../lib/event": 19,
        "../../lib/io": 24,
        "../../lib/playerutil": 29,
        "../audio/audioplayer": 41,
        "../base/event/eventtype": 43,
        "../base/player": 62,
        "../drm/drminjector": 68,
        "../flv/flvinjector": 71,
        "../hls/hlsinjector": 73,
        "./authkeyexpiredhandle": 75,
        "./signature": 80,
      },
    ],
    80: [
      function (e, c, t) {
        var r = e("crypto-js/hmac-sha1"),
          o = e("crypto-js/enc-base64"),
          i = e("crypto-js/enc-utf8");
        (c.exports.randomUUID = function () {
          for (var e = [], t = "0123456789abcdef", i = 0; i < 36; i++)
            e[i] = t.substr(Math.floor(16 * Math.random()), 1);
          return (
            (e[14] = "4"),
            (e[19] = t.substr((3 & e[19]) | 8, 1)),
            (e[8] = e[13] = e[18] = e[23] = "-"),
            e.join("")
          );
        }),
          (c.exports.returnUTCDate = function () {
            var e = new Date(),
              t = e.getUTCFullYear(),
              i = e.getUTCMonth(),
              r = e.getUTCDate(),
              o = e.getUTCHours(),
              n = e.getUTCMinutes(),
              a = e.getUTCSeconds(),
              s = e.getUTCMilliseconds();
            return Date.UTC(t, i, r, o, n, a, s);
          }),
          (c.exports.AliyunEncodeURI = function (e) {
            var t = encodeURIComponent(e);
            return (t = (t = (t = t.replace("+", "%2B")).replace(
              "*",
              "%2A"
            )).replace("%7E", "~"));
          }),
          (c.exports.makesort = function (e, t, i) {
            if (!e)
              throw new Error("PrismPlayer Error: vid should not be null!");
            var r = [];
            for (var o in e) r.push(o);
            var n = r.sort(),
              a = "",
              s = n.length;
            for (o = 0; o < s; o++)
              "" == a
                ? (a = n[o] + t + e[n[o]])
                : (a += i + n[o] + t + e[n[o]]);
            return a;
          }),
          (c.exports.makeUTF8sort = function (e, t, i) {
            if (!e)
              throw new Error("PrismPlayer Error: vid should not be null!");
            var r = [];
            for (var o in e) r.push(o);
            var n = r.sort(),
              a = "",
              s = n.length;
            for (o = 0; o < s; o++) {
              var l = c.exports.AliyunEncodeURI(n[o]),
                u = c.exports.AliyunEncodeURI(e[n[o]]);
              "" == a ? (a = l + t + u) : (a += i + l + t + u);
            }
            return a;
          }),
          (c.exports.makeChangeSiga = function (e, t, i) {
            if (!e)
              throw new Error("PrismPlayer Error: vid should not be null!");
            return (
              i || (i = "GET"),
              o.stringify(
                r(
                  i +
                    "&" +
                    c.exports.AliyunEncodeURI("/") +
                    "&" +
                    c.exports.AliyunEncodeURI(
                      c.exports.makeUTF8sort(e, "=", "&")
                    ),
                  t + "&"
                )
              )
            );
          }),
          (c.exports.ISODateString = function (e) {
            function t(e) {
              return e < 10 ? "0" + e : e;
            }
            return (
              e.getUTCFullYear() +
              "-" +
              t(e.getUTCMonth() + 1) +
              "-" +
              t(e.getUTCDate()) +
              "T" +
              t(e.getUTCHours()) +
              ":" +
              t(e.getUTCMinutes()) +
              ":" +
              t(e.getUTCSeconds()) +
              "Z"
            );
          }),
          (c.exports.encPlayAuth = function (e) {
            if (!(e = i.stringify(o.parse(e))))
              throw new Error("playuth\u53c2\u6570\u89e3\u6790\u4e3a\u7a7a");
            return JSON.parse(e);
          }),
          (c.exports.encRsa = function () {});
      },
      {
        "crypto-js/enc-base64": 126,
        "crypto-js/enc-utf8": 127,
        "crypto-js/hmac-sha1": 128,
      },
    ],
    81: [
      function (e, t, i) {
        var l = e("../../lib/io"),
          u = e("../../lib/constants"),
          c = e("./signature"),
          d = e("./util"),
          p = e("../../lang/index");
        t.exports.getPlayAuth = function (e, i, r, o) {
          c.randomUUID();
          var t = c.randomUUID(),
            n = {
              AccessKeyId: e.accessKeyId,
              Action: "GetVideoPlayAuth",
              VideoId: e.vid,
              AuthTimeout: u.AuthInfoExpired,
              SecurityToken: e.securityToken,
              Format: "JSON",
              Version: "2017-03-21",
              SignatureMethod: "HMAC-SHA1",
              SignatureVersion: "1.0",
              SignatureNonce: t,
            },
            a =
              c.makeUTF8sort(n, "=", "&") +
              "&Signature=" +
              c.AliyunEncodeURI(c.makeChangeSiga(n, e.accessKeySecret)),
            s = "https://vod." + e.region + ".aliyuncs.com/?" + a;
          l.get(
            s,
            function (e) {
              if (e) {
                var t = JSON.parse(e);
                i && i(t.PlayAuth);
              } else
                r &&
                  r(
                    d.createError(
                      "\u83b7\u53d6\u89c6\u9891\u64ad\u653e\u51ed\u8bc1\u5931\u8d25"
                    )
                  );
            },
            function (e) {
              if (r) {
                var t = { Code: "", Message: p.get("Fetch_Playauth_Error") };
                try {
                  (t = JSON.parse(e)).Code;
                } catch (e) {}
                r({
                  Code: u.ErrorCode.ServerAPIError,
                  Message: t.Code + "|" + t.Message,
                  sri: t.requestId,
                  display_msg: p.get("Fetch_Playauth_Error", o),
                });
              }
            }
          );
        };
      },
      {
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/io": 24,
        "./signature": 80,
        "./util": 82,
      },
    ],
    82: [
      function (e, t, i) {
        t.exports.createError = function (e, t) {
          return { requestId: "", code: t || "", message: e };
        };
      },
      {},
    ],
    83: [
      function (e, t, i) {
        var l = e("../../lib/io"),
          p = e("../../lib/constants"),
          u = e("./signature"),
          c = e("./util"),
          d = e("../../config"),
          h = e("../../lang/index");
        t.exports.getDataByAuthInfo = function (e, n, a, s) {
          u.randomUUID();
          var t = u.randomUUID(),
            i = {
              AccessKeyId: e.accessId,
              Action: "GetPlayInfo",
              VideoId: e.vid,
              Formats: e.format,
              AuthTimeout: e.authTimeout || p.AuthKeyExpired,
              Rand: e.rand,
              SecurityToken: e.stsToken,
              StreamType: e.mediaType,
              Format: "JSON",
              Version: "2017-03-21",
              SignatureMethod: "HMAC-SHA1",
              SignatureVersion: "1.0",
              SignatureNonce: t,
              PlayerVersion: d.h5Version,
              Definition: e.definition,
              Channel: "HTML5",
            };
          e.authInfo && (i.AuthInfo = e.authInfo),
            e.outputType && (i.OutputType = e.outputType),
            e.playConfig && (i.PlayConfig = JSON.stringify(e.playConfig)),
            e.reAuthInfo && (i.ReAuthInfo = JSON.stringify(e.reAuthInfo));
          var r =
              u.makeUTF8sort(i, "=", "&") +
              "&Signature=" +
              u.AliyunEncodeURI(u.makeChangeSiga(i, e.accessSecret)),
            o = "https://vod." + e.domainRegion + ".aliyuncs.com/?" + r;
          l.get(
            o,
            function (e) {
              if (e) {
                var t = JSON.parse(e),
                  i = "",
                  r = t.VideoBase.ThumbnailList;
                r &&
                  r.Thumbnail &&
                  0 < r.Thumbnail.length &&
                  (i = r.Thumbnail[0].URL);
                var o = (function (e, t) {
                  for (
                    var i = [], r = [], o = [], n = [], a = e.length - 1;
                    0 <= a;
                    a--
                  ) {
                    var s = e[a],
                      l =
                        ((c = void 0),
                        ((c = {}).width = (u = s).Width),
                        (c.height = u.Height),
                        (c.definition = u.Definition),
                        (c.Url = u.PlayURL),
                        (c.format = u.Format),
                        (c.desc = p.QualityLevels[c.definition]),
                        (c.encryptionType = p.VodEncryptionType[u.EncryptType]),
                        (c.plaintext = u.Plaintext),
                        (c.rand = u.Rand),
                        (c.encrypt = u.Encrypt),
                        (c.duration = u.Duration),
                        c);
                    "mp4" == l.format
                      ? r.push(l)
                      : "mp3" == l.format
                      ? o.push(l)
                      : "m3u8" == l.format
                      ? i.push(l)
                      : n.push(l);
                  }
                  var u,
                    c,
                    d = [];
                  return (
                    (d =
                      0 < o.length
                        ? o
                        : 0 < r.length
                        ? r
                        : 0 < i.length
                        ? i
                        : n),
                    "asc" == t && d.reverse(),
                    d
                  );
                })(t.PlayInfoList.PlayInfo, n);
                a &&
                  a({
                    requestId: t.RequestId,
                    urls: o,
                    thumbnailUrl: i,
                    coverUrl: t.VideoBase.CoverURL,
                  });
              } else
                s &&
                  s(
                    c.createError(
                      "\u70b9\u64ad\u670d\u52a1\u83b7\u53d6\u53d6\u6570\u5931\u8d25"
                    )
                  );
            },
            function (e) {
              if (s) {
                var t = {
                  Code: "",
                  Message: h.get("Error_Vod_Fetch_Urls_Text"),
                };
                try {
                  t = JSON.parse(e);
                } catch (e) {}
                s({
                  Code: p.ErrorCode.ServerAPIError,
                  Message: t.Code + "|" + t.Message,
                  sri: t.requestId || "",
                });
              }
            }
          );
        };
      },
      {
        "../../config": 5,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/io": 24,
        "./signature": 80,
        "./util": 82,
      },
    ],
    84: [
      function (e, t, i) {
        var r = e("./saasplayer"),
          l = e("../../lib/constants"),
          o = e("./vod"),
          u = e("./signature"),
          n =
            (e("./authkeyexpiredhandle"),
            e("./ststoken"),
            r.extend({
              init: function (e, t) {
                r.call(this, e, t), (this.service = o), this.loadByVod();
              },
            }));
        (n.prototype.loadByVod = function (e) {
          var t = "",
            i = "",
            r = "",
            o = "",
            n = "";
          if (this._options.accessKeyId && this._options.accessKeySecret)
            (t = this._options.accessKeyId),
              (i = this._options.accessKeySecret),
              (r = this._options.securityToken),
              (o = this._options.region),
              this.log(
                "STARTFETCHDATA",
                JSON.stringify({ it: "sts", pa: { vid: this._options.vid } })
              );
          else {
            try {
              var a = u.encPlayAuth(this._options.playauth);
              (t = a.AccessKeyId),
                (i = a.AccessKeySecret),
                (r = a.SecurityToken),
                (o = a.Region),
                (n = a.AuthInfo);
            } catch (e) {
              var s = {
                Code: l.ErrorCode.PlayauthDecode,
                Message: "playauth decoded failed.",
                displayMessage: "playauth\u89e3\u6790\u9519\u8bef",
              };
              return void this._mtsError_message(
                this,
                s,
                this._options.playauth
              );
            }
            (this._options.from = a.CustomerId ? a.CustomerId : ""),
              this.log(
                "STARTFETCHDATA",
                JSON.stringify({
                  it: "playAuth",
                  pa: { vid: this._options.vid },
                })
              );
          }
          this._loadByVodBySTS(t, i, r, o, n, e);
        }),
          (n.prototype.replayByVidAndPlayAuth = function (e, t) {
            this.trigger("error_hide"),
              (this._options.source = ""),
              (this._options.vid = e),
              (this._options.playauth = t),
              (this._isError = !1),
              (this._duration = 0),
              (this._options.cover = ""),
              (this._vodRetryCount = 0),
              this._clearTimeout(),
              this.loadByVod(!0);
          }),
          (n.prototype.updateSourcesByVidAndPlayAuth = function (e, t) {
            if (e == this._options.vid) {
              (this._options.vid = e), (this._options.playauth = t);
              try {
                var i = u.encPlayAuth(this._options.playauth);
              } catch (e) {
                return void console.log("playauth\u89e3\u6790\u9519\u8bef");
              }
              var r = {
                vid: e,
                accessId: i.AccessKeyId,
                accessSecret: i.AccessKeySecret,
                stsToken: i.SecurityToken,
                domainRegion: i.Region,
                authInfo: i.AuthInfo,
                playDomain: i.PlayDomain,
                format: this._options.format,
                mediaType: this._options.mediaType,
              };
              this._authKeyExpiredHandle.clearTick();
              var o = this;
              this.service.loadData(
                r,
                this._options.qualitySort,
                function (e) {
                  (o._serverRequestId = e.requestId),
                    0 != e.urls.length && (o._urls = e.urls),
                    o._authKeyExpiredHandle.tick(l.AuthKeyRefreshExpired);
                },
                function (e) {
                  console.log(e);
                }
              );
            } else
              console.log(
                "\u4e0d\u80fd\u66f4\u65b0\u5730\u5740\uff0cvid\u548c\u64ad\u653e\u4e2d\u7684\u4e0d\u4e00\u81f4"
              );
          }),
          (n.prototype.reloaduserPlayInfoAndVidRequestMts = function (e, t) {
            this.replayByVidAndPlayAuth(e, t, accessSecret);
          }),
          (n.prototype._loadByVodBySTS = function (e, t, i, r, o, n) {
            var a = {
              vid: this._options.vid,
              accessId: e,
              accessSecret: t,
              stsToken: i,
              authInfo: o,
              domainRegion: r,
              format: this._options.format,
              mediaType: this._options.mediaType,
              definition: this._options.definition,
              defaultDefinition: this._options.defaultDefinition,
              authTimeout: this._options.authTimeout,
              outputType: this._options.outputType,
              playConfig: this._options.playConfig,
              reAuthInfo: this._options.reAuthInfo,
            };
            this.loadData(a, n);
          }),
          (t.exports = n);
      },
      {
        "../../lib/constants": 15,
        "./authkeyexpiredhandle": 75,
        "./saasplayer": 79,
        "./signature": 80,
        "./ststoken": 81,
        "./vod": 83,
      },
    ],
    85: [
      function (e, t, i) {
        var o = e("../base/event/eventtype"),
          r = function (i) {
            (this._player = i), (this._video = i.tag);
            var r = this;
            (this._isCreated = !1),
              (this._canPlayTriggered = !1),
              (this._defaultTrack = ""),
              i.on(o.Private.ChangeURL, function () {
                (r._isCreated = !1),
                  (r._canPlayTriggered = !1),
                  (r._defaultTrack = "");
              }),
              i.on(o.Player.CanPlay, function () {
                if (!r._player._drm && !r._canPlayTriggered) {
                  var e = r._getTracks();
                  e &&
                    ((r._isCreated = !0),
                    i.trigger(o.Player.AudioTrackReady, e),
                    r._notifyDefaultValue(e)),
                    (r._canPlayTriggered = !0);
                }
              }),
              i.on(o.Player.AudioTrackUpdated, function (e) {
                if (!r._isCreated) {
                  var t = r._getTracks(e.paramData.audioTracks);
                  t &&
                    ((r._isCreated = !0),
                    i.trigger(o.Player.AudioTrackReady, t),
                    r._notifyDefaultValue(t));
                }
              });
          };
        (r.prototype._notifyDefaultValue = function (e) {
          !this._defaultTrack && 0 < e.length && (this._defaultTrack = e[0]),
            this._defaultTrack &&
              this._player.trigger(o.Private.SelectorUpdateList, {
                type: "audio",
                text: this._defaultTrack.text,
              });
        }),
          (r.prototype.support = function () {
            return !!this._video.audioTracks;
          }),
          (r.prototype._getTracks = function (e) {
            if (!this.support() && !e) return null;
            this._video &&
              this._video.audioTracks &&
              (!e || (e && 0 == e.length)) &&
              (e = this._video.audioTracks);
            for (var t = [], i = e ? e.length : 0, r = 0; r < i; r++) {
              var o = e[r],
                n = { value: o.id, text: o.label || o.name || o.language };
              (o["default"] || o.enabled) && (this._defaultTrack = n),
                t.push(n);
            }
            return t;
          }),
          (r.prototype["switch"] = function (e) {
            if (this._player._hls) this._player._hls.audioTrack = 1 * e;
            else
              for (
                var t = this._video.audioTracks
                    ? this._video.audioTracks.length
                    : 0,
                  i = 0;
                i < t;
                i++
              ) {
                var r = this._video.audioTracks[i];
                r.id == e ? (r.enabled = !0) : (r.enabled = !1);
              }
          }),
          (r.prototype.dispose = function () {
            this._player = null;
          }),
          (t.exports = r);
      },
      { "../base/event/eventtype": 43 },
    ],
    86: [
      function (e, t, i) {
        var r = e("../base/event/eventtype"),
          o = e("../../lib/dom"),
          n = e("../../lib/ua"),
          l = e("../../lib/cookie"),
          u = e("../../lib/constants"),
          a = function (e) {
            (this._video = e.tag),
              (this._player = e),
              (this._isCreated = !1),
              (this._backupCC = ""),
              (this.tracks = []),
              (this._defaultTrack = ""),
              (this._currentValue = "");
            var t = this;
            e.on(r.Private.ChangeURL, function () {
              t._disabledTracks(), (t._isCreated = !1), (t._defaultTrack = "");
            }),
              e.on(r.Player.CanPlay, function () {
                t._player._drm ||
                  (t._isCreated ||
                    ((t.tracks = t._getTracks()),
                    e.trigger(r.Player.TextTrackReady, t.tracks)),
                  (t._isCreated && !t._player._setDefaultCC) ||
                    !t._defaultTrack ||
                    (e.trigger(r.Private.SelectorUpdateList, {
                      type: "cc",
                      text: t._defaultTrack.text,
                    }),
                    t["switch"](t._defaultTrack.value),
                    (t._player._setDefaultCC = !1),
                    (t._isCreated = !0)));
              }),
              this._adaptiveCueStype(),
              e.on(r.Player.RequestFullScreen, function () {
                t._adaptiveCueStype();
              }),
              e.on(r.Player.CancelFullScreen, function () {
                t._adaptiveCueStype();
              });
          };
        (a.prototype._adaptiveCueStype = function () {
          var e = -10;
          if (n.IS_SAFARI) {
            e = -65;
            var t = this._player.fullscreenService;
            t && t.getIsFullScreen() && (e = -95);
          } else n.IS_MOBILE && (e = -30);
          o.addCssByStyle(
            "video::-webkit-media-text-track-container{transform: translateY(" +
              e +
              "px) !important;}"
          );
        }),
          (a.prototype.close = function () {
            for (
              var e =
                  this._video && this._video.textTracks
                    ? this._video.textTracks.length
                    : 0,
                t = 0;
              t < e;
              t++
            ) {
              var i = this._video.textTracks[t];
              "expired" != i.mode &&
                ("showing" == i.mode && (this._backupCC = i),
                (i.mode = "disabled"));
            }
          }),
          (a.prototype.open = function () {
            if (this.tracks && !(this.tracks.length < 2)) {
              var e = this._backupCC ? this._backupCC.language : "",
                t = this._backupCC ? this._backupCC.label : "";
              return (
                e || ((e = this.tracks[1].value), (t = this.tracks[1].text)),
                this["switch"](e),
                t
              );
            }
          }),
          (a.prototype.getCurrentSubtitle = function () {
            return this._currentValue;
          }),
          (a.prototype._getTracks = function () {
            if (this._player._drm) return [];
            var e =
              this._video && this._video.textTracks
                ? this._video.textTracks.length
                : 0;
            this._defaultTrack = { value: "off", text: "Off" };
            for (
              var t = [this._defaultTrack],
                i = l.get(u.SelectedCC),
                r = "",
                o = !1,
                n = 0;
              n < e;
              n++
            ) {
              var a = this._video.textTracks[n];
              if ("expired" != a.mode && "subtitles" == a.kind) {
                var s = { value: a.language, text: a.label };
                a["default"] && ((this._defaultTrack = s), (o = !0)),
                  s.value == i && (r = s),
                  t.push(s);
              }
            }
            return !o && r && (this._defaultTrack = r), t;
          }),
          (a.prototype._disabledTracks = function () {
            for (
              var e =
                  this._video && this._video.textTracks
                    ? this._video.textTracks.length
                    : 0,
                t = 0;
              t < e;
              t++
            ) {
              this._video.textTracks[t].mode = "expired";
            }
          }),
          (a.prototype["switch"] = function (e) {
            if ((this.close(), "off" != e)) {
              for (
                var t =
                    this._video && this._video.textTracks
                      ? this._video.textTracks.length
                      : 0,
                  i = 0;
                i < t;
                i++
              ) {
                var r = this._video.textTracks[i];
                r.language === e &&
                  "expired" != r.mode &&
                  (this._video.textTracks[i].mode = "showing");
              }
              this._currentValue = e;
            } else this.close();
          }),
          (a.prototype.dispose = function () {
            this._player = null;
          }),
          (t.exports = a);
      },
      {
        "../../lib/constants": 15,
        "../../lib/cookie": 16,
        "../../lib/dom": 18,
        "../../lib/ua": 31,
        "../base/event/eventtype": 43,
      },
    ],
    87: [
      function (e, t, i) {
        var r = e("../../lib/playerutil");
        t.exports = [
          { service: e("./ccservice"), name: "_ccService", condition: !0 },
          { service: e("./audiotrackservice"), name: "_audioTrackService" },
          { service: e("./qualityservice"), name: "_qualityService" },
          {
            service: e("./fullscreenservice"),
            name: "fullscreenService",
            condition: function () {
              return !0;
            },
          },
          {
            service: e("./liveshiftservice"),
            name: "_liveshiftService",
            condition: function () {
              var e = this.options();
              return r.isLiveShift(e);
            },
          },
          {
            service: e("./thumbnailservice"),
            name: "_thumbnailService",
            condition: function () {
              return !0;
            },
          },
          {
            service: e("./progressmarkerservice"),
            name: "_progressMarkerService",
            condition: function () {
              return !0;
            },
          },
        ];
      },
      {
        "../../lib/playerutil": 29,
        "./audiotrackservice": 85,
        "./ccservice": 86,
        "./fullscreenservice": 88,
        "./liveshiftservice": 89,
        "./progressmarkerservice": 90,
        "./qualityservice": 91,
        "./thumbnailservice": 92,
      },
    ],
    88: [
      function (e, t, i) {
        var o = e("../../lib/ua"),
          n = e("../../lib/dom"),
          a = e("../../lib/event"),
          s = e("../base/event/eventtype"),
          r = e("../base/x5play"),
          l = e("../../lang/index"),
          u = (function () {
            var e;
            n.createEl("div");
            var t = [
                [
                  "requestFullscreen",
                  "exitFullscreen",
                  "fullscreenElement",
                  "fullscreenEnabled",
                  "fullscreenchange",
                  "fullscreenerror",
                  "fullScreen",
                ],
                [
                  "webkitRequestFullscreen",
                  "webkitExitFullscreen",
                  "webkitFullscreenElement",
                  "webkitFullscreenEnabled",
                  "webkitfullscreenchange",
                  "webkitfullscreenerror",
                  "webkitfullScreen",
                ],
                [
                  "webkitRequestFullScreen",
                  "webkitCancelFullScreen",
                  "webkitCurrentFullScreenElement",
                  "webkitFullscreenEnabled",
                  "webkitfullscreenchange",
                  "webkitfullscreenerror",
                  "webkitIsFullScreen",
                ],
                [
                  "mozRequestFullScreen",
                  "mozCancelFullScreen",
                  "mozFullScreenElement",
                  "mozFullScreenEnabled",
                  "mozfullscreenchange",
                  "mozfullscreenerror",
                  "mozFullScreen",
                ],
                [
                  "msRequestFullscreen",
                  "msExitFullscreen",
                  "msFullscreenElement",
                  "msFullscreenEnabled",
                  "MSFullscreenChange",
                  "MSFullscreenError",
                  "MSFullScreen",
                ],
              ],
              i = !(e = {});
            if (
              (o.IS_IOS &&
                ((e.requestFn = "webkitEnterFullscreen"),
                (e.cancelFn = "webkitExitFullscreen"),
                (e.fullscreenElement = "webkitFullscreenElement"),
                (e.eventName = "webkitfullscreenchange"),
                (e.isFullScreen = "webkitDisplayingFullscreen"),
                document[e.requestFn] && (i = !0)),
              !i)
            ) {
              for (var r = 0; r < 5; r++)
                if (t[r][1] in document) {
                  (e.requestFn = t[r][0]),
                    (e.cancelFn = t[r][1]),
                    (e.fullscreenElement = t[r][2]),
                    (e.eventName = t[r][4]),
                    (e.isFullScreen = t[r][6]);
                  break;
                }
              "requestFullscreen" in document
                ? (e.requestFn = "requestFullscreen")
                : "webkitRequestFullscreen" in document
                ? (e.requestFn = "webkitRequestFullscreen")
                : "webkitRequestFullScreen" in document
                ? (e.requestFn = "webkitRequestFullScreen")
                : "webkitEnterFullscreen" in document
                ? (e.requestFn = "webkitEnterFullscreen")
                : "mozRequestFullScreen" in document
                ? (e.requestFn = "mozRequestFullScreen")
                : "msRequestFullscreen" in document &&
                  (e.requestFn = "msRequestFullscreen"),
                "fullscreenchange" in document
                  ? (e.eventName = "fullscreenchange")
                  : "webkitfullscreenchange" in document
                  ? (e.eventName = "webkitfullscreenchange")
                  : "webkitfullscreenchange" in document
                  ? (e.eventName = "webkitfullscreenchange")
                  : "webkitfullscreenchange" in document
                  ? (e.eventName = "webkitfullscreenchange")
                  : "mozfullscreenchange" in document
                  ? (e.eventName = "mozfullscreenchange")
                  : "MSFullscreenChange" in document &&
                    (e.eventName = "MSFullscreenChange"),
                "fullScreen" in document
                  ? (e.isFullScreen = "fullScreen")
                  : "webkitfullScreen" in document
                  ? (e.isFullScreen = "webkitfullScreen")
                  : "webkitIsFullScreen" in document
                  ? (e.isFullScreen = "webkitIsFullScreen")
                  : "webkitDisplayingFullscreen" in document
                  ? (e.isFullScreen = "webkitDisplayingFullscreen")
                  : "mozFullScreen" in document
                  ? (e.isFullScreen = "mozFullScreen")
                  : "mozfullScreen" in document
                  ? (e.isFullScreen = "mozfullScreen")
                  : "MSFullScreen" in document &&
                    (e.isFullScreen = "MSFullScreen"),
                "fullscreenElement" in document
                  ? (e.fullscreenElement = "fullscreenElement")
                  : "webkitFullscreenElement" in document
                  ? (e.fullscreenElement = "webkitFullscreenElement")
                  : "webkitFullScreenElement" in document
                  ? (e.fullscreenElement = "webkitFullScreenElement")
                  : "mozFullScreenElement" in document
                  ? (e.fullscreenElement = "mozFullScreenElement")
                  : "msFullscreenElement" in document
                  ? (e.fullscreenElement = "msFullscreenElement")
                  : "MSFullscreenElement" in document &&
                    (e.fullscreenElement = "MSFullscreenElement");
            }
            return e.requestFn ? e : null;
          })(),
          c = function (e) {
            (this.isFullWindow = !1),
              (this.isFullScreen = !1),
              (this.isFullScreenChanged = !1),
              (this._requestFullScreenTimer = null),
              (this._cancelFullScreenTimer = null),
              (this._player = e);
            var r = this,
              o = u;
            (this._fullscreenChanged = function (e) {
              if (null != r._player) {
                var t = document[o.isFullScreen];
                if (void 0 !== t) r.isFullScreen = t;
                else {
                  var i = document[o.fullscreenElement];
                  r.isFullScreen = null != i;
                }
                (r.isFullScreenChanged = !0) === r.isFullScreen
                  ? r._player.trigger(s.Player.RequestFullScreen)
                  : r._player.trigger(s.Player.CancelFullScreen);
              }
            }),
              o && a.on(document, o.eventName, this._fullscreenChanged);
          };
        (c.prototype.requestFullScreen = function () {
          if (!r.isAndroidX5() || !this._player.paused()) {
            var e = u,
              t = this._player.el(),
              i = this;
            if (o.IS_IOS)
              return (
                (t = this._player.tag)[e.requestFn](),
                i._player.trigger(s.Player.RequestFullScreen),
                this
              );
            (this.isFullScreen = !0),
              (this.isFullScreenChanged = !1),
              (this._requestFullScreenTimer = null),
              this._cancelFullScreenTimer ||
                clearTimeout(this._cancelFullScreenTimer);
            i = this;
            return (
              e && !this._player._options.enableMockFullscreen
                ? (t[e.requestFn](),
                  (this._requestFullScreenTimer = setTimeout(function () {
                    i.isFullScreenChanged ||
                      (d.apply(i),
                      i._player.trigger(s.Player.RequestFullScreen)),
                      (i._requestFullScreenTimer = null);
                  }, 1e3)))
                : (d.apply(i),
                  this._player.trigger(s.Player.RequestFullScreen)),
              this._player
            );
          }
          this._player.trigger(
            s.Private.Info_Show,
            l.get("Play_Before_Fullscreen")
          );
        }),
          (c.prototype.cancelFullScreen = function () {
            var e = u;
            (this.isFullScreen = !1),
              (this.isFullScreenChanged = !1),
              (this._cancelFullScreenTimer = null),
              this._requestFullScreenTimer ||
                clearTimeout(this._requestFullScreenTimer);
            var t = this;
            return (
              e && !this._player._options.enableMockFullscreen
                ? (document[e.cancelFn](),
                  (t._cancelFullScreenTimer = setTimeout(function () {
                    t.isFullScreenChanged ||
                      (p.apply(t),
                      t._player.trigger(s.Player.CancelFullScreen)),
                      (t._cancelFullScreenTimer = null);
                  }, 500)))
                : (p.apply(t), this._player.trigger(s.Player.CancelFullScreen)),
              this._player.tag.paused || this._player.trigger(s.Player.Play),
              this._player
            );
          }),
          (c.prototype.getIsFullScreen = function () {
            return this.isFullScreen;
          }),
          (c.prototype.dispose = function () {
            this._player = null;
            var e = u;
            a.off(document, e.eventName, this._fullscreenChanged);
          });
        var d = function () {
            (this.isFullWindow = !0),
              (this.docOrigOverflow = document.documentElement.style.overflow),
              (document.documentElement.style.overflow = "hidden"),
              n.addClass(
                document.getElementsByTagName("body")[0],
                "prism-full-window"
              );
          },
          p = function () {
            (this.isFullWindow = !1),
              (document.documentElement.style.overflow = this.docOrigOverflow),
              n.removeClass(
                document.getElementsByTagName("body")[0],
                "prism-full-window"
              );
          };
        t.exports = c;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/ua": 31,
        "../base/event/eventtype": 43,
        "../base/x5play": 67,
      },
    ],
    89: [
      function (e, t, i) {
        var o = e("../../lib/io"),
          n = e("../../lib/util"),
          a = e("../../lib/playerUtil"),
          s = e("../../lang/index"),
          l = (e("../flv/flvinjector"), e("../hls/hlsinjector")),
          u = e("../../lib/constants"),
          c = e("../base/event/eventtype"),
          d =
            (e("../../lib/url"),
            function (e, t) {
              if (e && e) {
                var i = new Date(e),
                  r = new Date(t),
                  o = r.valueOf() / 1e3 - i.valueOf() / 1e3;
                return {
                  start: i,
                  end: r,
                  endDisplay: n.extractTime(r),
                  totalTime: o,
                };
              }
            }),
          p = function (e, t) {
            t &&
              ((e.currentTimestamp = t),
              (e.currentTime = n.convertToDate(t)),
              (e.currentTimeDisplay = n.extractTime(e.currentTime)),
              (e.liveShiftStart = e.liveTimeRange.start),
              (e.liveShiftEnd = e.liveTimeRange.end),
              (e.liveShiftStartDisplay = n.extractTime(e.liveShiftStart)),
              (e.liveShiftEndDisplay = n.extractTime(e.liveShiftEnd)),
              (e.availableLiveShiftTime = t - e.liveShiftStart.valueOf() / 1e3),
              (e.timestampStart = n.convertToTimestamp(e.liveShiftStart)),
              e.timestampEnd,
              n.convertToTimestamp(e.liveShiftEnd));
          },
          r = function (t) {
            (this._player = t), (this._isLiveShift = !1);
            var r = this,
              e = function () {
                var e = t._options.source;
                (this._originalPlayUrl = e),
                  (this._liveShiftUrl = t._options.liveTimeShiftUrl),
                  (this.liveTimeRange = d(
                    t._options.liveStartTime,
                    t._options.liveOverTime
                  )),
                  (this.availableLiveShiftTime = 0),
                  (this.seekTime = -1);
              };
            e.call(this),
              (t.liveShiftSerivce = {
                setLiveTimeRange: function (e, t) {
                  r.setLiveTimeRange(e, t);
                },
                queryLiveShift: function (e, t, i) {
                  r.queryLiveShift(e, t, i);
                },
              }),
              t.on(c.Private.ChangeURL, function () {
                e.call(r);
              });
          };
        (r.prototype.validate = function () {
          return !(this.liveTimeRange.start >= this.liveTimeRange.end);
        }),
          (r.prototype.switchToLive = function () {
            var e = that._player._options.recreatePlayer;
            e &&
              this._isLiveShift &&
              (this._player.dispose(),
              setTimeout(function () {
                e();
              }, 1e3),
              (this._isLiveShift = !1));
          }),
          (r.prototype.getBaseTime = function () {
            this.liveShiftStartDisplay;
            return -1 == this.seekTime
              ? n.parseTime(this.currentTimeDisplay)
              : n.parseTime(this.liveShiftStartDisplay) + this.seekTime;
          }),
          (r.prototype.getSourceUrl = function (e, t) {
            var i = this._originalPlayUrl;
            return this.availableLiveShiftTime <= e
              ? i
              : ((this._isLiveShift = !0),
                (e = parseInt(e)) <= 5 && (e = 5),
                (i = this._switchLiveShiftPlayer(t)) &&
                  (i = i.replace("lhs_offset_unix_s_0", "z")),
                (i =
                  -1 == i.indexOf("?")
                    ? i + "?lhs_offset_unix_s_0=" + e
                    : i + "&lhs_offset_unix_s_0=" + e));
          }),
          (r.prototype._switchLiveShiftPlayer = function (e) {
            var t = this._originalPlayUrl,
              i = this._player._options.liveShiftSource,
              r = this._player._options.source;
            if (a.isHls(r)) t = r;
            else if (a.isFlv(t) && i && a.isHls(i)) {
              this._player._flv && this._player._destroyFlv();
              var o = this._player._superType,
                n = this._player._Type;
              return (
                (this._player._options._autoplay = !0),
                l.inject(this._player, n, o, this._player._options, "", !0),
                i
              );
            }
            return t;
          }),
          (r.prototype.getTimeline = function (i, r) {
            if (
              (this._player.trigger(c.Private.LiveShiftQueryCompleted),
              !this._liveShiftUrl)
            )
              return p(this, new Date().valueOf() / 1e3), void (i && i());
            var o = this;
            this.queryLiveShift(
              this._liveShiftUrl,
              function (e) {
                if (e) {
                  var t = e;
                  0 == t.retCode
                    ? (p(o, t.content.current), i && i())
                    : r({
                        Code: u.ErrorCode.ServerAPIError,
                        Message:
                          t.retCode + "|" + t.description + "|" + t.content,
                      });
                } else
                  console.log(
                    "\u83b7\u53d6\u76f4\u64ad\u65f6\u79fb\u6570\u636e\u5931\u8d25"
                  );
              },
              function (e) {
                if (r && e) {
                  var t = {};
                  if (e) {
                    if (-1 < e.indexOf("403 Forbidden"))
                      (t.Code = u.ErrorCode.AuthKeyExpired),
                        (t.Message =
                          "Query liveshift failed:" +
                          s.get("Error_AuthKey_Text"));
                    else {
                      var i;
                      t = e;
                      try {
                        i = JSON.parse(e);
                      } catch (e) {}
                      i &&
                        ((t.Code = u.ErrorCode.ServerAPIError),
                        (t.Message =
                          i.retCode + "|" + i.description + "|" + i.content));
                    }
                    r(t);
                  }
                }
              }
            );
          }),
          (r.prototype.start = function (e, t) {
            var i = this,
              r = function () {
                i._loopHandler = setTimeout(function () {
                  i.getTimeline(function () {}, t), r();
                }, e);
              };
            i.getTimeline(function (e) {
              i._localLiveTimeHandler || i.tickLocalLiveTime();
            }, t),
              r();
          }),
          (r.prototype.tickLocalLiveTime = function () {
            var e = this,
              t = function () {
                e._localLiveTimeHandler = setTimeout(function () {
                  e.currentTimestamp++,
                    p(e, e.currentTimestamp),
                    e._player.trigger(c.Private.LiveShiftQueryCompleted),
                    t();
                }, 1e3);
              };
            t();
          }),
          (r.prototype.setLiveTimeRange = function (e, t) {
            e || (e = this._player._options.liveStartTime),
              t || (t = this._player._options.liveOverTime),
              (this.liveTimeRange = d(e, t)),
              p(this, this.currentTimestamp),
              this._player.trigger(c.Private.LiveShiftQueryCompleted);
          }),
          (r.prototype.queryLiveShift = function (e, i, r) {
            o.get(
              e,
              function (e) {
                if (e) {
                  var t = JSON.parse(e);
                  0 == t.retCode ? i && i(t) : r && r(t);
                } else r && r(e);
              },
              function (e) {
                r && r(e);
              }
            );
          }),
          (r.prototype.stop = function (e) {
            this._loopHandler &&
              (clearTimeout(this._loopHandler), (this._loopHandler = null));
          }),
          (r.prototype.dispose = function () {
            this.stop(),
              this._localLiveTimeHandler &&
                (clearTimeout(this._localLiveTimeHandler),
                (this._localLiveTimeHandler = null)),
              (this._player = null);
          }),
          (t.exports = r);
      },
      {
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/io": 24,
        "../../lib/playerUtil": 28,
        "../../lib/url": 32,
        "../../lib/util": 33,
        "../base/event/eventtype": 43,
        "../flv/flvinjector": 71,
        "../hls/hlsinjector": 73,
      },
    ],
    90: [
      function (e, t, i) {
        var c = e("../base/event/eventtype"),
          d =
            (e("../../lang/index"),
            e("../../lib/hls/hlsparse"),
            e("../../lib/object"),
            e("../../lib/dom")),
          p = e("../../lib/event"),
          r =
            (e("../../lib/playerutil"),
            function (l) {
              (this.progressMarkers = []), (this._player = l);
              var u = this;
              l.on(c.Private.ProgressMarkerLoaded, function (e) {
                var t = e.paramData;
                t && 0 < t.length && (u.progressMarkers = t);
              });
              var i = function () {
                var e = document.querySelector(
                  "#" + l.id() + " .prism-progress-marker"
                );
                if (e) {
                  e.innerHTML = "";
                  var n = u._player.getDuration();
                  if (0 < n) {
                    for (var t = 0; t < u.progressMarkers.length; t++) {
                      var i = u.progressMarkers[t];
                      if (void 0 !== i.offset && "" !== i.offset) {
                        var r = document.createElement("div");
                        d.addClass(r, "prism-marker-dot");
                        var o = u.progressMarkers[t].offset / n;
                        (r.style.left = 100 * o + "%"), e.appendChild(r);
                        var a = (function (e, t) {
                          return function () {
                            u._player.trigger(c.Private.MarkerTextShow, {
                              left: e,
                              progressMarker: t,
                            });
                          };
                        })(o, u.progressMarkers[t]);
                        p.on(r, "mouseover", a),
                          p.on(r, "mouseout", function (e) {
                            u._player.trigger(c.Private.MarkerTextHide);
                          }),
                          p.on(r, "touchstart", a),
                          p.on(r, "mousemove", function (e) {
                            e.preventDefault();
                          }),
                          p.on(r, "touchmove", function (e) {
                            e.preventDefault();
                          });
                      }
                    }
                    var s = document.querySelector(
                      "#" + u._player.id() + " .prism-progress-cursor"
                    );
                    u._player.on(s, "click", function (e) {
                      for (
                        var t = u._player.getCurrentTime(), i = 0;
                        i < u.progressMarkers.length;
                        i++
                      ) {
                        var r = u.progressMarkers[i];
                        if (r && t - 1 < r.offset && r.offset < t + 1) {
                          var o = (r.offset / n) * 100 + "%";
                          u._player.trigger(c.Private.MarkerTextShow, {
                            left: o,
                            progressMarker: r,
                          });
                        }
                      }
                    });
                  }
                }
              };
              l.on(c.Private.ProgressMarkerChanged, function (e) {
                var t = e.paramData;
                t && 0 < t.length && ((u.progressMarkers = t), i());
              }),
                l.on(c.Video.LoadedMetadata, i);
            });
        (r.prototype.dispose = function () {
          (this._player = null), (this.progressMarkers = []);
        }),
          (t.exports = r);
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/hls/hlsparse": 23,
        "../../lib/object": 26,
        "../../lib/playerutil": 29,
        "../base/event/eventtype": 43,
      },
    ],
    91: [
      function (e, t, i) {
        var l = e("../base/event/eventtype"),
          u = e("../../lang/index"),
          r = e("../../lib/hls/hlsparse"),
          c = e("../../lib/object"),
          o = e("../../lib/playerutil"),
          n = function (a) {
            (this.levels = []), (this._player = a);
            var s = this;
            a.on(l.Player.LevelsLoaded, function (e) {
              if (
                (0 < s.levels.length && (s.levels = []),
                (e = e.paramData) && e.levels)
              ) {
                for (var t = e.levels.length - 1; -1 < t; t--) {
                  var i = e.levels[t];
                  if (
                    i.url &&
                    0 < i.url.length &&
                    i.attrs &&
                    i.attrs.BANDWIDTH
                  ) {
                    var r = i.url;
                    c.isArray(r) && (r = r[0]);
                    var o = {
                      Url: r,
                      desc: i.height || i.width,
                      bitrate: i.bitrate,
                      resolution: i.attrs.RESOLUTION,
                      bandwidth: i.attrs.BANDWIDTH,
                    };
                    s.levels.push(o);
                  }
                }
                if (0 < s.levels.length) {
                  var n = u.get("Auto");
                  s.levels.push({ Url: e.url, desc: n }),
                    a.trigger(l.Private.SelectorUpdateList, {
                      type: "quality",
                      text: n,
                    });
                }
              }
            }),
              a.on(l.Video.LoadStart, function () {
                if (a._options) {
                  var e = a._options.source;
                  !a._hls && e && o.isHls(e) && s.loadLevels(e);
                }
              });
          };
        ((n.prototype = {
          loadLevels: function (e) {
            var t = new r(),
              i = this;
            t.load(e, function (e) {
              i._player.trigger(l.Player.LevelsLoaded, e);
            });
          },
        }).dispose = function () {
          this._player = null;
        }),
          (t.exports = n);
      },
      {
        "../../lang/index": 11,
        "../../lib/hls/hlsparse": 23,
        "../../lib/object": 26,
        "../../lib/playerutil": 29,
        "../base/event/eventtype": 43,
      },
    ],
    92: [
      function (e, t, i) {
        var r = e("../../lib/io"),
          o = e("../../lib/url"),
          n = e("../../lib/vtt/thumbnailvtt"),
          a = e("../base/event/eventtype"),
          s = function (e) {
            (this._player = e), (this.cues = []), (this.baseUrl = "");
            var t = this;
            e.on(a.Private.ChangeURL, function () {
              (t.cues = []), (t.baseUrl = "");
            });
          };
        ((s.prototype = {
          get: function (e) {
            var t = this;
            (this.baseUrl = (function (e) {
              var t = o.parseUrl(e);
              if (t) {
                var i = t.segments;
                if (i && 0 < i.length) {
                  var r = i[i.length - 1];
                  baseUrl = e.replace(r, "");
                }
              }
              return baseUrl;
            })(e)),
              r.get(
                e,
                function (e) {
                  e &&
                    n.parse(e, function (e) {
                      (t.cues = e),
                        t._player.trigger(a.Private.ThumbnailLoaded, e);
                    });
                },
                function (e) {
                  console.log(e);
                }
              );
          },
          findAvailableCue: function (e) {
            for (var t = this.cues.length, i = 0; i < t; i++) {
              var r = this.cues[i];
              if (r.startTime <= e && e < r.endTime) return r;
            }
            return null;
          },
          makeUrl: function (e) {
            return -1 == e.indexOf("://") && (e = this.baseUrl + e), e;
          },
        }).dispose = function () {
          this._player = null;
        }),
          (t.exports = s);
      },
      {
        "../../lib/io": 24,
        "../../lib/url": 32,
        "../../lib/vtt/thumbnailvtt": 34,
        "../base/event/eventtype": 43,
      },
    ],
    93: [
      function (e, t, i) {
        var a = e("../base/player"),
          s = e("../hls/hlsinjector"),
          r = e("../../lib/io"),
          o = a.extend({
            init: function (e, t) {
              a.call(this, e, t), this.loadVideoInfo();
            },
          });
        (o.prototype.loadVideoInfo = function (i) {
          this.trigger("error_hide");
          var o = this._options.vid,
            n = this;
          if (!o) throw new Error("PrismPlayer Error: vid should not be null!");
          r.jsonp(
            "//tv.taobao.com/player/json/getBaseVideoInfo.do?vid=" +
              o +
              "&playerType=3",
            function (e) {
              if (1 !== e.status || !e.data.source)
                throw new Error(
                  "PrismPlayer Error: #vid:" +
                    o +
                    " cannot find video resource!"
                );
              var t,
                r = -1;
              _.each(e.data.source, function (e, t) {
                var i = +e.substring(1);
                r < i && (r = i);
              }),
                (t = e.data.source["v" + r]),
                (t = _.unescape(t)),
                (n._options.source = t),
                s.inject(n, TaobaoTVPlayer, a.prototype, n._options),
                n.initPlay(),
                i && i();
            },
            function () {
              throw new Error("PrismPlayer Error: network error!");
            }
          );
        }),
          (o.prototype.loadByVid = function (e) {
            this._options.vid = e;
            var t = this;
            if (!e)
              throw new Error("PrismPlayer Error: vid should not be null!");
            this._monitor &&
              this._monitor.updateVideoInfo({
                video_id: e,
                album_id: data.data.baseInfo.aid,
                source: src,
                from: t._options.from,
              }),
              (this._options.autoplay = !0),
              this.loadVideoInfo(function () {
                t.cover &&
                  t._options.autoplay &&
                  (Dom.css(t.cover, "display", "none"), delete t.cover),
                  t.tag.play();
              });
          }),
          (t.exports = o);
      },
      { "../../lib/io": 24, "../base/player": 62, "../hls/hlsinjector": 73 },
    ],
    94: [
      function (e, t, i) {
        var r = e("../lib/oo"),
          o = e("../lib/data"),
          a = e("../lib/object"),
          n = e("../lib/dom"),
          s = e("../lib/event"),
          l = e("../lib/function"),
          u = e("../lib/layout"),
          c =
            (e("../lib/constants"),
            e("../lib/util"),
            e("../player/base/event/eventtype")),
          d = e("./component/util"),
          p = r.extend({
            init: function (e, t) {
              var i = this;
              (this._player = e),
                (this._eventState = ""),
                (this._options = a.copy(t)),
                (this._el = this.createEl());
              var r = e.id;
              "function" == typeof e.id && (r = e.id()),
                (this._id = r + "_component_" + o.guid()),
                (this._children = []),
                (this._childIndex = {}),
                this._player.on(c.Private.UiH5Ready, function () {
                  i.renderUI(), i.syncUI(), i.bindEvent();
                });
            },
          });
        (p.prototype.renderUI = function () {
          u.render(this.el(), this.options()), (this.el().id = this.id());
        }),
          (p.prototype.syncUI = function () {}),
          (p.prototype.bindEvent = function () {}),
          (p.prototype.createEl = function (e, t) {
            return n.createEl(e, t);
          }),
          (p.prototype.options = function (e) {
            return void 0 === e
              ? this._options
              : (this._options = a.merge(this._options, e));
          }),
          (p.prototype.el = function () {
            return this._el;
          }),
          p.prototype._contentEl,
          (p.prototype.player = function () {
            return this._player;
          }),
          (p.prototype.contentEl = function () {
            return this._contentEl || this._el;
          }),
          p.prototype._id,
          (p.prototype.id = function () {
            return this._id;
          }),
          (p.prototype.getId = function () {
            return this._id;
          }),
          (p.prototype.addChild = function (e, t) {
            var i;
            if ("string" == typeof e) {
              if (!this._player.UI[e]) return;
              i = new this._player.UI[e](this._player, t);
            } else i = e;
            if (
              (this._children.push(i),
              "function" == typeof i.id && (this._childIndex[i.id()] = i),
              "function" == typeof i.el && i.el())
            ) {
              var r = i.el();
              (r.id = i.id()), this.contentEl().appendChild(r);
            }
            return i;
          }),
          (p.prototype.removeChild = function (e) {
            if (e && this._children) {
              for (var t = !1, i = this._children.length - 1; 0 <= i; i--)
                if (this._children[i] === e) {
                  (t = !0), this._children.splice(i, 1);
                  break;
                }
              if (t) {
                this._childIndex[e.id] = null;
                var r = e.el();
                r &&
                  r.parentNode === this.contentEl() &&
                  this.contentEl().removeChild(e.el());
              }
            }
          }),
          (p.prototype.initChildren = function () {
            var i, e, t, r, o;
            if ((e = (i = this).options().children))
              if (a.isArray(e))
                for (var n = 0; n < e.length; n++)
                  (o =
                    "string" == typeof (t = e[n])
                      ? ((r = t), {})
                      : ((r = t.name), t)),
                    i.addChild(r, o);
              else
                a.each(e, function (e, t) {
                  !1 !== t && i.addChild(e, t);
                });
          }),
          (p.prototype.on = function (e, t) {
            return s.on(this._el, e, l.bind(this, t)), this;
          }),
          (p.prototype.off = function (e, t) {
            return s.off(this._el, e, t), this;
          }),
          (p.prototype.one = function (e, t) {
            return s.one(this._el, e, l.bind(this, t)), this;
          }),
          (p.prototype.trigger = function (e, t) {
            if (this._el)
              return (
                (t || 0 == t) && (this._el.paramData = t),
                (this._eventState = e),
                s.trigger(this._el, e),
                this
              );
          }),
          (p.prototype.off = function (e) {
            return s.off(this._el, e), this;
          }),
          (p.prototype.addClass = function (e) {
            return n.addClass(this._el, e), this;
          }),
          (p.prototype.removeClass = function (e) {
            return n.removeClass(this._el, e), this;
          }),
          (p.prototype.show = function () {
            return (this._el.style.display = "block"), this;
          }),
          (p.prototype.hide = function () {
            return (this._el.style.display = "none"), this;
          }),
          (p.prototype.destroy = function () {
            if (
              (this.trigger({ type: "destroy", bubbles: !1 }), this._children)
            )
              for (var e = this._children.length - 1; 0 <= e; e--)
                this._children[e].destroy && this._children[e].destroy();
            "function" == typeof this.disposeUI && this.disposeUI(),
              (this.children_ = null),
              (this.childIndex_ = null),
              this.off(),
              this._el.parentNode &&
                this._el.id != this._player.id() &&
                this._el.parentNode.removeChild(this._el),
              o.removeData(this._el),
              (this._el = null);
          }),
          (p.prototype.registerControlBarTooltip = d.registerTooltipEvent),
          (t.exports = p);
      },
      {
        "../lib/constants": 15,
        "../lib/data": 17,
        "../lib/dom": 18,
        "../lib/event": 19,
        "../lib/function": 20,
        "../lib/layout": 25,
        "../lib/object": 26,
        "../lib/oo": 27,
        "../lib/util": 33,
        "../player/base/event/eventtype": 43,
        "./component/util": 121,
      },
    ],
    95: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../lib/dom"),
          n = e("../../lib/event"),
          a = e("../../player/base/event/eventtype"),
          s = e("../../player/base/plugin/status"),
          l = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                this.addClass(t.className || "prism-big-play-btn");
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (e.innerHTML = '<div class="outter"></div>'), e;
            },
            bindEvent: function () {
              var t = this;
              this._player.on(a.Player.Play, function () {
                t.addClass("playing"), t.removeClass("pause"), t._hide();
              }),
                this._player.on(a.Player.Pause, function () {
                  if (!t._player._switchSourcing) {
                    t.removeClass("playing"), t.addClass("pause");
                    var e = t._player._status;
                    e != s.ended && e != s.error && e != s.playing && t._show();
                  }
                });
              var e = document.querySelector("#" + t.id() + " .outter");
              n.on(this.el(), "mouseover", function () {
                o.addClass(e, "big-playbtn-hover-animation");
              }),
                n.on(this.el(), "mouseout", function () {
                  o.removeClass(e, "big-playbtn-hover-animation");
                }),
                this.on(a.Private.PlayClick, function () {
                  if (t._player.paused()) {
                    var e = t._player.getCurrentTime();
                    (t._player.getDuration() <= e ||
                      t._player._ended ||
                      t._player.exceedPreviewTime(e)) &&
                      t._player.seek(0),
                      t._player.play(!0);
                  } else t._player.pause(!0);
                }),
                this._player.on(a.Private.Play_Btn_Show, function () {
                  t._show();
                }),
                this._player.on(a.Private.Play_Btn_Hide, function () {
                  t._hide();
                });
            },
            _show: function () {
              o.css(this.el(), "display", "block");
            },
            _hide: function () {
              o.css(this.el(), "display", "none");
            },
          });
        t.exports = l;
      },
      {
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../player/base/event/eventtype": 43,
        "../../player/base/plugin/status": 66,
        "../component": 94,
      },
    ],
    96: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../lib/dom"),
          n = e("./util"),
          a = e("../../lang/index"),
          s = e("../../player/base/event/eventtype"),
          l = r.extend({
            init: function (e, t) {
              (this.isOpened = !1),
                r.call(this, e, t),
                this.addClass(t.className || "prism-cc-btn");
            },
            createEl: function () {
              return r.prototype.createEl.call(this, "div");
            },
            bindEvent: function () {
              var i = this;
              this.on("click", function () {
                o.addClass(i._el, "disabled");
                var e = "on",
                  t = "";
                i.isOpened
                  ? (i._player._ccService.close(), (e = "off"))
                  : (t = i._player._ccService.open()),
                  (i.isOpened = !i.isOpened),
                  i._player.trigger(s.Private.CCStateChanged, {
                    value: e,
                    lang: t,
                  }),
                  i.disabledHandler && clearTimeout(i.disabledHandler),
                  (i.disabledHandler = setTimeout(function () {
                    o.removeClass(i._el, "disabled");
                  }, 1e3)),
                  i._player.trigger(s.Private.MarkerTextHide);
              }),
                this._player.on(s.Private.CCChanged, function (e) {
                  var t = e.paramData;
                  i.isOpened = "off" != t;
                }),
                n.registerTooltipEvent.call(this, this.el(), function () {
                  return i.isOpened
                    ? a.get("CloseSubtitle")
                    : a.get("OpenSubtitle");
                });
            },
            disposeUI: function () {
              this.disabledHandler &&
                (clearTimeout(this.disabledHandler),
                (this.disabledHandler = null));
            },
          });
        t.exports = l;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
        "./util": 121,
      },
    ],
    97: [
      function (e, t, i) {
        var r = e("../component"),
          n = e("../../player/base/event/eventtype"),
          a = e("../../lib/event"),
          s = e("../../lib/dom"),
          o = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                this.addClass(t.className || "prism-controlbar"),
                this.initChildren(),
                this.onEvent();
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this);
              return (
                (e.innerHTML = '<div class="prism-controlbar-bg"></div>'), e
              );
            },
            onEvent: function () {
              var i = this.player(),
                e = i.options(),
                r = this;
              a.on(this._el, "mouseover", function () {
                var e = document.querySelector(
                  "#" + r.id() + " .prism-progress-cursor"
                );
                s.css(e, "display", "block");
              }),
                a.on(this._el, "mouseout", function (e) {
                  var t = document.querySelector(
                    "#" + r.id() + " .prism-progress-cursor"
                  );
                  s.css(t, "display", "none"),
                    i.trigger(n.Private.ThumbnailHide);
                }),
                (this.timer = null);
              var t = e.controlBarVisibility;
              if ((1 == e.controlBarForOver && (t = "hover"), "hover" == t)) {
                r.hide();
                var o = function () {
                  r._hideHandler && clearTimeout(r._hideHandler),
                    r._show(),
                    i.fullscreenService.getIsFullScreen() && r._hide();
                };
                i.on(n.Private.MouseOver, function () {
                  o();
                }),
                  a.on(this._player.tag, "click", function (e) {
                    e && e.target == e.currentTarget && o();
                  }),
                  a.on(this._player.tag, "touchstart", function (e) {
                    e && e.target == e.currentTarget && o();
                  }),
                  i.on(n.Private.MouseOut, function () {
                    r._hideHandler = setTimeout(function () {
                      r.hide(),
                        i.trigger(n.Private.HideBar),
                        i.trigger(n.Private.VolumeVisibilityChange, ""),
                        i.trigger(n.Private.SettingListHide);
                    });
                  });
              } else
                "click" == t
                  ? (i.on(n.Private.Click, function (e) {
                      i._isError ||
                        (e.preventDefault(),
                        e.stopPropagation(),
                        r._show(),
                        r._hide());
                    }),
                    i.on(n.Player.Ready, function () {
                      r._hide();
                    }),
                    i.on(n.Private.TouchStart, function () {
                      r._show();
                    }),
                    i.on(n.Private.TouchMove, function () {
                      r._show();
                    }),
                    i.on(n.Private.TouchEnd, function () {
                      r._hide();
                    }))
                  : r._show();
            },
            _show: function () {
              this.show(),
                this._player.trigger(n.Private.ShowBar),
                this.timer && (clearTimeout(this.timer), (this.timer = null));
            },
            _hide: function () {
              var e = this,
                t = this.player().options().showBarTime;
              this.timer = setTimeout(function () {
                e.hide(),
                  e._player.trigger(n.Private.HideBar),
                  e._player.trigger(n.Private.VolumeVisibilityChange, ""),
                  e._player.trigger(n.Private.SettingListHide);
              }, t);
            },
            disposeUI: function () {
              this.timer && (clearTimeout(this.timer), (this.timer = null)),
                this._hideHandler &&
                  (clearTimeout(this._hideHandler), (this._hideHandler = null));
            },
          });
        t.exports = o;
      },
      {
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    98: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../lib/dom"),
          n = e("../../player/base/event/eventtype"),
          a = r.extend({
            init: function (e, t) {
              r.call(this, e, t), this.addClass(t.className || "prism-cover");
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div"),
                t = this.options().cover;
              return (
                t
                  ? (e.style.backgroundImage = "url(" + t + ")")
                  : o.css(e, "display", "none"),
                e
              );
            },
            _hide: function (e) {
              var t = document.querySelector("#" + this.id() + " .prism-cover");
              t && o.css(t, "display", "none");
            },
            _show: function (e) {
              var t = document.querySelector("#" + this.id() + " .prism-cover");
              t && o.css(t, "display", "block");
            },
            bindEvent: function () {
              this._player.on(n.Private.Cover_Show, this._show),
                this._player.on(n.Private.Cover_Hide, this._hide);
            },
          });
        t.exports = a;
      },
      {
        "../../lib/dom": 18,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    99: [
      function (e, t, i) {
        var r = e("../component"),
          h = e("../../lib/util"),
          f = e("../../lib/dom"),
          o = e("../../lib/event"),
          n = e("../../lib/ua"),
          _ = e("../../lang/index"),
          a = e("../../player/base/event/eventtype"),
          s = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-ErrorMessage"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (
                (e.innerHTML =
                  "<div class='prism-error-content'><p></p></div><div class='prism-error-operation'><a class='prism-button prism-button-refresh'>" +
                  _.get("Refresh_Text") +
                  "</a><a class='prism-button prism-button-retry'  target='_blank'>" +
                  _.get("Retry") +
                  "</a><a class='prism-button prism-button-orange'  target='_blank'>" +
                  _.get("Detection_Text") +
                  "</a></div><div class='prism-detect-info prism-center'><p class='errorCode'><span class='info-label'>code\uff1a</span><span class='info-content'></span></p><p class='vid'><span class='info-label'>vid:</span><span class='info-content'></span></p><p class='uuid'><span class='info-label'>uuid:</span><span class='info-content'></span></p><p class='requestId'><span class='info-label'>requestId:</span><span class='info-content'></span></p><p class='dateTime'><span class='info-label'>" +
                  _.get("Play_DateTime") +
                  "\uff1a</span><span class='info-content'></span></p></div>"),
                e
              );
            },
            bindEvent: function () {
              var i = this;
              i._player.on(a.Private.Error_Show, function (e) {
                var t = null;
                i._player.getMonitorInfo && (t = i._player.getMonitorInfo()),
                  i._show(e, t);
              }),
                i._player.on(a.Private.Error_Hide, function () {
                  i._hide();
                });
              var e = document.querySelector(
                "#" + i.id() + " .prism-button-refresh"
              );
              if (
                (o.on(e, "click", function () {
                  location.reload(!0);
                }),
                n.IS_MOBILE)
              ) {
                e = document.querySelector(
                  "#" + i.id() + " .prism-detect-info"
                );
                f.addClass(e, "prism-width90");
              }
              var t = document.querySelector(
                "#" + i.id() + " .prism-button-retry"
              );
              o.on(t, "click", function () {
                var e = i._player.getCurrentTime(),
                  t = i._player._options.source;
                (i._player._setDefaultCC = !0),
                  i._player._loadByUrlInner(t, e, !0);
              });
            },
            _show: function (e, t) {
              var i = e.paramData,
                r = "",
                o = "";
              i.mediaId && (r = i.mediaId);
              var n = document.querySelector(
                "#" + this.id() + " .prism-button-orange"
              );
              if (n) {
                if (t && this._player._options.diagnosisButtonVisible) {
                  t.vu
                    ? (o = decodeURIComponent(t.vu))
                    : f.css(n, "display", "none");
                  var a =
                    "//player.alicdn.com/detection.html?from=h5&vid=" +
                    r +
                    "&source=" +
                    (o ? encodeURIComponent(o) : "") +
                    "&uuid=" +
                    t.uuid +
                    "&lang=" +
                    _.getCurrentLanguage();
                  n && (n.href = a);
                } else f.css(n, "display", "none");
                var s = i.display_msg || i.error_msg;
                (document.querySelector(
                  "#" + this.id() + " .prism-error-content p"
                ).innerHTML = s),
                  (document.querySelector(
                    "#" + this.id() + " .errorCode .info-content"
                  ).innerText = i.error_code);
                var l = document.querySelector("#" + this.id() + " .vid");
                if (
                  (i.mediaId
                    ? (f.css(l, "display", "block"),
                      (document.querySelector(
                        "#" + this.id() + " .vid .info-content"
                      ).innerText = i.mediaId))
                    : f.css(l, "display", "none"),
                  i.uuid)
                )
                  document.querySelector(
                    "#" + this.id() + " .uuid .info-content"
                  ).innerText = i.uuid;
                else {
                  var u = document.querySelector("#" + this.id() + " .uuid");
                  f.css(u, "display", "none");
                }
                if (i.requestId)
                  document.querySelector(
                    "#" + this.id() + " .requestId .info-content"
                  ).innerText = i.requestId;
                else {
                  var c = document.querySelector(
                    "#" + this.id() + " .requestId"
                  );
                  f.css(c, "display", "none");
                }
                document.querySelector(
                  "#" + this.id() + " .dateTime .info-content"
                ).innerText = h.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
                var d = document.querySelector("#" + this.id());
                f.css(d, "display", "block");
                var p = this;
                p.playHideHandler && clearTimeout(p.playHideHandler),
                  (p.playHideHandler = setTimeout(function () {
                    p._player.trigger("play_btn_hide");
                  }));
              }
            },
            _hide: function () {
              var e = document.querySelector("#" + this.id());
              f.css(e, "display", "none");
            },
            disposeUI: function () {
              this.playHideHandler &&
                (clearTimeout(this.playHideHandler),
                (this.playHideHandler = null));
            },
          });
        t.exports = s;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    100: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../player/base/event/eventtype"),
          n = (e("../../lib/event"), e("../../lib/ua")),
          a = e("../../lang/index"),
          s = e("./util"),
          l = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                this.addClass(t.className || "prism-fullscreen-btn");
            },
            bindEvent: function () {
              var e = this;
              this._player.on(o.Player.RequestFullScreen, function () {
                n.IS_IOS || e.addClass("fullscreen");
              }),
                this._player.on(o.Player.CancelFullScreen, function () {
                  e.removeClass("fullscreen");
                }),
                s.registerTooltipEvent.call(this, this.el(), function () {
                  return e._player.fullscreenService.getIsFullScreen()
                    ? a.get("ExistFullScreen")
                    : a.get("Fullscreen");
                }),
                this.on("click", function () {
                  e._player.fullscreenService.getIsFullScreen()
                    ? e._player.fullscreenService.cancelFullScreen()
                    : e._player.fullscreenService.requestFullScreen(),
                    e._player.trigger(o.Private.MarkerTextHide);
                });
            },
          });
        t.exports = l;
      },
      {
        "../../lang/index": 11,
        "../../lib/event": 19,
        "../../lib/ua": 31,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
        "./util": 121,
      },
    ],
    101: [
      function (e, t, i) {
        "use strict";
        var r = e("../component"),
          o = e("../../lib/dom"),
          n = e("../../player/base/event/eventtype"),
          a = r.extend({
            init: function (e, t) {
              r.call(this, e, t), this.addClass(t.className || "prism-hide");
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (
                (e.innerHTML =
                  '<div class="circle"></div> <div class="circle1"></div>'),
                e
              );
            },
            _loading_hide: function (e) {
              var t = document.querySelector(
                "#" + this.id() + " .prism-loading"
              );
              t &&
                (o.removeClass(t, "prism-loading"),
                o.addClass(t, "prism-hide"));
            },
            _loading_show: function (e) {
              var t = document.querySelector("#" + this.id() + " .prism-hide");
              t &&
                (o.removeClass(t, "prism-hide"),
                o.addClass(t, "prism-loading"));
            },
            bindEvent: function () {
              this._player.on(n.Private.H5_Loading_Show, this._loading_show),
                this._player.on(n.Private.H5_Loading_Hide, this._loading_hide);
            },
          });
        t.exports = a;
      },
      {
        "../../lib/dom": 18,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    102: [
      function (e, t, i) {
        var r = e("../component"),
          o = (e("../../lib/util"), e("../../lib/dom")),
          n =
            (e("../../lib/event"),
            e("../../lib/ua"),
            e("../../lang/index"),
            e("../../player/base/event/eventtype")),
          a = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-info-display"),
                this.addClass(this.className);
            },
            createEl: function () {
              return r.prototype.createEl.call(this, "p");
            },
            bindEvent: function () {
              var r = this;
              r._player.on(n.Private.Info_Show, function (e) {
                var t = document.querySelector("#" + r.id()),
                  i = e.paramData;
                i &&
                  (void 0 !== i.text && i.text
                    ? ((t.innerHTML = i.text),
                      void 0 !== i.duration &&
                        i.duration &&
                        (r.handler && clearTimeout(r.handler),
                        (r.handler = setTimeout(function () {
                          o.css(t, "display", "none");
                        }, i.duration))),
                      "lb" == i.align
                        ? (o.addClass(t, "prism-info-left-bottom"),
                          o.removeClass(t, "prism-info-top-center"))
                        : "tc" == i.align
                        ? (o.addClass(t, "prism-info-top-center"),
                          o.removeClass(t, "prism-info-left-bottom"))
                        : (o.removeClass(t, "prism-info-left-bottom"),
                          o.removeClass(t, "prism-info-top-center")),
                      i.isBlack
                        ? o.addClass(t, "prism-info-black")
                        : o.removeClass(t, "prism-info-black"))
                    : (t.innerHTML = i),
                  o.css(t, "display", "block"));
              }),
                r._player.on(n.Private.Info_Hide, function (e) {
                  var t = document.querySelector("#" + r.id());
                  o.css(t, "display", "none");
                });
            },
            disposeUI: function () {
              this.handler &&
                (clearTimeout(this.handler), (this.handler = null));
            },
          });
        t.exports = a;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    103: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("./util"),
          n = (e("../../lib/util"), e("../../lib/dom")),
          a = e("../../lib/event"),
          s = e("../../lib/playerUtil"),
          l = e("../../lang/index"),
          u = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-live-display"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "p");
              return (
                (e.innerText = "LIVE"),
                s.isLiveShift(this._player._options) &&
                  n.addClass(e, "live-shift-display"),
                e
              );
            },
            bindEvent: function () {
              var e = document.querySelector("#" + this.id()),
                t = this;
              s.isLiveShift(this._player._options) &&
                (a.on(e, "click", function () {
                  t._player._liveshiftService.switchToLive();
                }),
                o.registerTooltipEvent.call(
                  this,
                  this.el(),
                  l.get("SwitchToLive")
                ));
            },
          });
        t.exports = u;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/playerUtil": 28,
        "../../lib/util": 33,
        "../component": 94,
        "./util": 121,
      },
    ],
    104: [
      function (e, t, i) {
        var r = e("../component"),
          o =
            (e("../../lib/dom"),
            e("../../lib/event"),
            e("../../player/base/event/eventtype")),
          n = e("../../player/base/plugin/status"),
          a = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                this.addClass(t.className || "prism-animation");
            },
            bindEvent: function () {
              var t = this;
              this._player.on(o.Player.Play, function () {
                t._player._isManualPlay &&
                  (t.removeClass("prism-pause-animation"),
                  t.addClass("prism-play-animation"),
                  t.removeClass("play-apply-animation"),
                  t.playHandler && clearTimeout(t.playHandler),
                  (t.playHandler = setTimeout(function () {
                    t.addClass("play-apply-animation");
                  })));
              }),
                this._player.on(o.Player.Pause, function () {
                  var e = t._player._status;
                  e != n.ended &&
                    e != n.error &&
                    t._player._isManualPause &&
                    (t.removeClass("prism-play-animation"),
                    t.addClass("prism-pause-animation"),
                    t.removeClass("play-apply-animation"),
                    t.pauseHandler && clearTimeout(t.pauseHandler),
                    (t.pauseHandler = setTimeout(function () {
                      t.addClass("play-apply-animation");
                    })));
                });
            },
            disposeUI: function () {
              this.playHandler &&
                (clearTimeout(this.playHandler), (this.playHandler = null)),
                this.pauseHandler &&
                  (clearTimeout(this.pauseHandler), (this.pauseHandler = null));
            },
          });
        t.exports = a;
      },
      {
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../player/base/event/eventtype": 43,
        "../../player/base/plugin/status": 66,
        "../component": 94,
      },
    ],
    105: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../player/base/event/eventtype"),
          n = e("./util"),
          a = e("../../lang/index"),
          s = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                this.addClass(t.className || "prism-play-btn");
            },
            bindEvent: function () {
              var t = this;
              this._player.on(o.Player.Play, function () {
                t.addClass("playing");
              }),
                this._player.on(o.Player.Pause, function () {
                  t.removeClass("playing");
                }),
                this.on(o.Private.PlayClick, function () {
                  if (t._player.paused()) {
                    var e = t._player.getCurrentTime();
                    (t._player.getDuration() <= e ||
                      t._player._ended ||
                      t._player.exceedPreviewTime(e)) &&
                      t._player.seek(0),
                      t._player.play(!0),
                      t.addClass("playing");
                  } else t._player.pause(!0), t.removeClass("playing");
                  t._player.trigger(o.Private.MarkerTextHide);
                }),
                n.registerTooltipEvent.call(this, this.el(), function () {
                  return t._player.paused() ? a.get("Play") : a.get("Pause");
                });
            },
          });
        t.exports = s;
      },
      {
        "../../lang/index": 11,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
        "./util": 121,
      },
    ],
    106: [
      function (e, t, i) {
        var r = e("../component"),
          a = e("../../lib/dom"),
          n = (e("../../lib/constants"), e("../../lib/event")),
          s = e("../../lib/ua"),
          l = e("../../lib/function"),
          o = e("../../lang/index"),
          u = e("../../config"),
          c = e("../../lib/util"),
          d = e("../../player/base/event/eventtype"),
          p = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className ? t.className : "prism-progress"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this);
              return (
                (e.innerHTML =
                  '<div class="prism-progress-loaded"></div><div class="prism-progress-played"></div><div class="prism-progress-marker"></div><div class="prism-progress-cursor"><img></img></div><p class="prism-progress-time"></p>'),
                e
              );
            },
            bindEvent: function () {
              var t = this;
              (this.loadedNode = document.querySelector(
                "#" + this.id() + " .prism-progress-loaded"
              )),
                (this.playedNode = document.querySelector(
                  "#" + this.id() + " .prism-progress-played"
                )),
                (this.cursorNode = document.querySelector(
                  "#" + this.id() + " .prism-progress-cursor"
                )),
                (this.timeNode = document.querySelector(
                  "#" + this.id() + " .prism-progress-time"
                )),
                (this.timeNode = document.querySelector(
                  "#" + this._player._options.id + " .prism-progress-time"
                ));
              var i = document.querySelector("#" + this.id()),
                e = document.querySelector(
                  "#" + this.id() + " .prism-progress-cursor img"
                ),
                r =
                  "https://" +
                  u.domain +
                  "/de/prismplayer/" +
                  u.h5Version +
                  "/skins/default/img/dragcursor.png";
              u.domain
                ? -1 < u.domain.indexOf("localhost") &&
                  (r =
                    "//" + u.domain + "/build/skins/default/img/dragcursor.png")
                : (r =
                    "de/prismplayer/" +
                    u.h5Version +
                    "/skins/default/img/dragcursor.png"),
                (e.src =
                  "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEQAAABECAYAAAA4E5OyAAAAAXNSR0IArs4c6QAADHFJREFUeAHNWltoVdkZPknM1RhrMtNqdRgnU6QPVRGqVLDVohZqEeahF9BpB0tvjoj1wam+2SKKKFj6UCtU26JTHAVLxXmxE6kdpDMPiowRO4oGrZeaeInRXDTR0+/bOd/23+usfc4+OycZF6z8a/3rX//lO/+67L1TkRmbUlEmM9ky6YlVUy5HXQOjpde1U3aAyul4Gl1xc9IEmmaOC3AmzqE8wQKMpDqSysWZShpwUjmvnZE4mWSuK+P2vU55mG6Qbt8zJZNEJm9eGgeLzXHHbd+2rTPixwVh+bZNHW7f6k0yHpGXIxFmgU4heTtWattn0gZaatvVZ+e7Y5G+dTwy4OkUktWYKKerHUetjGvOBqB2HOVcd8zVZ2V8YyGvMmwVbigoV4p8jVlKvexH6K5duxo6OzuXDwwM7BgcHDz69OnT9mw2ex31Qa5eJ49jfX19OynLOT5dRjeaER/kB/m2xPGtTKI2Ffkqg2WtytVxoKzVqDWotayHDh2a3N3d/VME+fdnz571IvCSCuc8fvz46L179362f//+KdKbs0Fbsis/5JfP5xGDEqdURuVEHhDbtm2b1NvbuxkB9aCWBIJPmDqo68GDB7/ZtGlTSwww8kf+xfmP6aWXOGUyRuP6dcKsWL58eQOcXgPnb5YDCBcc6sSyunXnzp21ixYtaoQPzERmpJst8jMuDkxJXuKUyIjAoBMhGG1tba9jaZweDSB8wDx58uTMkSNHZsCHOlSBImDoo/yNiwciyYpPgZRbMLRX1F25cuUbAGJUssIFQ30CPzQ09L8zZ84sRljjUd1sKQZKIjRKBuP+/fur4Fw/HRzrQpu0ffXq1Z8jOi4hmy1c0iMGxQWkYGbkwBhrHPLsEZiOjo5fpAAFU+KLCwb7BIQos+o0YWpqmXwmmeEiokw5derUt+DbBPqHavcTZYovRoj6iysclx113EC529ORF6XQF+4pu3fv/grC0wlkQVE8bpxeNFwhTbaZEWyis2bNGo8dfkxOk1LBJii45Z6dPHnyy4iSG61On2L7SR4oPkDsUtGJUs87QC5FS/V31OXl18WLF99BhM2ovPrTdwESt3QgEi0WkLjsqOMtEWn5Qi0VF2WCggy+vWTJklaEOBGVe16xpRNBw4LBNgFRdlBRmB0PHz78tX4F15EXpS//rl27tgO+v4Rql47iYoxu3EHQ4IdPi2yzuILB5L179zbPnTv33YqKilrUYcmUf/m8/sm9Z5kPbgxl2lA/6nyaufwwi+f4iswX6ivyHCrFjHxrbGycdfPmzb/i4taH+c9ytaAqRSVKYbVJWYVkZVdX14+am5v/QIMyygmllCEgcfjKYGbfp08ydwboY355ub4ys2pGTeZ7rdWZcfImX6wgB9maYW1vb98we/bsv0CYoAyi0ih/D987lKzMiUIuAIF9WwlKJXbvg3V1dcvTgnG7P5tZ9+/+zKfdT2mnaPny56oyv51fH2RMUWGPAAHBxfF4S0vLjzHcizqASuMCRBSsoGT164vhowEwa9asqa+pqVnsE0jCIxg//GdfYjCo8z8AjnM4N21pamr6+rx587iH8JRhvIVKhStgM4UTwz5Ol8XIDB5hJRcuE2ZGV79/iRRSyDm/xFzqSFMqKyvrd+7cuRBzddwWjNkdpE27VML+hAkTqDRV4Z6RdJn4DDBTqCNtaW1tnY+5zBBWG1/4g0u3DxCNkWpyZty4cTPS7B38YbmBjrT86eKTcBcsRRd9bmhoeB1zGKuyJFZFMUA0sQKAvMZOqaDwaI07TaQ8CeXSoa5Sinytra19FfMIBmteVlidhQCJTITySXZi0va5e8lOlCT60urCj9kE/YyH8Yp6TVpAIgA40hzj02NwtjtjBbtpNtI4haXq4rHLgh+TpwxjUCXbljB2C4hPIKJABqzgi952fGa8ijkEwcagQcvztvHu45F3oAiTt85ylbS68DDKS5kXANe3xN4C6W4HbVeXtz+zmftYeUoaXfQZgPQk9SAxIPi80JEGkFnNlZm0v6wNgjqoq9RCn/Hp9BrmDW8oRRTEWdBk0qANQC5RuWoRveEw85QPaiMt1JEo53OG5CcpviBeybF5buvsVowR1ywgXgHpx7fVf1F5msKnVj6opS2cSx1pCn3G27OPMZfOq7qqwsAsILFCHMC32g+gvE+giLqTfH0+wvOpNc3S4RzOLeU1gHwjxcui/g0bNnwIvxg0s0PU52reucystJWAsZJXhSx5Dy9dvl1VVRXcWHUTxFiiMlaP/wSCFSdj5u7du21Tpkzh95rHqHwn0o/KByNliyhYz8/koOP5Y4WzPT097wPx8HKmX8Izz8vim7AD32zIvDO7rmC2MCsosx+ynFNKkU+k9LWjo6MN87V38NqsPcSrVtmgQVkXX9kRZMqWLVteWr9+fXt1dXVj2iyRISLNZxNex3UDJRA8WnmayBHJJ6UEgpXZgRfNvStWrFh09OjRu5jP7OB9hNlhXxKhG2QLaVAUvCiD5w7IR2XuZHxjXY/K6++EGzdubOvv7+cHIX5TDSoceCGK/KFv9PHcuXO/g89fQn0VlS+b+T7HffuuuAOqrZ8dlYhAjhny8G9OZ5ctW/YmXrw0cg/RPiIqJWNN8YsEJrlMctnR+cYbb6y/desW9w5mheiwoN/B4BWib4iTVDmudvbAgQOP8LJ5B43SuBzxKRlrHn0RIBcuXPh97m07lwdfyBAUnTKKJ89FZYaoBMKMAIPtyF4ybdq0GqTjCbxwno1H6wyy5TPLFP0gAgPLJfPo0aPzeEv2XXxDIhB8scz9gxkyhCowRMEKS2yGSIKTWDQ5oNevXx88ePDgm7i93qYDNlPk4PC00f0rWxYMbKSdmzdvfhtgMHhWZQczhUUxDfcK/LVZEZwqkLWbK+/f/BcDbkx8N9J0/PjxZbgWY//qzwIc/u/XmG20+BECW7RJ2/QBmTGwb9++H8A3bqTTUaegpvqUiXnB0nBBISACJfycCZ5AmYSlsxaOBA7h14mcPnS63EVAkPI0oc0cGNmTJ0/+Cr7NQH0N9YuoJX/sZiYUKja9tGzsxjQ4c+bMdy9fvrwOzj3m8uFmy2rTWe1ChoqNUYf0kMoObdL26dOnNy5cuPBv0KOlwj3D7hsyYWMSL6QWEFdQfQHhUgEzhE+FB06cOPF9pG5nzsHAYfyKkSAUUGg9QcMFgjoJhuwgQ7oOHz78Vg4M7hM8TXg9t2BY32lVsbHN4vaHufhrl4zaBM0uHV3WuJ/owsaXuC3YzL6KZ4dPuITw2TOL9xBBSsP5YH9BIOEeY1O/UJtzWKmDy4M6qZs2cPy3r169eiFsc5m0or6CygtY6n+pYtBucXnqCyAfJWis1fiOWo9seWv69OnrcL3/vI5kUV3mdJETlRPKImWGqLKNFOB08Z6xdOnS9wAMlwizgpVHrDJDGVxSdihY6AlLIZ4PDPEECq/8tQsWLGjas2fP21OnTv0JgBnPwONACS3nGgJBVGAgU3o7Ojr+vGrVqj+ePXuWdwsuEQFCMHjEsp8UDIhGl4sveAr5+OIJgDhKYPQcVL1y5cqWtWvXfgfALJ04ceJ8AFOvrBClQVsIBEsOkH58wf8I//zStn379n8cO3asG0MM2G6eyhDybEaoDXY0cDJQhg0Nt4O/CtKwEvEtGJygPsGw7RAY8KvnzJnTsHXr1kW4RX4N71VacdN9BVnThAwKPqIjA/qQDT3YJ/6Li1XHpUuXPt64ceOH58+f569PEFiZFay6cAkMZQWGIqCoT+qWxIBwYjGwFLhk1XepNmRuxrrTEDi2LYCuPQUoIEiVFaQEQuAoExSg+hDJzwIyUSQ73Mv9dZ2IDKITNy6+pWyrUo/aogxeQAgMZpAFhfNYFBCp9gkBwj7bpCxWVkG6dFjy+V+NP+fkWnS2WImTEd9HybN8t82+AJKsZOiPgmTgbJPaNrqhjIKLo5S1RXKWF7atEyHT04iTs3y1SW2b6mxfbZkhMLa4DgsIymjMUtuWHvHUF43jazx0NGQUaLiBWFGNiXJM7ThqZawutq3jasdRKy8ZV5+V8Y2FPDkbMoo0CsnbsVLbPrM2uFLbrj473x2L9K3jkYECnWJz3HHbt21rQvw4xy3ftqnD7Vu9ScYj8nIkwkzYSTLXlXH7CU3lBV0MBOpNIpNnP62DVlFSHUnlrG7bThpgUjmrO2yP1MlQERppdMXNSRNUmjnW/6Ad51CeYImM0dLrulEWEKzSsXK8XHbKDoAFg+3/AzG6P4gTtPU8AAAAAElFTkSuQmCC"),
                n.on(this.cursorNode, "mousedown", function (e) {
                  t._onMouseDown(e);
                }),
                n.on(this.cursorNode, "touchstart", function (e) {
                  t._onMouseDown(e);
                }),
                n.on(i, "mousemove", function (e) {
                  t._progressMove(e);
                }),
                n.on(i, "touchmove", function (e) {
                  t._progressMove(e);
                });
              var o = function (e) {
                t._progressDown = e;
              };
              n.on(i, "mousedown", function (e) {
                o(!0);
              }),
                n.on(i, "touchstart", function (e) {
                  o(!0);
                }),
                n.on(i, "mouseup", function (e) {
                  o(!1);
                }),
                n.on(i, "touchend", function (e) {
                  o(!1);
                }),
                n.on(this._el, "click", function (e) {
                  t._onMouseClick(e);
                }),
                this._player.on(d.Private.HideProgress, function (e) {
                  t._hideProgress(e);
                }),
                this._player.on(d.Private.CancelHideProgress, function (e) {
                  t._cancelHideProgress(e);
                }),
                n.on(i, d.Private.MouseOver, function (e) {
                  t._onMouseOver(e);
                }),
                n.on(i, d.Private.MouseOut, function (e) {
                  t._onMouseOut(e);
                }),
                n.on(this.controlNode, d.Private.MouseLeave, function (e) {
                  t._offMouseUp();
                }),
                s.IS_PC
                  ? (n.on(i, "mouseover", function () {
                      a.addClass(i, "prism-progress-hover"),
                        a.addClass(t.cursorNode, "cursor-hover");
                    }),
                    n.on(i, "mouseout", function (e) {
                      a.removeClass(i, "prism-progress-hover"),
                        a.removeClass(t.cursorNode, "cursor-hover"),
                        (t._progressDown = !1);
                    }))
                  : (a.addClass(i, "prism-progress-hover"),
                    a.addClass(t.cursorNode, "cursor-hover")),
                (this.bindTimeupdate = l.bind(this, this._onTimeupdate)),
                this._player.on(d.Player.TimeUpdate, this.bindTimeupdate),
                s.IS_IPAD
                  ? (this.interval = setInterval(function () {
                      t._onProgress();
                    }, 500))
                  : this._player.on(d.Video.Progress, function () {
                      t._onProgress();
                    });
            },
            _progressMove: function (e) {
              e.preventDefault();
              var t = this._getSeconds(e);
              if (t != 1 / 0) {
                var i = c.formatTime(t),
                  r = this._getDistance(e);
                this.cursorNode &&
                  (this._player.trigger(d.Private.ThumbnailShow, {
                    time: t,
                    formatTime: i,
                    left: r,
                    progressWidth: this.el().offsetWidth,
                  }),
                  this._progressDown && this._onMouseMove(e));
              }
            },
            _hideProgress: function (e) {
              n.off(this.cursorNode, "mousedown"),
                n.off(this.cursorNode, "touchstart");
            },
            _cancelHideProgress: function (e) {
              var t = this;
              n.on(this.cursorNode, "mousedown", function (e) {
                t._onMouseDown(e);
              }),
                n.on(this.cursorNode, "touchstart", function (e) {
                  t._onMouseDown(e);
                });
            },
            _canSeekable: function (e) {
              var t = !0;
              return (
                "function" == typeof this._player.canSeekable &&
                  (t = this._player.canSeekable(e)),
                t
              );
            },
            _onMouseOver: function (e) {
              this._cursorHideHandler &&
                (clearTimeout(this._cursorHideHandler),
                (this._cursorHideHandler = null)),
                this._mouseInProgress ||
                  this._updateCursorPosition(this._player.getCurrentTime()),
                (this._mouseInProgress = !0);
            },
            _onMouseOut: function (e) {
              var t = this;
              this._cursorHideHandler && clearTimeout(this._cursorHideHandler),
                (this._cursorHideHandler = setTimeout(function () {
                  t._player.trigger(d.Private.ThumbnailHide),
                    (t._mouseInProgress = !1);
                }));
            },
            _getSeconds: function (e) {
              var t = this._getDistance(e),
                i = this.el().offsetWidth,
                r = this._player.getDuration()
                  ? (t / i) * this._player.getDuration()
                  : 0;
              return (
                r < 0 && (r = 0),
                r > this._player.getDuration() &&
                  (r = this._player.getDuration()),
                r
              );
            },
            _getDistance: function (e) {
              for (
                var t = this.el().offsetLeft, i = this.el();
                (i = i.offsetParent);

              ) {
                var r = a.getTranslateX(i);
                t += i.offsetLeft + r;
              }
              var o = e.touches ? e.touches[0].pageX : e.pageX;
              return Math.abs(o - t);
            },
            _onMouseClick: function (e) {
              var t = this,
                i = t._getSeconds(e);
              if (t._canSeekable(i)) {
                t._player.exceedPreviewTime(i) &&
                  (i = t._player.getPreviewTime()),
                  t._updateCursorPosition(i);
                this._mouseClickTimeHandle &&
                  clearTimeout(this._mouseClickTimeHandle),
                  (this._mouseClickTimeHandle = setTimeout(function () {
                    (t._player._seeking = !0),
                      t._player.trigger(d.Private.SeekStart, {
                        fromTime: t._player.getCurrentTime(),
                      }),
                      t._player.seek(i),
                      t._player.trigger(d.Private.EndStart, { toTime: i }),
                      (t._mouseClickTimeHandle = null),
                      (t._inWaitingSeek = !1);
                  }, 300)),
                  (this._inWaitingSeek = !0);
              } else
                t._player.trigger(d.Private.Info_Show, {
                  text: o.get("Can_Not_Seekable"),
                  duration: 2e3,
                });
            },
            _onMouseDown: function (e) {
              var t = this;
              e.preventDefault(),
                this._player.trigger(d.Private.SeekStart, {
                  fromTime: this._player.getCurrentTime(),
                }),
                n.on(this.controlNode, "mousemove", function (e) {
                  t._onMouseMove(e);
                }),
                n.on(this.controlNode, "touchmove", function (e) {
                  t._onMouseMove(e);
                }),
                n.on(this._player.tag, "mouseup", function (e) {
                  t._onPlayerMouseUp(e);
                }),
                n.on(this._player.tag, "touchend", function (e) {
                  t._onPlayerMouseUp(e);
                }),
                n.on(this.controlNode, "mouseup", function (e) {
                  t._onControlBarMouseUp(e);
                }),
                n.on(this.controlNode, "touchend", function (e) {
                  t._onControlBarMouseUp(e);
                });
            },
            _onMouseUp: function (e) {
              this._onMouseUpIntern(e);
            },
            _onControlBarMouseUp: function (e) {
              this._onMouseUpIntern(e);
            },
            _onPlayerMouseUp: function (e) {
              this._onMouseUpIntern(e);
            },
            _offMouseUp: function () {
              n.off(this.controlNode, "mousemove"),
                n.off(this.controlNode, "touchmove"),
                n.off(this._player.tag, "mouseup"),
                n.off(this._player.tag, "touchend"),
                n.off(this.controlNode, "mouseup"),
                n.off(this.controlNode, "touchend");
            },
            _onMouseUpIntern: function (e) {
              e.preventDefault(), this._offMouseUp();
              var t =
                (this.playedNode.offsetWidth / this.el().offsetWidth) *
                this._player.getDuration();
              this._player.getDuration();
              isNaN(t) || this._player.seek(t),
                this._player.trigger(d.Private.EndStart, { toTime: t });
            },
            _onMouseMove: function (e) {
              e.preventDefault();
              var t = this._getSeconds(e);
              this._player.exceedPreviewTime(t) &&
                (t = this._player.getPreviewTime()),
                this._player.seek(t),
                this._updateProgressBar(this.playedNode, t),
                this._updateCursorPosition(t);
            },
            _onTimeupdate: function (e) {
              this._inWaitingSeek ||
                this._player._seeking ||
                this._progressDown ||
                (this._updateProgressBar(
                  this.playedNode,
                  this._player.getCurrentTime()
                ),
                this._updateCursorPosition(this._player.getCurrentTime()),
                this._player.trigger(d.Private.UpdateProgressBar, {
                  time: this._player.getCurrentTime(),
                }));
            },
            _onProgress: function (e) {
              this._player.getDuration() &&
                1 <= this._player.getBuffered().length &&
                this._updateProgressBar(
                  this.loadedNode,
                  this._player
                    .getBuffered()
                    .end(this._player.getBuffered().length - 1)
                );
            },
            _updateProgressBar: function (e, t) {
              var i = this._player.getDuration();
              if (1 != this._player._switchSourcing && i) {
                var r = t / i + 0.005;
                1 < r && (r = 1), e && a.css(e, "width", 100 * r + "%");
              }
            },
            _updateCursorPosition: function (e) {
              var t = this._player.getDuration();
              if (1 != this._player._switchSourcing && t) {
                var i = 1,
                  r = this._player.el().clientWidth,
                  o = 10 / r,
                  n = e / t - o;
                0 != r && (i = 1 - o),
                  (n = n < 0 ? 0 : n),
                  this.cursorNode &&
                    (i < n
                      ? (a.css(this.cursorNode, "right", "0px"),
                        a.css(this.cursorNode, "left", "auto"))
                      : (a.css(this.cursorNode, "right", "auto"),
                        a.css(this.cursorNode, "left", 100 * n + "%")));
              }
            },
            disposeUI: function () {
              this.cursorNodeHandler &&
                (clearTimeout(this.cursorNodeHandler),
                (this.cursorNodeHandler = null)),
                this._cursorHideHandler &&
                  (clearTimeout(this._cursorHideHandler),
                  (this._cursorHideHandler = null)),
                this._mouseClickTimeHandle &&
                  (clearTimeout(this._mouseClickTimeHandle),
                  (this._mouseClickTimeHandle = null));
            },
          });
        t.exports = p;
      },
      {
        "../../config": 5,
        "../../lang/index": 11,
        "../../lib/constants": 15,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/function": 20,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    107: [
      function (e, t, i) {
        var r = e("../component"),
          o = (e("../../lib/util"), e("../../lib/dom")),
          n = e("../../lib/event"),
          a = e("../../player/base/event/eventtype"),
          s = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-marker-text"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (e.innerHTML = "<p></p>"), e;
            },
            bindEvent: function () {
              var r = this;
              r._player.on(a.Private.MarkerTextShow, function (e) {
                var t = e.paramData,
                  i = a.Player.MarkerDotOver;
                if (
                  (r._player.trigger(i, e.paramData),
                  t.progressMarker.isCustomized)
                )
                  r._player.trigger(a.Private.LifeCycleChanged, {
                    type: i,
                    data: e.paramData,
                  });
                else {
                  r._thumbnailShowHanlde &&
                    (o.css(r.el(), "display", "none"),
                    clearTimeout(r._thumbnailShowHanlde)),
                    (r._thumbnailShowHanlde = setTimeout(function () {
                      if (
                        ((document.querySelector(
                          "#" + r.id() + " p"
                        ).innerText = t.progressMarker.text || ""),
                        t)
                      ) {
                        o.css(r.el(), "display", "block");
                        var e = r._player.el().offsetWidth;
                        (left = e * t.left),
                          (width = r.el().offsetWidth),
                          left + width > e
                            ? (o.css(r.el(), "right", "0px"),
                              o.css(r.el(), "left", "auto"))
                            : ((left -= width / 2),
                              (left = left < 0 ? 0 : left),
                              o.css(r.el(), "right", "auto"),
                              o.css(r.el(), "left", left + "px"));
                      }
                    }, 30));
                }
              }),
                r._player.on(a.Private.MarkerTextHide, function (e) {
                  r._player.trigger(a.Player.MarkerDotOut),
                    r._player.trigger(a.Private.LifeCycleChanged, {
                      type: a.Player.MarkerDotOut,
                      data: "",
                    }),
                    r._thumbnailShowHanlde &&
                      clearTimeout(r._thumbnailShowHanlde),
                    o.css(r.el(), "display", "none");
                }),
                n.on(r._player.tag, "click", function (e) {
                  e &&
                    e.target == e.currentTarget &&
                    r._player.trigger(a.Private.MarkerTextHide);
                }),
                n.on(r._player.tag, "touchstart", function (e) {
                  e &&
                    e.target == e.currentTarget &&
                    r._player.trigger(a.Private.MarkerTextHide);
                });
            },
            disposeUI: function () {
              this._thumbnailShowHanlde &&
                (clearTimeout(this._thumbnailShowHanlde),
                (this._thumbnailShowHanlde = null));
            },
          });
        t.exports = s;
      },
      {
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/util": 33,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    108: [
      function (e, t, i) {
        var r = e("./selector"),
          s = e("../../../lib/object"),
          u = (e("../../../lib/util"), e("../../../lib/cookie")),
          l = e("../../../lib/dom"),
          c = (e("../../../lib/event"), e("../../../lib/constants")),
          d = e("../../../lang/index"),
          p = e("../../../player/base/event/eventtype"),
          o = r.extend({
            init: function (e, t) {
              (this.Name = d.get("Quality")),
                (this.Type = "quality"),
                (this.Tooltip = d.get("Quality_Switch_To")),
                r.call(this, e, t),
                (this._isMasterLevel = !1);
            },
            showTip: function (e, t) {
              this._player.trigger(p.Private.Info_Show, {
                text: e,
                duration: t,
                align: "lb",
              });
            },
            bindEvent: function () {
              this.bindCommonEvent();
              var s = this;
              this._player.on(p.Private.QualityChange, function (e) {
                var t = s._player._urls,
                  i = e.paramData;
                if (i.levelSwitch) {
                  var r = i.desc;
                  (s._autoSWitchDesc = r), s._updateText(r);
                } else if (0 < s._player._currentPlayIndex) {
                  s._autoSWitchDesc = "";
                  var o = s._player._currentPlayIndex,
                    n = t[o - 1].desc,
                    a = t[o].desc;
                  s.showTip(n + e.paramData + a, 1e3),
                    s._player.trigger(p.Private.SelectorValueChange, t[o].Url);
                }
              });
              var e = document.querySelector("#" + s.id() + " .selector-list");
              this._player.on(p.Player.LevelSwitch, function () {
                l.addClass(e, "disabled");
              }),
                this._player.on(p.Player.LevelSwitched, function () {
                  l.removeClass(e, "disabled");
                });
            },
            generateList: function (e) {
              var t = this._player._urls,
                o = this._player._currentPlayIndex,
                i = this._player._qualityService.levels;
              0 < i.length &&
                ((this._isMasterLevel = !0), (o = (t = i).length - 1));
              var n = document.querySelector(
                "#" + this.id() + " .selector-list"
              );
              if (0 < t.length) {
                var a = this;
                s.each(t, function (e, t) {
                  if (e.desc) {
                    var i = l.createEl.call(this, "li", {
                        key: e.Url,
                        index: t,
                        text: e.desc,
                      }),
                      r = l.createEl.call(this, "span", {
                        key: e.Url,
                        index: t,
                        text: e.desc,
                      });
                    t == o &&
                      (l.addClass(i, "current"), (a._previousSelection = i)),
                      (r.innerText = e.desc),
                      i.appendChild(r),
                      n.appendChild(i);
                  }
                });
              }
              this._autoSWitchDesc && this._updateText(this._autoSWitchDesc);
            },
            execute: function (e) {
              if (((this._player._switchSourcing = !0), this._isMasterLevel)) {
                var t = this._player._qualityService.levels;
                for (n = 0; n < t.length; n++)
                  t[n].Url == e &&
                    t[n].desc != d.get("Auto") &&
                    this._updateText("");
                this._player._switchLevel && this._player._switchLevel(e);
              } else {
                for (
                  var i = this._player._urls.length,
                    r = this._player._currentPlayIndex,
                    o = -1,
                    n = 0;
                  n < i;
                  n++
                )
                  if (this._player._urls[n].Url == e) {
                    (o = this._player._currentPlayIndex = n),
                      u.set(
                        c.SelectedStreamLevel,
                        this._player._urls[n].definition,
                        365
                      );
                    break;
                  }
                if (r != o && -1 < o) {
                  var a = this._player.getCurrentTime();
                  this._previousCurrentTime
                    ? "playing" != this._player._status &&
                      (a = this._previousCurrentTime)
                    : (this._previousCurrentTime = a),
                    (this._previousCurrentTime = a);
                  var s =
                    this._player.autoplay || "pause" != this._player._status;
                  this._player.autoplay || 0 != a || (s = !1),
                    this._player._loadByUrlInner(e, a, s);
                }
              }
              var l = this;
              setTimeout(function () {
                l._player._switchSourcing = !1;
              });
            },
            _updateText: function (e) {
              var t = document.querySelector(
                  "#" + this.id() + " .selector-list .current"
                ),
                i = document.querySelector(
                  "#" + this.id() + " .selector-list .current span"
                ),
                r = d.get("Auto");
              i &&
                i.innerText &&
                -1 < i.innerText.indexOf(r) &&
                ((r += e ? "(" + e + ")" : ""),
                (i.innerText = r),
                t && (t.text = r));
            },
          });
        t.exports = o;
      },
      {
        "../../../lang/index": 11,
        "../../../lib/constants": 15,
        "../../../lib/cookie": 16,
        "../../../lib/dom": 18,
        "../../../lib/event": 19,
        "../../../lib/object": 26,
        "../../../lib/util": 33,
        "../../../player/base/event/eventtype": 43,
        "./selector": 114,
      },
    ],
    109: [
      function (e, t, i) {
        var r = e("./selector"),
          a = e("../../../lib/object"),
          s =
            (e("../../../lib/util"),
            e("../../../lib/cookie"),
            e("../../../lib/dom")),
          o = (e("../../../lib/event"), e("./util"), e("../../../lang/index")),
          l = e("../../../player/base/event/eventtype"),
          n = r.extend({
            init: function (e, t) {
              (this.Name = o.get("AudioTrack")),
                (this.Type = "audio"),
                (this.Tooltip = o.get("AudioTrack_Switch_To")),
                r.call(this, e, t);
            },
            bindEvent: function () {
              this.bindCommonEvent();
              var o = this,
                n = document.querySelector("#" + o.id() + " .selector-list");
              document.querySelector("#" + o.id() + " .header");
              o._player.on(l.Private.ChangeURL, function () {
                o._hasGeneratedList = !1;
              }),
                this._player.on(l.Player.AudioTrackSwitch, function () {
                  s.addClass(n, "disabled");
                }),
                this._player.on(l.Player.AudioTrackSwitched, function () {
                  s.removeClass(n, "disabled");
                }),
                o._player.on(l.Player.AudioTrackReady, function (e) {
                  o._hasGeneratedList ||
                    (o._clear(),
                    (e = e.paramData) &&
                      (a.each(e, function (e, t) {
                        var i = s.createEl.call(o, "li", {
                            key: e.value,
                            text: e.text,
                          }),
                          r = s.createEl.call(o, "span", {
                            key: e.value,
                            text: e.text,
                          });
                        (r.innerText = e.text),
                          i.appendChild(r),
                          n.appendChild(i);
                      }),
                      (o._hasGeneratedList = !0)));
                });
            },
            execute: function (e) {
              this._player._audioTrackService["switch"](e);
            },
          });
        t.exports = n;
      },
      {
        "../../../lang/index": 11,
        "../../../lib/cookie": 16,
        "../../../lib/dom": 18,
        "../../../lib/event": 19,
        "../../../lib/object": 26,
        "../../../lib/util": 33,
        "../../../player/base/event/eventtype": 43,
        "./selector": 114,
        "./util": 116,
      },
    ],
    110: [
      function (e, t, i) {
        var r = e("../../component"),
          o =
            (e("../../../lib/dom"), e("../../../player/base/event/eventtype")),
          n = e("./list"),
          a = e("../../../lang/index"),
          s = e("../util"),
          l = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                this.addClass(t.className || "prism-setting-btn"),
                (this._settingList = new n(e, t)),
                e.addChild(this._settingList, t);
            },
            createEl: function () {
              return r.prototype.createEl.call(this, "div");
            },
            bindEvent: function () {
              var e = this;
              this.on("click", function () {
                e._settingList.isOpened
                  ? e._player.trigger(o.Private.SettingListHide)
                  : e._player.trigger(o.Private.SettingListShow),
                  e._player.trigger(o.Private.SelectorHide),
                  e._player.trigger(o.Private.MarkerTextHide),
                  e._player.trigger(o.Private.VolumeVisibilityChange, "");
              }),
                s.registerTooltipEvent.call(this, this.el(), a.get("Setting"));
            },
          });
        t.exports = l;
      },
      {
        "../../../lang/index": 11,
        "../../../lib/dom": 18,
        "../../../player/base/event/eventtype": 43,
        "../../component": 94,
        "../util": 121,
        "./list": 113,
      },
    ],
    111: [
      function (e, t, i) {
        var r = e("./selector"),
          s = e("../../../lib/object"),
          l = e("../../../lib/dom"),
          o = (e("../../../lib/event"), e("./util"), e("../../../lib/cookie")),
          n = e("../../../lib/constants"),
          a = e("../../../lang/index"),
          u = e("../../../player/base/event/eventtype"),
          c = r.extend({
            init: function (e, t) {
              (this.Name = a.get("Subtitle")),
                (this.Type = "cc"),
                (this.Tooltip = a.get("CC_Switch_To")),
                r.call(this, e, t);
            },
            bindEvent: function () {
              this.bindCommonEvent();
              var o = this;
              this._player.on(u.Private.CCStateChanged, function (e) {
                var t = e.paramData.value,
                  i = e.paramData.lang;
                "on" == t && i
                  ? (o._backCCText = i)
                  : "off" == t &&
                    "" == o._backCCText &&
                    (o._backCCText = o._previousSelection.text);
                var r = "Off";
                "on" == t && (r = o._backCCText),
                  o._player.trigger(u.Private.SelectorUpdateList, {
                    type: "cc",
                    text: r,
                  });
              });
            },
            generateList: function (o) {
              var n = document.querySelector(
                  "#" + this.id() + " .selector-list"
                ),
                e = this._player._ccService.tracks,
                a = this;
              s.each(e, function (e, t) {
                var i = l.createEl.call(this, "li", {
                    key: e.value,
                    text: e.text,
                  }),
                  r = l.createEl.call(this, "span", {
                    key: e.value,
                    text: e.text,
                  });
                e.text == o &&
                  (l.addClass(i, "current"), (a._previousSelection = i)),
                  (r.innerText = e.text),
                  i.appendChild(r),
                  n.appendChild(i);
              });
            },
            execute: function (e) {
              (this._backCCText = ""),
                o.set(n.SelectedCC, e, 365),
                this._player._ccService["switch"](e),
                this._player.trigger(u.Private.CCChanged, e);
            },
          });
        t.exports = c;
      },
      {
        "../../../lang/index": 11,
        "../../../lib/constants": 15,
        "../../../lib/cookie": 16,
        "../../../lib/dom": 18,
        "../../../lib/event": 19,
        "../../../lib/object": 26,
        "../../../player/base/event/eventtype": 43,
        "./selector": 114,
        "./util": 116,
      },
    ],
    112: [
      function (e, t, i) {
        t.exports = {
          CC: e("./cc"),
          Speed: e("./speed"),
          Quality: e("./Quality"),
          Audio: e("./audio"),
        };
      },
      { "./Quality": 108, "./audio": 109, "./cc": 111, "./speed": 115 },
    ],
    113: [
      function (e, t, i) {
        var a = e("../../component"),
          r = e("../../../lib/dom"),
          n = e("../../../lib/ua"),
          s = e("../../../lib/event"),
          l = e("../../../player/base/event/eventtype"),
          o = e("./export"),
          u = e("./util"),
          c = e("../../../lang/index"),
          d = a.extend({
            init: function (e, t) {
              for (var i in ((this.isOpened = !1),
              a.call(this, e, t),
              this.addClass(t.className || "prism-setting-list"),
              o)) {
                var r = new o[i](e, t);
                e.addChild(r, t);
              }
            },
            createEl: function () {
              var e = a.prototype.createEl.call(this, "div"),
                t =
                  "<div class='prism-setting-item prism-setting-{type}' type={type}><div class='setting-content'><span class='setting-title'>{value}</span><span class='array'></span><span class='current-setting'></span></div></div>",
                i = t
                  .replace(/{type}/g, "speed")
                  .replace("{value}", c.get("Speed")),
                r = t
                  .replace(/{type}/g, "cc")
                  .replace("{value}", c.get("Subtitle")),
                o = t
                  .replace(/{type}/g, "audio")
                  .replace("{value}", c.get("AudioTrack")),
                n = t
                  .replace(/{type}/g, "quality")
                  .replace("{value}", c.get("Quality"));
              return (e.innerHTML = i + r + o + n), e;
            },
            bindEvent: function () {
              document.querySelector(
                "#" + this.id() + " .prism-setting-speed .current-setting"
              ).innerText = c.get("Speed_1X_Text");
              var o = this,
                t = function () {
                  o._player.trigger(l.Private.SettingListHide),
                    (o.isOpened = !1);
                },
                i = function (e) {
                  e &&
                    e.text &&
                    (document.querySelector(
                      "#" +
                        o.id() +
                        " .prism-setting-" +
                        e.type +
                        " .current-setting"
                    ).innerText = e.text);
                };
              this._player.on(l.Private.SettingListShow, function (e) {
                o.isOpened = !0;
                e = e.paramData;
                i(e), r.css(o.el(), "display", "block");
              }),
                this._player.on(l.Private.UpdateToSettingList, function (e) {
                  e = e.paramData;
                  i(e);
                }),
                this._player.on(l.Private.SelectorUpdateList, function (e) {
                  e = e.paramData;
                  i(e), o._player.trigger(l.Private.SelectorValueChange, e);
                }),
                this._player.on(l.Private.SettingListHide, function () {
                  (o.isOpened = !1), r.css(o.el(), "display", "none");
                }),
                s.on(this.el(), "click", function (e) {
                  o._player.trigger(l.Private.SettingListHide);
                  var t = e.srcElement ? e.srcElement : e.target;
                  if ((t = u.findItemElementForList(t))) {
                    var i = t.getAttribute("type");
                    o._player.trigger(l.Private.SelectorShow, { type: i });
                  }
                });
              var e = n.IS_MOBILE ? "touchleave" : "mouseleave";
              s.on(this.el(), e, function () {
                t();
              }),
                s.on(this._player.tag, "click", function (e) {
                  e && e.target == e.currentTarget && t();
                }),
                s.on(this._player.tag, "touchstart", function (e) {
                  e && e.target == e.currentTarget && t();
                }),
                this._player.on(l.Private.QualityChange, function (e) {
                  var t = e.paramData;
                  if (t.levelSwitch) {
                    var i = document.querySelector(
                        "#" +
                          o.id() +
                          " .prism-setting-quality .current-setting"
                      ),
                      r = c.get("Auto");
                    -1 < i.innerText.indexOf(r) &&
                      (i.innerText = r + (t.desc ? "(" + t.desc + ")" : ""));
                  }
                });
            },
          });
        t.exports = d;
      },
      {
        "../../../lang/index": 11,
        "../../../lib/dom": 18,
        "../../../lib/event": 19,
        "../../../lib/ua": 31,
        "../../../player/base/event/eventtype": 43,
        "../../component": 94,
        "./export": 112,
        "./util": 116,
      },
    ],
    114: [
      function (e, t, i) {
        var r = e("../../component"),
          o =
            (e("../../../lib/object"),
            e("../../../lib/util"),
            e("../../../lib/ua")),
          a = (e("../../../lib/cookie"), e("../../../lib/dom")),
          s = e("../../../lib/event"),
          l = e("./util"),
          u =
            (e("../../../lang/index"),
            e("../../../player/base/event/eventtype")),
          n = r.extend({
            init: function (e, t) {
              (this._hasGeneratedList = !1),
                (this._previousSelection = null),
                (this._backupSelector = ""),
                r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-" + this.Type + "-selector prism-setting-selector"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (
                (e.innerHTML =
                  '<div class="header"><div class="left-array"></div><span>' +
                  this.Name +
                  '</span></div><ul class="selector-list"></ul>'),
                e
              );
            },
            bindEvent: function () {
              this.bindCommonEvent();
            },
            bindCommonEvent: function () {
              var n = this,
                e = document.querySelector("#" + n.id() + " .selector-list"),
                t = document.querySelector("#" + n.id() + " .header");
              this._player.on(u.Private.ChangeURL, function () {
                n._hasGeneratedList = !1;
              }),
                s.on(t, "click", function () {
                  n._player.trigger(u.Private.SelectorHide),
                    n._player.trigger(u.Private.SettingListShow, {
                      type: n.Type,
                      text: n._previousSelection
                        ? n._previousSelection.text
                        : "",
                    });
                }),
                s.on(e, "click", function (e) {
                  var t = e.srcElement ? e.srcElement : e.target,
                    i = t.key,
                    r = t.text;
                  if (void 0 !== r) {
                    n._previousSelection &&
                      a.removeClass(n._previousSelection, "current"),
                      (n._previousSelection = l.findliElementForSelector(t)),
                      a.addClass(n._previousSelection, "current"),
                      n.execute && n.execute(i);
                    var o = n.Tooltip + "<span>" + r + "</span>";
                    n._player.trigger(u.Private.Info_Show, {
                      text: o,
                      duration: 1e3,
                      align: "lb",
                    });
                  }
                }),
                n._player.on(u.Private.SelectorHide, function () {
                  i();
                }),
                n._player.on(u.Private.SelectorValueChange, function (e) {
                  var t = e.paramData;
                  if (t) {
                    if (t.type != n.Type) return;
                    var i = document.querySelectorAll(
                      "#" + n.id() + " .selector-list li"
                    );
                    if (i) {
                      var r = i.length;
                      0 == r && (n._backupSelector = t.text);
                      for (var o = 0; o < r; o++)
                        if (i[o].text == t.text) {
                          n._previousSelection &&
                            a.removeClass(n._previousSelection, "current"),
                            a.addClass(i[o], "current"),
                            (n._previousSelection = i[o]);
                          break;
                        }
                    }
                  }
                }),
                n._player.on(u.Private.SelectorShow, function (e) {
                  if ((e = e.paramData).type == n.Type) {
                    var t = document.querySelector(
                      "#" + n._player.id() + " .prism-" + e.type + "-selector"
                    );
                    n._hasGeneratedList ||
                      (n._clear(),
                      n.generateList(n._backupSelector),
                      (n._backupSelector = ""),
                      (n._hasGeneratedList = !0)),
                      a.css(t, "display", "block");
                  }
                });
              var i = function () {
                  a.css(n.el(), "display", "none"),
                    n._player.trigger(u.Private.UpdateToSettingList, {
                      type: n.Type,
                      text: n._previousSelection
                        ? n._previousSelection.text
                        : "",
                    });
                },
                r = o.IS_MOBILE ? "touchleave" : "mouseleave";
              s.on(this.el(), r, function () {
                i();
              }),
                s.on(this._player.tag, "click", function (e) {
                  e && e.target == e.currentTarget && i();
                }),
                s.on(this._player.tag, "touchstart", function (e) {
                  e && e.target == e.currentTarget && i();
                });
            },
            setSelected: function (e) {},
            generateList: function () {},
            _clear: function () {
              document.querySelector(
                "#" + this.id() + " .selector-list"
              ).innerHTML = "";
            },
          });
        t.exports = n;
      },
      {
        "../../../lang/index": 11,
        "../../../lib/cookie": 16,
        "../../../lib/dom": 18,
        "../../../lib/event": 19,
        "../../../lib/object": 26,
        "../../../lib/ua": 31,
        "../../../lib/util": 33,
        "../../../player/base/event/eventtype": 43,
        "../../component": 94,
        "./util": 116,
      },
    ],
    115: [
      function (e, t, i) {
        var r = e("./selector"),
          a = e("../../../lib/object"),
          s =
            (e("../../../lib/util"),
            e("../../../lib/cookie"),
            e("../../../lib/dom")),
          l =
            (e("../../../lib/event"), e("./util"), e("../../../lib/constants")),
          u = e("../../../lang/index"),
          o =
            (e("../../../player/base/event/eventtype"),
            r.extend({
              init: function (e, t) {
                (this.Name = u.get("Speed")),
                  (this.Type = "speed"),
                  (this.Tooltip = u.get("Speed_Switch_To")),
                  r.call(this, e, t);
              },
              generateList: function () {
                var o = document.querySelector(
                    "#" + this.id() + " .selector-list"
                  ),
                  e = l.SpeedLevels,
                  n = this;
                a.each(e, function (e, t) {
                  var i = s.createEl.call(this, "li", {
                      key: e.key,
                      text: e.text,
                    }),
                    r = s.createEl.call(this, "span", {
                      key: e.key,
                      text: e.text,
                    });
                  (r.innerText = e.text),
                    e.text == u.get("Speed_1X_Text") &&
                      (s.addClass(i, "current"), (n._previousSelection = i)),
                    i.appendChild(r),
                    o.appendChild(i);
                });
              },
              execute: function (e) {
                this._player.setSpeed(e);
              },
            }));
        t.exports = o;
      },
      {
        "../../../lang/index": 11,
        "../../../lib/constants": 15,
        "../../../lib/cookie": 16,
        "../../../lib/dom": 18,
        "../../../lib/event": 19,
        "../../../lib/object": 26,
        "../../../lib/util": 33,
        "../../../player/base/event/eventtype": 43,
        "./selector": 114,
        "./util": 116,
      },
    ],
    116: [
      function (e, i, t) {
        (i.exports.findliElementForSelector = function (e) {
          if (!e || "li" == e.tagName.toLowerCase()) return e;
          var t = e.parentElement;
          return t && "li" == t.tagName.toLowerCase() ? t : null;
        }),
          (i.exports.findliElementByKey = function (e, t) {
            document.querySelectors(e);
            return null;
          }),
          (i.exports.findItemElementForList = function (e) {
            if (!e || -1 < e.className.indexOf("prism-setting-item")) return e;
            var t = e.parentElement;
            return t && (e = i.exports.findItemElementForList(t)), e;
          });
      },
      {},
    ],
    117: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../lib/dom"),
          f = e("../../lib/util"),
          n = e("../../lang/index"),
          _ = e("../../player/base/event/eventtype"),
          a = e("./util"),
          s = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                this.addClass(t.className || "prism-snapshot-btn");
            },
            createEl: function () {
              return r.prototype.createEl.call(this, "div");
            },
            bindEvent: function () {
              var h = this;
              this._player.on(_.Private.Snapshot_Hide, function () {
                o.css(h._el, "display", "none");
              }),
                a.registerTooltipEvent.call(this, this.el(), n.get("Snapshot")),
                this.on("click", function () {
                  h.trigger(_.Player.Snapshoting);
                  var e = document.createElement("canvas"),
                    t = h._player.tag,
                    i = t.videoWidth,
                    r = t.videoHeight,
                    o = h._player._getSanpshotMatric();
                  (e.width = o.width || i), (e.height = o.height || r);
                  var n = h._player.getCurrentTime(),
                    a = e.getContext("2d");
                  a.save();
                  var s = h._player.getImage();
                  "vertical" == s
                    ? (a.translate(0, e.height), a.scale(1, -1))
                    : "horizon" == s &&
                      (a.translate(e.width, 0), a.scale(-1, 1)),
                    a.drawImage(t, 0, 0, i, r),
                    a.restore(),
                    g(a, h._player.getOptions());
                  var l = "",
                    u = "";
                  try {
                    l = e.toDataURL("image/jpeg", o.rate || 1);
                  } catch (e) {
                    u = e;
                  }
                  var c = "",
                    d = "",
                    p = "";
                  l &&
                    ((d = (c = l).substr(c.indexOf(",") + 1)),
                    (p = f.toBinary(d))),
                    h.trigger(_.Player.Snapshoted, {
                      time: n,
                      base64: c,
                      binary: p,
                      error: u,
                    });
                });
            },
          }),
          g = function (e, t) {
            var i = t.snapshotWatermark;
            i &&
              i.text &&
              ((e.font = i.font),
              i.fillColor &&
                ((e.fillStyle = i.fillColor),
                e.fillText(i.text, i.left, i.top)),
              i.strokeColor &&
                ((e.strokeStyle = i.strokeColor),
                e.strokeText(i.text, i.left, i.top)),
              e.stroke());
          };
        t.exports = s;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/util": 33,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
        "./util": 121,
      },
    ],
    118: [
      function (e, t, i) {
        var r = e("../component"),
          c = (e("../../lib/util"), e("../../lib/dom")),
          o = e("../../lib/event"),
          n =
            (e("../../lib/ua"),
            e("../../lang/index"),
            e("../../player/base/event/eventtype")),
          a = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-thumbnail"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (e.innerHTML = "<img></img><span></span>"), e;
            },
            bindEvent: function () {
              var u = this;
              o.on(this._el, "mousemove", function (e) {
                e.preventDefault();
              }),
                o.on(this._el, "touchmove", function (e) {
                  e.preventDefault();
                }),
                u._player.on(n.Private.ThumbnailLoaded, function (e) {
                  var t = e.paramData;
                  if (t && 0 < t.length) {
                    var i = u._player._thumbnailService.makeUrl(t[0].text);
                    u._player.log("THUMBNAILSTART", {
                      tu: encodeURIComponent(i),
                    });
                    var r = new Date().getTime();
                    if (t[0].isBig)
                      c.css(u.el(), "background", "url(" + i + ")"),
                        c.css(u.el(), "width", t[0].w + "px"),
                        c.css(u.el(), "height", t[0].h + "px"),
                        u._player.log("THUMBNAILCOMPLETE", {
                          ftt: new Date().getTime() - r,
                        });
                    else {
                      var o = document.querySelector("#" + u.id() + " img");
                      (o.onload = function () {
                        var e = o.width,
                          t = o.height;
                        c.css(u.el(), "width", e + "px"),
                          c.css(u.el(), "height", t + "px"),
                          u._player.log("THUMBNAILCOMPLETE", {
                            ftt: new Date().getTime() - r,
                          });
                      }),
                        (o.src = i);
                    }
                  }
                }),
                u._player.on(n.Private.ThumbnailShow, function (l) {
                  u._thumbnailShowHanlde &&
                    clearTimeout(u._thumbnailShowHanlde),
                    (u._thumbnailShowHanlde = setTimeout(function () {
                      var e = document.querySelector("#" + u.id() + " span"),
                        t = l.paramData;
                      if (((e.innerText = t.formatTime), t)) {
                        var i = u._player._thumbnailService.findAvailableCue(
                          t.time
                        );
                        if (i)
                          if (i.isBig) {
                            var r = u._player._thumbnailService.makeUrl(i.text);
                            c.css(u.el(), "background", "url(" + r + ")"),
                              i.w,
                              i.h;
                            var o = -1 * i.x + "px " + -1 * i.y + "px";
                            c.css(u.el(), "background-position", o);
                          } else {
                            var n = document.querySelector(
                              "#" + u.id() + " img"
                            );
                            (r = u._player._thumbnailService.makeUrl(i.text)),
                              n.src != r && (n.src = r);
                          }
                        else
                          c.css(u.el(), "border", "none"),
                            c.css(e, "left", "0px");
                        c.css(u.el(), "display", "block");
                        var a = 0,
                          s = i ? u.el().offsetWidth : e.offsetWidth;
                        (a =
                          t.left + s > t.progressWidth
                            ? t.left - s
                            : (a = t.left - s / 2) < 0
                            ? 0
                            : a),
                          c.css(u.el(), "left", a + "px");
                      }
                    }, 30));
                }),
                u._player.on(n.Private.ThumbnailHide, function (e) {
                  u._thumbnailShowHanlde &&
                    clearTimeout(u._thumbnailShowHanlde),
                    c.css(u.el(), "display", "none");
                });
            },
            _createSamllThumbnail: function () {},
            disposeUI: function () {
              this._thumbnailShowHanlde &&
                (clearTimeout(this._thumbnailShowHanlde),
                (this._thumbnailShowHanlde = null));
            },
          });
        t.exports = a;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../lib/ua": 31,
        "../../lib/util": 33,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    119: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../lib/util"),
          n = e("../../player/base/event/eventtype"),
          a = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className
                  ? t.className
                  : "prism-time-display"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (
                (e.innerHTML =
                  '<span class="current-time">00:00</span> <span class="time-bound">/</span> <span class="duration">00:00</span>'),
                e
              );
            },
            bindEvent: function () {
              var i = this;
              this._player.on(n.Video.DurationChange, function () {
                var e = o.formatTime(i._player.getDisplayDuration());
                e
                  ? ((document.querySelector(
                      "#" + i.id() + " .time-bound"
                    ).style.display = "inline"),
                    (document.querySelector(
                      "#" + i.id() + " .duration"
                    ).style.display = "inline"),
                    (document.querySelector(
                      "#" + i.id() + " .duration"
                    ).innerText = e))
                  : ((document.querySelector(
                      "#" + i.id() + " .duration"
                    ).style.display = "none"),
                    (document.querySelector(
                      "#" + i.id() + " .time-bound"
                    ).style.display = "none"));
              }),
                this._player.on(n.Video.TimeUpdate, function () {
                  var e = i._player.getCurrentTime(),
                    t = o.formatTime(e);
                  document.querySelector("#" + i.id() + " .current-time") &&
                    (t
                      ? ((document.querySelector(
                          "#" + i.id() + " .current-time"
                        ).style.display = "inline"),
                        (document.querySelector(
                          "#" + i.id() + " .current-time"
                        ).innerText = t))
                      : (document.querySelector(
                          "#" + i.id() + " .current-time"
                        ).style.display = "none"));
                });
            },
          });
        t.exports = a;
      },
      {
        "../../lib/util": 33,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    120: [
      function (e, t, i) {
        var r = e("../component"),
          s = e("../../lib/dom"),
          o = e("../../player/base/event/eventtype"),
          n = r.extend({
            init: function (e, t) {
              r.call(this, e, t),
                (this.className = t.className ? t.className : "prism-tooltip"),
                this.addClass(this.className);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "p");
              return (e.innerText = "\u63d0\u793a\u4fe1\u606f"), e;
            },
            bindEvent: function () {
              var a = this;
              a._player.on(o.Private.TooltipShow, function (e) {
                var t = document.querySelector("#" + a.id()),
                  i = e.paramData;
                (t.innerText = i.text), s.css(t, "display", "block");
                var r = t.offsetWidth,
                  o = document.querySelector(
                    "#" + a._player.id() + " .prism-controlbar"
                  );
                if (o) {
                  var n = o.offsetWidth;
                  i.left + r > n
                    ? s.css(t, "left", n - r + "px")
                    : s.css(t, "left", i.left - (r - i.width) / 2 + "px");
                }
              }),
                a._player.on(o.Private.TooltipHide, function (e) {
                  var t = document.querySelector("#" + a.id());
                  s.css(t, "display", "none");
                });
            },
          });
        t.exports = n;
      },
      {
        "../../lib/dom": 18,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
      },
    ],
    121: [
      function (e, t, i) {
        var r = e("../../lib/event"),
          s = e("../../player/base/event/eventtype");
        (t.exports.registerTooltipEvent = function (e, o) {
          var n = this,
            a = function () {
              n._controlbarTooltipHandler &&
                (clearTimeout(n._controlbarTooltipHandler),
                (n._controlbarTooltipHandler = null));
            };
          r.on(this.el(), "mouseover", function (e) {
            a(),
              (n._controlbarTooltipHandler = setTimeout(function () {
                n._player.trigger(s.Private.TooltipHide);
              }, 4e3));
            var t = n.el().offsetLeft,
              i = n.el().offsetWidth,
              r = o;
            "function" == typeof r && (r = o.call(this)),
              n._player.trigger(s.Private.TooltipShow, {
                left: t,
                width: i,
                text: r,
              });
          }),
            r.on(this.el(), "mouseout", function () {
              a(), n._player.trigger(s.Private.TooltipHide);
            });
        }),
          (t.exports.throttle = function (i, r) {
            var o = Date.now();
            return function () {
              var e = arguments,
                t = Date.now();
              r <= t - o && (i(e), (o = t));
            };
          });
      },
      { "../../lib/event": 19, "../../player/base/event/eventtype": 43 },
    ],
    122: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../lib/dom"),
          n = e("../../lib/event"),
          a = e("../../player/base/event/eventtype"),
          s = e("./util"),
          l = e("../../lang/index"),
          u = e("./volumecontrol"),
          c = r.extend({
            init: function (e, t) {
              r.call(this, e, t), this.addClass(t.className || "prism-volume");
              var i = new u(e, t);
              e.addChild(i, t);
            },
            createEl: function () {
              var e = r.prototype.createEl.call(this, "div");
              return (
                (e.innerHTML =
                  '<div class="volume-icon"><div class="short-horizontal"></div><div class="long-horizontal"></div></div>'),
                e
              );
            },
            bindEvent: function () {
              var i = this;
              (this.icon = document.querySelector(
                "#" + i.id() + "  .volume-icon"
              )),
                s.registerTooltipEvent.call(this, this.el(), function () {
                  return i._player.muted() || 0 == i._player.getVolume()
                    ? l.get("Muted")
                    : l.get("Volume");
                }),
                n.on(this.icon, "click", function (e) {
                  var t = i.el().offsetLeft;
                  i._player.trigger(a.Private.SettingListHide),
                    i._player.trigger(a.Private.SelectorHide),
                    i._player.trigger(a.Private.VolumeVisibilityChange, t),
                    i._player.trigger(a.Private.MarkerTextHide);
                });
              var e = document.querySelector(
                  "#" + i.id() + "  .long-horizontal"
                ),
                t = document.querySelector(
                  "#" + i.id() + "  .short-horizontal"
                );
              n.on(this.el(), "mouseover", function () {
                o.removeClass(e, "volume-hover-animation"),
                  setTimeout(function () {
                    o.addClass(e, "volume-hover-animation");
                  }),
                  setTimeout(function () {
                    o.removeClass(e, "volume-hover-animation"),
                      o.addClass(t, "volume-hover-animation"),
                      setTimeout(function () {
                        o.removeClass(t, "volume-hover-animation"),
                          o.addClass(e, "volume-hover-animation");
                      }, 300);
                  }, 300);
              });
            },
          });
        t.exports = c;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
        "./util": 121,
        "./volumecontrol": 123,
      },
    ],
    123: [
      function (e, t, i) {
        var r = e("../component"),
          o = e("../../lib/dom"),
          n = e("../../lib/event"),
          a = e("../../player/base/event/eventtype"),
          s =
            (e("./util"),
            e("../../lang/index"),
            r.extend({
              init: function (e, t) {
                r.call(this, e, t),
                  this.addClass(t.className || "prism-volume-control"),
                  (this._shown = !1);
              },
              createEl: function () {
                var e = r.prototype.createEl.call(this, "div");
                return (
                  (e.innerHTML =
                    '<div class="volume-range"><div class="volume-value"></div><div class="volume-cursor"></div></div>'),
                  e
                );
              },
              bindEvent: function () {
                var r = this;
                (this.icon = document.querySelector(
                  "#" + r._player.id() + "  .volume-icon"
                )),
                  (this.control = document.querySelector("#" + r.id())),
                  (this.volumnValue = document.querySelector(
                    "#" + r.id() + "  .volume-value"
                  )),
                  (this.volumnRange = document.querySelector(
                    "#" + r.id() + "  .volume-range"
                  )),
                  (this.volumnCursor = document.querySelector(
                    "#" + r.id() + "  .volume-cursor"
                  )),
                  this._player.on(
                    a.Private.VolumeVisibilityChange,
                    function (e) {
                      var t = e.paramData;
                      if (!r._shown && t) {
                        var i = r._player.getVolume();
                        r._setVolumnUI(i),
                          o.css(r.control, "display", "block"),
                          t && o.css(r.control, "left", t - 5 + "px"),
                          (r._shown = !0);
                      } else
                        o.css(r.control, "display", "none"), (r._shown = !1);
                    }
                  ),
                  n.on(this.volumnRange, "click", function (e) {
                    var t = o.getPointerPosition(r.volumnRange, e).y;
                    t < 0 ||
                      1 < t ||
                      (t < 0 && (t = 0),
                      1 < t && (t = 1),
                      r._setVolumnUI(t),
                      r._setMuteUI(t),
                      r._player.setVolume(t));
                  }),
                  n.on(this._player.tag, "click", function (e) {
                    e &&
                      e.target == e.currentTarget &&
                      o.css(r.control, "display", "none");
                  }),
                  n.on(this._player.tag, "touchstart", function (e) {
                    e &&
                      e.target == e.currentTarget &&
                      o.css(r.control, "display", "none");
                  }),
                  n.on(this.volumnCursor, "mousedown", function (e) {
                    r._onMouseDown(e);
                  }),
                  n.on(this.volumnCursor, "touchstart", function (e) {
                    r._onMouseDown(e);
                  }),
                  this._player.on(a.Private.VolumnChanged, function (e) {
                    var t = e.paramData;
                    -1 < t && r._setVolumnUI(t), r._setMuteUI(t);
                  }),
                  n.on(this.control, "mouseleave", function () {
                    o.css(r.control, "display", "none"), (r._shown = !1);
                  }),
                  n.on(this.control, "mouseover", function () {
                    o.addClass(r.control, "hover");
                  }),
                  (r._rangeBottom = r._getBottom());
              },
              _getBottom: function () {
                if (window.getComputedStyle) {
                  var e = window
                    .getComputedStyle(this.volumnRange, null)
                    .getPropertyValue("bottom");
                  return parseFloat(e);
                }
                return 26;
              },
              _onMouseDown: function (e) {
                var t = this;
                e.preventDefault(),
                  n.on(this.control, "mousemove", function (e) {
                    t._onMouseMove(e);
                  }),
                  n.on(this.control, "touchmove", function (e) {
                    t._onMouseMove(e);
                  }),
                  n.on(this._player.tag, "mouseup", function (e) {
                    t._onMouseUp(e);
                  }),
                  n.on(this._player.tag, "touchend", function (e) {
                    t._onMouseUp(e);
                  }),
                  n.on(this.control, "mouseup", function (e) {
                    t._onMouseUp(e);
                  }),
                  n.on(this.control, "touchend", function (e) {
                    t._onMouseUp(e);
                  });
              },
              _onMouseUp: function (e) {
                if (
                  (e.preventDefault(),
                  this._offEvent(),
                  this.volumnRange.offsetHeight)
                ) {
                  var t = (
                    this.volumnValue.offsetHeight /
                    this.volumnRange.offsetHeight
                  ).toFixed(2);
                  this._player.setVolume(t), this._setMuteUI(t);
                }
              },
              _onMouseMove: function (e) {
                e.preventDefault();
                var t = o.getPointerPosition(this.volumnRange, e).y;
                t < 0 ||
                  1 < t ||
                  (t < 0 && (t = 0), 1 < t && (t = 1), this._setVolumnUI(t));
              },
              _getPosition: function (e) {
                for (var t = this.volumnRange, i = 0; (t = t.offsetParent); )
                  i += t.offsetTop;
                var r = this.volumnRange.offsetHeight,
                  o = this.volumnCursor.offsetHeight,
                  n = e.touches ? e.touches[0].pageY : e.pageY;
                return (
                  r < n - i && (n = e.clientY),
                  (r - (n - i) + o) / (r = this.volumnRange.offsetHeight)
                );
              },
              _offEvent: function () {
                n.off(this._player.tag, "mouseup"),
                  n.off(this._player.tag, "touchend"),
                  n.off(this.control, "mousemove"),
                  n.off(this.control, "touchmove"),
                  n.off(this.control, "mouseup"),
                  n.off(this.control, "touchend");
              },
              _setMuteUI: function (e) {
                isNaN(e) ||
                  (0 == e || -1 == e
                    ? o.addClass(this.icon, "mute")
                    : o.removeClass(this.icon, "mute"));
              },
              _setVolumnUI: function (e) {
                isNaN(e) ||
                  (o.css(this.volumnValue, "height", 100 * e + "%"),
                  1 == e && (e = 0.99),
                  o.css(this.volumnCursor, "bottom", 100 * e + "%"));
              },
            }));
        t.exports = s;
      },
      {
        "../../lang/index": 11,
        "../../lib/dom": 18,
        "../../lib/event": 19,
        "../../player/base/event/eventtype": 43,
        "../component": 94,
        "./util": 121,
      },
    ],
    124: [
      function (e, t, i) {
        t.exports = {
          H5Loading: e("./component/h5-loading"),
          bigPlayButton: e("./component/big-play-button"),
          controlBar: e("./component/controlbar"),
          progress: e("./component/progress"),
          playButton: e("./component/play-button"),
          liveDisplay: e("./component/live-display"),
          timeDisplay: e("./component/time-display"),
          fullScreenButton: e("./component/fullscreen-button"),
          volume: e("./component/volume"),
          snapshot: e("./component/snapshot"),
          errorDisplay: e("./component/error-display"),
          infoDisplay: e("./component/info-display"),
          liveShiftProgress: e("../commonui/liveshiftprogress"),
          liveShiftTimeDisplay: e("../commonui/livetimedisplay"),
          setting: e("./component/setting/button"),
          subtitle: e("./component/cc-button"),
          thumbnail: e("./component/thumbnail"),
          tooltip: e("./component/tooltip"),
        };
      },
      {
        "../commonui/liveshiftprogress": 3,
        "../commonui/livetimedisplay": 4,
        "./component/big-play-button": 95,
        "./component/cc-button": 96,
        "./component/controlbar": 97,
        "./component/error-display": 99,
        "./component/fullscreen-button": 100,
        "./component/h5-loading": 101,
        "./component/info-display": 102,
        "./component/live-display": 103,
        "./component/play-button": 105,
        "./component/progress": 106,
        "./component/setting/button": 110,
        "./component/snapshot": 117,
        "./component/thumbnail": 118,
        "./component/time-display": 119,
        "./component/tooltip": 120,
        "./component/volume": 122,
      },
    ],
    125: [
      function (e, t, i) {
        var r, o;
        (r = this),
          (o = function () {
            var c,
              i,
              e,
              t,
              r,
              d,
              o,
              n,
              a,
              s,
              l,
              u,
              p =
                p ||
                ((c = Math),
                (i =
                  Object.create ||
                  (function () {
                    function i() {}
                    return function (e) {
                      var t;
                      return (
                        (i.prototype = e),
                        (t = new i()),
                        (i.prototype = null),
                        t
                      );
                    };
                  })()),
                (t = (e = {}).lib = {}),
                (r = t.Base =
                  {
                    extend: function (e) {
                      var t = i(this);
                      return (
                        e && t.mixIn(e),
                        (t.hasOwnProperty("init") && this.init !== t.init) ||
                          (t.init = function () {
                            t.$super.init.apply(this, arguments);
                          }),
                        ((t.init.prototype = t).$super = this),
                        t
                      );
                    },
                    create: function () {
                      var e = this.extend();
                      return e.init.apply(e, arguments), e;
                    },
                    init: function () {},
                    mixIn: function (e) {
                      for (var t in e) e.hasOwnProperty(t) && (this[t] = e[t]);
                      e.hasOwnProperty("toString") &&
                        (this.toString = e.toString);
                    },
                    clone: function () {
                      return this.init.prototype.extend(this);
                    },
                  }),
                (d = t.WordArray =
                  r.extend({
                    init: function (e, t) {
                      (e = this.words = e || []),
                        (this.sigBytes = null != t ? t : 4 * e.length);
                    },
                    toString: function (e) {
                      return (e || n).stringify(this);
                    },
                    concat: function (e) {
                      var t = this.words,
                        i = e.words,
                        r = this.sigBytes,
                        o = e.sigBytes;
                      if ((this.clamp(), r % 4))
                        for (var n = 0; n < o; n++) {
                          var a = (i[n >>> 2] >>> (24 - (n % 4) * 8)) & 255;
                          t[(r + n) >>> 2] |= a << (24 - ((r + n) % 4) * 8);
                        }
                      else
                        for (n = 0; n < o; n += 4)
                          t[(r + n) >>> 2] = i[n >>> 2];
                      return (this.sigBytes += o), this;
                    },
                    clamp: function () {
                      var e = this.words,
                        t = this.sigBytes;
                      (e[t >>> 2] &= 4294967295 << (32 - (t % 4) * 8)),
                        (e.length = c.ceil(t / 4));
                    },
                    clone: function () {
                      var e = r.clone.call(this);
                      return (e.words = this.words.slice(0)), e;
                    },
                    random: function (e) {
                      for (
                        var t,
                          i = [],
                          r = function (t) {
                            t = t;
                            var i = 987654321,
                              r = 4294967295;
                            return function () {
                              var e =
                                (((i = (36969 * (65535 & i) + (i >> 16)) & r) <<
                                  16) +
                                  (t = (18e3 * (65535 & t) + (t >> 16)) & r)) &
                                r;
                              return (
                                (e /= 4294967296),
                                (e += 0.5) * (0.5 < c.random() ? 1 : -1)
                              );
                            };
                          },
                          o = 0;
                        o < e;
                        o += 4
                      ) {
                        var n = r(4294967296 * (t || c.random()));
                        (t = 987654071 * n()), i.push((4294967296 * n()) | 0);
                      }
                      return new d.init(i, e);
                    },
                  })),
                (o = e.enc = {}),
                (n = o.Hex =
                  {
                    stringify: function (e) {
                      for (
                        var t = e.words, i = e.sigBytes, r = [], o = 0;
                        o < i;
                        o++
                      ) {
                        var n = (t[o >>> 2] >>> (24 - (o % 4) * 8)) & 255;
                        r.push((n >>> 4).toString(16)),
                          r.push((15 & n).toString(16));
                      }
                      return r.join("");
                    },
                    parse: function (e) {
                      for (var t = e.length, i = [], r = 0; r < t; r += 2)
                        i[r >>> 3] |=
                          parseInt(e.substr(r, 2), 16) << (24 - (r % 8) * 4);
                      return new d.init(i, t / 2);
                    },
                  }),
                (a = o.Latin1 =
                  {
                    stringify: function (e) {
                      for (
                        var t = e.words, i = e.sigBytes, r = [], o = 0;
                        o < i;
                        o++
                      ) {
                        var n = (t[o >>> 2] >>> (24 - (o % 4) * 8)) & 255;
                        r.push(String.fromCharCode(n));
                      }
                      return r.join("");
                    },
                    parse: function (e) {
                      for (var t = e.length, i = [], r = 0; r < t; r++)
                        i[r >>> 2] |=
                          (255 & e.charCodeAt(r)) << (24 - (r % 4) * 8);
                      return new d.init(i, t);
                    },
                  }),
                (s = o.Utf8 =
                  {
                    stringify: function (e) {
                      try {
                        return decodeURIComponent(escape(a.stringify(e)));
                      } catch (e) {
                        throw new Error("Malformed UTF-8 data");
                      }
                    },
                    parse: function (e) {
                      return a.parse(unescape(encodeURIComponent(e)));
                    },
                  }),
                (l = t.BufferedBlockAlgorithm =
                  r.extend({
                    reset: function () {
                      (this._data = new d.init()), (this._nDataBytes = 0);
                    },
                    _append: function (e) {
                      "string" == typeof e && (e = s.parse(e)),
                        this._data.concat(e),
                        (this._nDataBytes += e.sigBytes);
                    },
                    _process: function (e) {
                      var t = this._data,
                        i = t.words,
                        r = t.sigBytes,
                        o = this.blockSize,
                        n = r / (4 * o),
                        a =
                          (n = e
                            ? c.ceil(n)
                            : c.max((0 | n) - this._minBufferSize, 0)) * o,
                        s = c.min(4 * a, r);
                      if (a) {
                        for (var l = 0; l < a; l += o)
                          this._doProcessBlock(i, l);
                        var u = i.splice(0, a);
                        t.sigBytes -= s;
                      }
                      return new d.init(u, s);
                    },
                    clone: function () {
                      var e = r.clone.call(this);
                      return (e._data = this._data.clone()), e;
                    },
                    _minBufferSize: 0,
                  })),
                (t.Hasher = l.extend({
                  cfg: r.extend(),
                  init: function (e) {
                    (this.cfg = this.cfg.extend(e)), this.reset();
                  },
                  reset: function () {
                    l.reset.call(this), this._doReset();
                  },
                  update: function (e) {
                    return this._append(e), this._process(), this;
                  },
                  finalize: function (e) {
                    return e && this._append(e), this._doFinalize();
                  },
                  blockSize: 16,
                  _createHelper: function (i) {
                    return function (e, t) {
                      return new i.init(t).finalize(e);
                    };
                  },
                  _createHmacHelper: function (i) {
                    return function (e, t) {
                      return new u.HMAC.init(i, t).finalize(e);
                    };
                  },
                })),
                (u = e.algo = {}),
                e);
            return p;
          }),
          "object" == typeof i
            ? (t.exports = i = o())
            : "function" == typeof define && define.amd
            ? define([], o)
            : (r.CryptoJS = o());
      },
      {},
    ],
    126: [
      function (e, t, i) {
        var r, o;
        (r = this),
          (o = function (e) {
            var t, l;
            return (
              (l = (t = e).lib.WordArray),
              (t.enc.Base64 = {
                stringify: function (e) {
                  var t = e.words,
                    i = e.sigBytes,
                    r = this._map;
                  e.clamp();
                  for (var o = [], n = 0; n < i; n += 3)
                    for (
                      var a =
                          (((t[n >>> 2] >>> (24 - (n % 4) * 8)) & 255) << 16) |
                          (((t[(n + 1) >>> 2] >>> (24 - ((n + 1) % 4) * 8)) &
                            255) <<
                            8) |
                          ((t[(n + 2) >>> 2] >>> (24 - ((n + 2) % 4) * 8)) &
                            255),
                        s = 0;
                      s < 4 && n + 0.75 * s < i;
                      s++
                    )
                      o.push(r.charAt((a >>> (6 * (3 - s))) & 63));
                  var l = r.charAt(64);
                  if (l) for (; o.length % 4; ) o.push(l);
                  return o.join("");
                },
                parse: function (e) {
                  var t = e.length,
                    i = this._map,
                    r = this._reverseMap;
                  if (!r) {
                    r = this._reverseMap = [];
                    for (var o = 0; o < i.length; o++) r[i.charCodeAt(o)] = o;
                  }
                  var n = i.charAt(64);
                  if (n) {
                    var a = e.indexOf(n);
                    -1 !== a && (t = a);
                  }
                  return (function (e, t, i) {
                    for (var r = [], o = 0, n = 0; n < t; n++)
                      if (n % 4) {
                        var a = i[e.charCodeAt(n - 1)] << ((n % 4) * 2),
                          s = i[e.charCodeAt(n)] >>> (6 - (n % 4) * 2);
                        (r[o >>> 2] |= (a | s) << (24 - (o % 4) * 8)), o++;
                      }
                    return l.create(r, o);
                  })(e, t, r);
                },
                _map: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
              }),
              e.enc.Base64
            );
          }),
          "object" == typeof i
            ? (t.exports = i = o(e("./core")))
            : "function" == typeof define && define.amd
            ? define(["./core"], o)
            : o(r.CryptoJS);
      },
      { "./core": 125 },
    ],
    127: [
      function (e, t, i) {
        var r, o;
        (r = this),
          (o = function (e) {
            return e.enc.Utf8;
          }),
          "object" == typeof i
            ? (t.exports = i = o(e("./core")))
            : "function" == typeof define && define.amd
            ? define(["./core"], o)
            : o(r.CryptoJS);
      },
      { "./core": 125 },
    ],
    128: [
      function (e, t, i) {
        var r, o;
        (r = this),
          (o = function (e) {
            return e.HmacSHA1;
          }),
          "object" == typeof i
            ? (t.exports = i = o(e("./core"), e("./sha1"), e("./hmac")))
            : "function" == typeof define && define.amd
            ? define(["./core", "./sha1", "./hmac"], o)
            : o(r.CryptoJS);
      },
      { "./core": 125, "./hmac": 129, "./sha1": 130 },
    ],
    129: [
      function (e, t, i) {
        var r, o;
        (r = this),
          (o = function (e) {
            var t, i, u;
            (i = (t = e).lib.Base),
              (u = t.enc.Utf8),
              (t.algo.HMAC = i.extend({
                init: function (e, t) {
                  (e = this._hasher = new e.init()),
                    "string" == typeof t && (t = u.parse(t));
                  var i = e.blockSize,
                    r = 4 * i;
                  t.sigBytes > r && (t = e.finalize(t)), t.clamp();
                  for (
                    var o = (this._oKey = t.clone()),
                      n = (this._iKey = t.clone()),
                      a = o.words,
                      s = n.words,
                      l = 0;
                    l < i;
                    l++
                  )
                    (a[l] ^= 1549556828), (s[l] ^= 909522486);
                  (o.sigBytes = n.sigBytes = r), this.reset();
                },
                reset: function () {
                  var e = this._hasher;
                  e.reset(), e.update(this._iKey);
                },
                update: function (e) {
                  return this._hasher.update(e), this;
                },
                finalize: function (e) {
                  var t = this._hasher,
                    i = t.finalize(e);
                  return t.reset(), t.finalize(this._oKey.clone().concat(i));
                },
              }));
          }),
          "object" == typeof i
            ? (t.exports = i = o(e("./core")))
            : "function" == typeof define && define.amd
            ? define(["./core"], o)
            : o(r.CryptoJS);
      },
      { "./core": 125 },
    ],
    130: [
      function (e, t, i) {
        var r, o;
        (r = this),
          (o = function (e) {
            var t, i, r, o, n, d, a;
            return (
              (i = (t = e).lib),
              (r = i.WordArray),
              (o = i.Hasher),
              (n = t.algo),
              (d = []),
              (a = n.SHA1 =
                o.extend({
                  _doReset: function () {
                    this._hash = new r.init([
                      1732584193, 4023233417, 2562383102, 271733878, 3285377520,
                    ]);
                  },
                  _doProcessBlock: function (e, t) {
                    for (
                      var i = this._hash.words,
                        r = i[0],
                        o = i[1],
                        n = i[2],
                        a = i[3],
                        s = i[4],
                        l = 0;
                      l < 80;
                      l++
                    ) {
                      if (l < 16) d[l] = 0 | e[t + l];
                      else {
                        var u = d[l - 3] ^ d[l - 8] ^ d[l - 14] ^ d[l - 16];
                        d[l] = (u << 1) | (u >>> 31);
                      }
                      var c = ((r << 5) | (r >>> 27)) + s + d[l];
                      (c +=
                        l < 20
                          ? 1518500249 + ((o & n) | (~o & a))
                          : l < 40
                          ? 1859775393 + (o ^ n ^ a)
                          : l < 60
                          ? ((o & n) | (o & a) | (n & a)) - 1894007588
                          : (o ^ n ^ a) - 899497514),
                        (s = a),
                        (a = n),
                        (n = (o << 30) | (o >>> 2)),
                        (o = r),
                        (r = c);
                    }
                    (i[0] = (i[0] + r) | 0),
                      (i[1] = (i[1] + o) | 0),
                      (i[2] = (i[2] + n) | 0),
                      (i[3] = (i[3] + a) | 0),
                      (i[4] = (i[4] + s) | 0);
                  },
                  _doFinalize: function () {
                    var e = this._data,
                      t = e.words,
                      i = 8 * this._nDataBytes,
                      r = 8 * e.sigBytes;
                    return (
                      (t[r >>> 5] |= 128 << (24 - (r % 32))),
                      (t[14 + (((64 + r) >>> 9) << 4)] = Math.floor(
                        i / 4294967296
                      )),
                      (t[15 + (((64 + r) >>> 9) << 4)] = i),
                      (e.sigBytes = 4 * t.length),
                      this._process(),
                      this._hash
                    );
                  },
                  clone: function () {
                    var e = o.clone.call(this);
                    return (e._hash = this._hash.clone()), e;
                  },
                })),
              (t.SHA1 = o._createHelper(a)),
              (t.HmacSHA1 = o._createHmacHelper(a)),
              e.SHA1
            );
          }),
          "object" == typeof i
            ? (t.exports = i = o(e("./core")))
            : "function" == typeof define && define.amd
            ? define(["./core"], o)
            : o(r.CryptoJS);
      },
      { "./core": 125 },
    ],
  },
  {},
  [6]
);
