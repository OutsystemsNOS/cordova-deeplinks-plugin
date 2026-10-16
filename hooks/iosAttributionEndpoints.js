const path = require("path");
const fs = require("fs");
const plist = require("plist");

// Info.plist keys controlled by IOS_ATTRIBUTION_REPORT_ENDPOINT / IOS_ATTRIBUTION_COPY_ENDPOINT.
// plugin.xml always injects them (config-file cannot be conditional), so they are
// removed here when the variable was omitted (default "none") or is otherwise invalid.
var ATTRIBUTION_KEYS = [
  "NSAdvertisingAttributionReportEndpoint",
  "AttributionCopyEndpoint",
];

var IGNORED_DIRS = ["Pods", "CordovaLib", "build", "www", "platform_www", "node_modules"];

var INVALID_VALUES = ["", "none", "undefined", "null", "false"];

function isValidEndpoint(value) {
  if (typeof value !== "string") return false;
  var normalized = value.trim();
  if (normalized.indexOf("$") !== -1) return false;
  return INVALID_VALUES.indexOf(normalized.toLowerCase()) === -1;
}

function cleanInfoPlist(filePath) {
  var obj;
  try {
    obj = plist.parse(fs.readFileSync(filePath, "utf8"));
  } catch (e) {
    return;
  }
  if (!obj || typeof obj !== "object" || Array.isArray(obj)) return;

  var removed = ATTRIBUTION_KEYS.filter(function (key) {
    if (Object.prototype.hasOwnProperty.call(obj, key) && !isValidEndpoint(obj[key])) {
      delete obj[key];
      return true;
    }
    return false;
  });

  if (removed.length > 0) {
    fs.writeFileSync(filePath, plist.build(obj, { indent: "\t", offset: -1 }), "utf8");
    console.log(
      "[CustomDeeplinksPlugin] Removed " + removed.join(", ") + " from " + filePath
    );
  }
}

function walk(dir) {
  var entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch (e) {
    return;
  }
  entries.forEach(function (entry) {
    var fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (IGNORED_DIRS.indexOf(entry.name) === -1) walk(fullPath);
    } else if (entry.isFile() && entry.name.endsWith("Info.plist")) {
      cleanInfoPlist(fullPath);
    }
  });
}

module.exports = function (context) {
  var projectRoot = context.opts.cordova.project
    ? context.opts.cordova.project.root
    : context.opts.projectRoot;

  var iosPath = path.join(projectRoot, "platforms", "ios");
  if (!fs.existsSync(iosPath)) return;

  walk(iosPath);
};
