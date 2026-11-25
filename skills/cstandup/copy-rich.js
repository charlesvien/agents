ObjC.import('AppKit')

function run(argv) {
    const contents = $.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null)
    if (contents.isNil()) {
        throw new Error(`cannot read ${argv[0]}`)
    }

    const html = `<meta charset="utf-8">${contents.js}`
    const data = $(html).dataUsingEncoding($.NSUTF8StringEncoding)
    const options = $({ CharacterEncoding: $.NSUTF8StringEncoding })
    const attributed = $.NSAttributedString.alloc.initWithHTMLOptionsDocumentAttributes(data, options, null)

    const pasteboard = $.NSPasteboard.generalPasteboard
    pasteboard.clearContents
    pasteboard.setStringForType($(html), 'public.html')
    pasteboard.setStringForType(attributed.string, 'public.utf8-plain-text')

    return 'copied as rich text'
}
