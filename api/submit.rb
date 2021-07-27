require 'octokit'

TOKEN = ENV['TOKEN']
REPO = ENV['REPO'] || 'duty-machine/archives'

Handler = Proc.new do |req, res|
  url = req.query['url']

  client = Octokit::Client.new(access_token: TOKEN)
  result = client.create_issue(REPO, 'archive_request', url)
  sleep 1

  res.status = 302
  res['Location'] = result[:html_url]
end
