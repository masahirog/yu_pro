require "google_drive"
require "pry"
require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'


worksheet_name = "rakuten_b"
session = GoogleDrive::Session.from_config("google_drive_config.json")
ws = session.spreadsheet_by_key("1zM2FiW1bkc-E0cI0-4AaBJ6P1VJrFy1uf68RqWxbZ0A").worksheet_by_title(worksheet_name)

#ws.num_rows　空でない最終行
existing_shops = []
today = Date.today
(2..ws.num_rows).map do |row|
  existing_shops << [ws[row,1]]
end

Capybara.register_driver(:poltergeist) do |app|
  Capybara::Poltergeist::Driver.new(app, {
    js_errors: false, :timeout => 100
  })
end
session = Capybara::Session.new(:poltergeist)
session.driver.headers = {
    'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2564.97 Safari/537.36"
}


shops = []
sleep(rand(10))
session.visit("https://delivery.rakuten.co.jp/genre/lunch.html")
page = Nokogiri::HTML.parse(session.html)
elements = page.css('.gl-pickup-list-item')
elements.each do |ele|
  shop_name = ele.css(".gl-pickup-name > a").text()
  if ele.css(".gl-pickup-name > a").attribute("href").value().nil?
    shop_url = "なし"
  else
    shop_url = ele.css("a").attribute("href").value()
  end
  puts shop_name
  puts shop_url
  if existing_shops.include?(shop_name)
  else
    last_row = ws.num_rows + 1
    ws[last_row, 1] = shop_name
    ws[last_row, 2] = shop_url
    ws[last_row, 3] = today
    last_row += 1
    ws.save
    existing_shops << shop_name
  end
end
