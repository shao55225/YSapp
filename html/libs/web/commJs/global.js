// 关闭广告
function cusCloseAds(ele) {
  $(`#${ele}`).hide();
}


/* 存储 */
//写cookies
var TokenKey = "Token";
function temSetCookie(name, value) {
  var Days = 30;
  var exp = new Date();
  exp.setTime(exp.getTime() + Days * 24 * 60 * 60 * 1000);
  document.cookie =
    name + "=" + escape(value) + ";expires=" + exp.toGMTString() + ";path=/";
}
function temSetToken(token) {
  return temSetCookie(TokenKey, token);
}
//删除cookies
function temDelCookie(name) {
  var exp = new Date();
  exp.setTime(exp.getTime() - 1);
  var cval = temGetCookie(name);
  if (cval != null)
    document.cookie =
      name + "=" + cval + ";expires=" + exp.toGMTString() + ";path=/";
}
function temRemoveToken() {
  return temDelCookie(TokenKey);
  // return window.sessionStorage.removeItem(TokenKey);
}
// 7.是否boolean
const isBoolean = (o) => {
  return Object.prototype.toString.call(o).slice(8, -1) === "Boolean";
};
// 11.是否对象
const isObj = (o) => {
  return Object.prototype.toString.call(o).slice(8, -1) === "Object";
};
// 12.是否数组
const isArray = (o) => {
  return Object.prototype.toString.call(o).slice(8, -1) === "Array";
};
var storage = {
  setLocal: (key, value) => {
    if (isArray(value) || isObj(value) || isBoolean(value)) {
      window.localStorage.setItem(key, JSON.stringify(value));
    } else {
      window.localStorage.setItem(key, value);
    }
  },
  getLocal: (key) => {
    let value = window.localStorage.getItem(key);
    if (value) {
      return JSON.parse(value);
    } else {
      return value;
    }
  },
  clearOneLocal: (key) => {
    window.localStorage.removeItem(key);
  },
  clearAllLocal: () => {
    // indexDBStore 不清除
    const indexDBStore = storage.getLocal("indexDBStore");
    window.localStorage.clear();
    storage.setLocal("indexDBStore", JSON.stringify(indexDBStore));
  },
  setSession: (key, value) => {
    //正常设置，会覆盖原值
    if (isArray(value) || isObj(value) || isBoolean(value)) {
      window.sessionStorage.setItem(
        key,
        window.btoa(window.encodeURIComponent(JSON.stringify(value)))
      );
    } else {
      window.sessionStorage.setItem(
        key,
        window.btoa(window.encodeURIComponent(value))
      );
    }
    // window.sessionStorage.setItem(key, JSON.stringify(value))
  },
  appendSession: (key, value) => {
    //追加赋值，不会覆盖原值
    let getValue = window.sessionStorage.getItem(key);
    if (getValue) {
      let oldValue = JSON.parse(getValue);
      let newValue = Object.assign(oldValue, value);
      window.sessionStorage.setItem(key, JSON.stringify(newValue));
    } else {
      window.sessionStorage.setItem(key, JSON.stringify(value));
    }
  },
  getSession: (key) => {
    //需要判断取值格式，如果是string或者undefined，不能JSON.PARSE()
    let value = window.sessionStorage.getItem(key);
    if (!value) {
      return value;
    } else {
      try {
        if (
          isArray(JSON.parse(window.decodeURIComponent(window.atob(value)))) ||
          isObj(JSON.parse(window.decodeURIComponent(window.atob(value))))
        ) {
          return JSON.parse(window.decodeURIComponent(window.atob(value)));
        } else {
          if (window.decodeURIComponent(window.atob(value)) == "true") {
            return true;
          } else if (window.decodeURIComponent(window.atob(value)) == "false") {
            return false;
          } else {
            return window.decodeURIComponent(window.atob(value));
          }
        }
      } catch (e) {
        return window.decodeURIComponent(window.atob(value));
      }
    }
  },
  clearOneSession: (key) => {
    window.sessionStorage.removeItem(key);
  },
  clearAllSession: () => {
    let t1 = storage.getSession("isAdsPop");
    window.sessionStorage.clear();
    t1 ? storage.setSession("isAdsPop", t1) : "";
  },
};
// 获取路由参数
function getRouteParams() {
  // 获取 URL 中的查询字符串（? 后的参数）
  const queryString = window.location.search;
  // 去掉查询字符串中的问号（?）
  const queryParams = queryString.substring(1);
  // 将查询字符串转换为对象
  const params = {};
  // 分割参数并放入对象中
  const paramArr = queryParams.split("&");
  for (let i = 0; i < paramArr.length; i++) {
    const pair = paramArr[i].split("=");
    const key = decodeURIComponent(pair[0]);
    const value = decodeURIComponent(pair[1]);
    key ? (params[key] = value) : "";
  }
  return params;
}
// 中文转义
function temUtf16to8(str) {
  var out, i, len, c;
  out = "";
  len = str.length;
  for (i = 0; i < len; i++) {
    c = str.charCodeAt(i);
    if (c >= 0x0001 && c <= 0x007f) {
      out += str.charAt(i);
    } else if (c > 0x07ff) {
      out += String.fromCharCode(0xe0 | ((c >> 12) & 0x0f));
      out += String.fromCharCode(0x80 | ((c >> 6) & 0x3f));
      out += String.fromCharCode(0x80 | ((c >> 0) & 0x3f));
    } else {
      out += String.fromCharCode(0xc0 | ((c >> 6) & 0x1f));
      out += String.fromCharCode(0x80 | ((c >> 0) & 0x3f));
    }
  }
  return out;
}
