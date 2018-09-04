require "google_drive"
require "pry"
require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'


worksheet_name = "ippinbento"
session = GoogleDrive::Session.from_config("google_drive_config.json")
ws = session.spreadsheet_by_key("1zM2FiW1bkc-E0cI0-4AaBJ6P1VJrFy1uf68RqWxbZ0A").worksheet_by_title(worksheet_name)

Capybara.register_driver(:poltergeist) do |app|
  Capybara::Poltergeist::Driver.new(app, {
    js_errors: false, :timeout => 100
  })
end
session = Capybara::Session.new(:poltergeist)
session.driver.headers = {
    'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2564.97 Safari/537.36"
}

session.visit('https://www.ippin-bento.com/brand/')
page = Nokogiri::HTML.parse(session.html)
elements = page.css('tr')
shops = []
elements.each_with_index do |ele, i|
  if i < 3
    next
  end
  @shop_url = "https://www.ippin-bento.com/brand/" + ele.css('a').text()
  session.visit(@shop_url)
  sleep(rand(10) + 5)
  page = Nokogiri::HTML.parse(session.html)
  @shop_name = page.css('.brand-name').text()
  puts [@shop_name,@shop_url]
  shops << [@shop_name,@shop_url]

  if shops.length == 10
    #ws.num_rows　空でない最終行
    existing_shops = []
    today = Date.today
    (2..ws.num_rows).map do |row|
      existing_shops << [ws[row,1],ws[row,2],ws[row,3]]
    end
    #配列の引き算
    new_shops = shops - existing_shops

    i = 0
    last_row = ws.num_rows + 1

    new_shops.each do |shop|
      ws[last_row, 1] = shop[0]
      ws[last_row, 2] = shop[1]
      ws[last_row, 3] = today
      last_row += 1
      ws.save
    end
    shops = []
    puts shops
  end
end
