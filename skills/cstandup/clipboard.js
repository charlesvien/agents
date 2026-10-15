ObjC.import("AppKit");

function read(path) {
  return $.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null);
}

function run([htmlPath, textPath]) {
  const pasteboard = $.NSPasteboard.generalPasteboard;
  pasteboard.clearContents;
  pasteboard.setStringForType(read(htmlPath), $.NSPasteboardTypeHTML);
  pasteboard.setStringForType(read(textPath), $.NSPasteboardTypeString);
}
