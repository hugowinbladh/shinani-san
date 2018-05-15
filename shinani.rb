require 'httparty'
require 'nokogiri'
require 'telegram/bot'

def getEpisodes(bot, show)
	page = HTTParty.get(show)
	Nokogiri::HTML(page).css("#episode_page li a").first["ep_end"].to_i
end

def init(bot, message, users)
	users[message.chat.id] = {}
	bot.api.send_message(chat_id: message.chat.id, text: "Herro sir! My namu isu Shinani ando i wirru terru you when new anime episodo comu outo. Ifu you wanto to addo a serisu to watchu, writo \"addSeries\" ando I wirru keepu turacku ofu ito. Habu a naisu day!")
end

token = File.open("API.txt", "r").read

Telegram::Bot::Client.run(token) do |bot|
	users = {}
	Thread.new {
		while true
			users.each do |u, info|
				info.each do |s, show|
					if getEpisodes(bot, show[:url]) > show[:episodes]
						users[u][s][:episodes] = getEpisodes(bot, show[:url])
						bot.api.send_message(chat_id: u, text: "a new episode of " + s + " is out")
					end
				end
			end
			sleep 60
		end
	}
	bot.listen do |message|
		case message.text
		when "/start"
			init(bot,message, users)
		when "addSeries"
			bot.api.send_message(chat_id: message.chat.id, text: "Okay! Whatu isu za namu ofu ze serisu?")
			bot.listen do |name|
				bot.api.send_message(chat_id: message.chat.id, text: "Sankyuu! Now whato isu ze URL ofu ze serisu on gogoanime? \n it should look like this https://www2.gogoanime.se/category/name-of-the-show")
				bot.listen do |url|
					users[message.chat.id][name.text] = {:url => url.text, :episodes => getEpisodes(bot, url.text)}
					bot.api.send_message(chat_id: message.chat.id, text: "Arigatou gosaimashita! Ima zenbu wa owatta desu!")
				end
			end
		end
	end
end

