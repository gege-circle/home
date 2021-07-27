register_website(
  name: 'default',
  test: -> (uri) {
    false
  },
  process: -> (html) {
    document = Nokogiri::HTML(html)
    article = document.css('article').first || document.css('main').first
    title = document.css('title').first.content

    {
      title: title,
      author: nil,
      content: article.to_html.lines.map(&:strip).join
    }
  }
)
