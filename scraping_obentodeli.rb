require "google_drive"
require 'mechanize'
require "csv"
require "pry"

agent = Mechanize.new

worksheet_name = "obentodeli"
session = GoogleDrive::Session.from_config("google_drive_config.json")
ws = session.spreadsheet_by_key("1zM2FiW1bkc-E0cI0-4AaBJ6P1VJrFy1uf68RqWxbZ0A").worksheet_by_title(worksheet_name)

shops = []
path = 1492
while path < 2000 do
  @shop_name = ""
  @error_messe = ""
  @shop_url = ""
  current_page = agent.get("http://obentodeli.jp/" + path.to_s )
  sleep(rand(10) + 5)
  @shop_name = current_page.search(".containerTopTenantoName").inner_text.gsub(/[\t\n]/,"")
  @error_messe = current_page.search(".itemTopBoxErrorMessage").inner_text.gsub(/[\t\n]/,"")
  @shop_url = "http://obentodeli.jp/" + path.to_s

  break if @shop_name == ""

  puts [@shop_name,@shop_url,@error_messe]
  shops << [@shop_name,@shop_url,@error_messe]

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
      ws[last_row, 3] = shop[2]
      ws[last_row, 4] = today
      last_row += 1
      ws.save
    end
    shops = []
    puts shops
  end
  path += 1
end
