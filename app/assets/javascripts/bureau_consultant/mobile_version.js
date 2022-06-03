if (!String.prototype.startsWith) {
  String.prototype.startsWith = function (search, pos) {
    return this.substr(!pos || pos < 0 ? 0 : +pos, search.length) === search;
  };
}

function isMobileVersion() {
  return window.location.pathname.startsWith('/m/')
}

function rootPathByVarient() {
  return isMobileVersion() ? '/m' : ''
}