require "google_drive"
require "pry"
require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'


worksheet_name = "gnavi"
session = GoogleDrive::Session.from_config("google_drive_config.json")
ws = session.spreadsheet_by_key("1zM2FiW1bkc-E0cI0-4AaBJ6P1VJrFy1uf68RqWxbZ0A").worksheet_by_title(worksheet_name)

# ws.num_rows　空でない最終行
existing_shops = []
(2..ws.num_rows).map do |row|
  existing_shops << [ws[row,1],ws[row,2]]
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

# saitama = 'pr11'
# chiba = 'pr12'
# tokyo = 'pr13'
# kanagawa = 'pr14'

area = ['pr14']

for i in area do
  p i
  next_page = 1
  while next_page < 50 do
    shops = []
    p next_page
    sleep(rand(10))
    session.visit("https://delivery.gnavi.co.jp/premium/area/" + i + "/shop/?page=" + next_page.to_s)
    page = Nokogiri::HTML.parse(session.html)
    elements = page.css('.shop-card__box')
    if elements.length == 0
      break
    else
      elements.each do |ele|
        shop_name = ele.css(".shop-card__title").text()
        if ele.attribute("href").value().nil?
          shop_url = "なし"
        else
          shop_url = ele.attribute("href").value()
        end
        puts shop_name
        puts shop_url
        shops << [shop_name,shop_url]
      end
      # 配列ユニーク
      new_shops = shops - existing_shops
      last_row = ws.num_rows + 1
      new_shops.each do |shop|
        ws[last_row, 1] = shop[0]
        ws[last_row, 2] = shop[1]
        last_row += 1
        ws.save
      end
      next_page += 1
      existing_shops = new_shops + existing_shops
    end
  end
end
