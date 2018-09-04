require "google_drive"
require "pry"
require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'


worksheet_name = "fine_dine"
session = GoogleDrive::Session.from_config("google_drive_config.json")
ws = session.spreadsheet_by_key("1zM2FiW1bkc-E0cI0-4AaBJ6P1VJrFy1uf68RqWxbZ0A").worksheet_by_title(worksheet_name)

#ws.num_rows　空でない最終行
existing_shops = []
today = Date.today
(2..ws.num_rows).map do |row|
  existing_shops << ws[row,1]
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
session.visit("https://www.finedine.jp/office/")
page = Nokogiri::HTML.parse(session.html)
elements = page.css('.mod-buttonList')
elements.each do |ele|
  offices = ele.css("li")
  offices.each do |office|
    office_url = office.css("a").attribute("href").value()
    session.visit("https://www.finedine.jp#{office_url}")
    page = Nokogiri::HTML.parse(session.html)
    stores = page.css('.office-restaulantList')
    stores.each do |store|
      shop_name = store.css('.headLine').text()
      shop_url = "https://www.finedine.jp" + store.css('.mod-restaulantImages > a').attribute("href").value()
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
  end
end
