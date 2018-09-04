require "google_drive"
require 'mechanize'
require "csv"
require "pry"

agent = Mechanize.new

worksheet_name = "gochikul"
session = GoogleDrive::Session.from_config("google_drive_config.json")
ws = session.spreadsheet_by_key("1zM2FiW1bkc-E0cI0-4AaBJ6P1VJrFy1uf68RqWxbZ0A").worksheet_by_title(worksheet_name)

shops = []
current_page = agent.get("https://gochikuru.com/shoplist/")
elements = current_page.search("#kanto > .shop-name")
elements.each do |ele|
  ele.search("li > a").each do |li|
    sleep(rand(10))
    @shop_name = li.inner_text
    @shop_url = "https://gochikuru.com" + li.get_attribute("href")
    puts @shop_name
    puts @shop_url
    shops << [@shop_name,@shop_url]
    if shops.length == 10
      #ws.num_rows　空でない最終行
      existing_shops = []
      today = Date.today
      (2..ws.num_rows).map do |row|
        existing_shops << [ws[row,1],ws[row,2]
      end
      #配列の引き算
      new_shops = shops - existing_shops
      last_row = ws.num_rows + 1
      new_shops.each do |shop|
        ws[last_row, 1] = shop[0]
        ws[last_row, 2] = shop[1]
        ws[last_row, 3] = today
        last_row += 1
        ws.save
      end
    end
    shops = []
    puts shops
  end
end
