require 'nokogiri'
require 'octokit'
require 'uri'
require 'net/http'
require 'cgi'
require 'json'

WEBSITES = []

def register_website config
  WEBSITES << config
end

def get_with_headers uri, headers
  get = Net::HTTP::Get.new(uri)
  res = Net::HTTP.start(uri.hostname, uri.port, {use_ssl: uri.scheme == 'https'}) { |http|
    http.request_get(uri, headers)
  }
  res.body
end

Dir["#{__dir__}/websites/*.rb"].each{|path| require path}

def fetch_article url
  begin
    uri = URI(url)
  rescue URI::InvalidURIError
    uri = URI(URI.escape(url))
  end

  website = WEBSITES.find{|x| x[:test].(uri) } || WEBSITES.find{|x| x[:name] == 'default'}

  request = website[:request] || ->(uri) {
    get_with_headers(uri, {})
  }

  process = website[:process]

  process.(request.(uri))
end

def run token, repo
  client = Octokit::Client.new(access_token: token)
  client.list_issues(repo, state: 'open').each do |issue|
    begin
      number = issue[:number]
      title = issue[:title]
      body = issue[:body]

      if title == 'archive_request'
        article = fetch_article(body)
        client.add_comment(repo, number, "#{article[:title]} by #{article[:author]}\n------\n#{article[:content]}")
        client.update_issue(repo, number, title: article[:title])
      else
        raise 'invalid request'
      end
    rescue
      client.add_comment(repo, number, $!.inspect)
      client.update_issue(repo, number)
    ensure
      client.close_issue(repo, number)
    end
  end
end
