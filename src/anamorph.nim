type HtmlNodeKind = enum
  element
  text

type StringImpl = (when defined(js): cstring else: string)

type HtmlNode* = ref object
  case kind*: HtmlNodeKind
  of element:
    attrs: seq[(StringImpl, StringImpl)]
    children: seq[HtmlNode]
    tag: StringImpl
  of text:
    content: StringImpl
  

converter hnode*(s: StringImpl): HtmlNode =
  HtmlNode(
    kind: text,
    content: s
  )

proc createElement*(tag: StringImpl, children: openarray[HtmlNode] = [], attrs: openarray[(StringImpl, StringImpl)] = []): HtmlNode =
  HtmlNode(
    kind: element,
    children: @children,
    attrs: @attrs,
    tag: tag
  )


template registerTag*(tn: untyped, tag: StringImpl): untyped =
  proc tn*(children: varargs[HtmlNode]): HtmlNode = createElement(tag, children)
  proc tn*(attrs: openarray[(StringImpl, StringImpl)], children: varargs[HtmlNode]): HtmlNode = createElement(tag, children, attrs)

registerTag(a, "a")
registerTag(tdiv, "div")
registerTag(span, "span")
registerTag(center, "center")
registerTag(h1, "h1")
registerTag(h2, "h2")
registerTag(h3, "h3")
registerTag(h4, "h4")
registerTag(h5, "h5")
registerTag(h6, "h6")
registerTag(label, "label")
registerTag(p, "p")
registerTag(b, "b")
registerTag(i, "i")
registerTag(u, "u")
registerTag(li, "li")
registerTag(ul, "ul")
registerTag(ol, "ol")
registerTag(img, "img")
registerTag(meta, "meta")
registerTag(link, "link")
registerTag(head, "head")
registerTag(body, "body")
registerTag(hr, "hr")
registerTag(br, "br")
registerTag(title, "title")
registerTag(html, "html")
registerTag(iframe, "iframe")
registerTag(input, "input")
registerTag(form, "form")
registerTag(sup, "sup")
registerTag(sub, "sub")
registerTag(button, "button")
registerTag(script, "script")
registerTag(table, "table")
registerTag(thead, "thead")
registerTag(tbody, "tbody")
registerTag(th, "th")
registerTag(tr, "tr")
registerTag(td, "td")
registerTag(style, "style")

proc stringifyAttrs(h: HtmlNode, buffer: var StringImpl) =
  proc stringifyAttr(attr: (StringImpl, StringImpl), buffer: var StringImpl) =
    if attr[1] != "":
      buffer.add(attr[0])
      buffer.add("=\"")
      buffer.add(attr[1])
      buffer.add("\"")
    else: buffer.add(attr[0])

  if h.attrs.len != 0:
    for attr in h.attrs:
      buffer.add(" ")
      stringifyAttr(attr, buffer)

proc stringifyInternal(h: HtmlNode, buffer: var StringImpl) {.inline.} =
  assert(not h.isNil(), "Cannot render NULL node")
  case h.kind
  of text:
    buffer.add(h.content)
  of element:
    buffer.add("<")
    buffer.add(h.tag)
    h.stringifyAttrs(buffer)
    buffer.add(">")
    for child in h.children: child.stringifyInternal(buffer)
    buffer.add("</")
    buffer.add(h.tag)
    buffer.add(">")

proc `$`*(h: HtmlNode): StringImpl =
  case h.kind
  of text: return h.content
  of element:
    when defined(js):
      h.stringifyInternal(result)
    else:
      result = newStringOfCap(100)
      h.stringifyInternal(result)

proc stylesheet*(href: string): HtmlNode =
  link({"rel": "stylesheet", "type": "text/css", "href": href})

proc mobileDeviceScaling*: HtmlNode =
  meta({"name": "viewport", "content": "width=device-width, initial-scale=1"})
