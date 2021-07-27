register_website(
  name: 'telegraph',
  test: -> (uri) {
    uri.hostname == 'telegra.ph'
  },
  process: -> (html) {
    document = Nokogiri::HTML(html)
    title = document.css('header h1').first.content
    author = document.css('header a[rel=author]').first.content
    content = document.css('article').first

    content.css('h1').first.remove
    content.css('address').first.remove

    {
      title: title,
      author: author,
      content: content.to_html.lines.map(&:strip).join
    }
  }
)
