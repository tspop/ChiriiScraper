require "open-uri"
require "nokogiri"
require "json"
require "ostruct"

timeToWait = 10

100000.times do 

	rents = JSON.parse(open('rents.json').read)

	seenLinks = rents.map { |e| e["link"]  }

	url = "http://nemutam.co/?pret_min=&pret_max=350&camere_min=2&camere_max=3&zone=21-&sort=noi"

	node = Nokogiri::HTML(open(url))


	node.xpath('//div[@class="thumbnail"]').each do |rentNode|
		rent = OpenStruct.new

		rent.price = rentNode.xpath('div[@class="price"]/span').inner_text
		rent.numar_camere = rentNode.xpath('div[@class="caption"]/table/tr[2]/td[2]').inner_text
		rent.suprafata = rentNode.xpath('div[@class="caption"]/table/tr[3]/td[2]').inner_text
		rent.link = rentNode.xpath('a').first['href']
		rent.added_at = Time.new.to_s

		break if seenLinks.include?(rent.link)

		rents << rent.marshal_dump
		rent_description = "Pret: #{rent.price}\nSuprafata: #{rent.suprafata}\nLink: #{rent.link}"
		`terminal-notifier -title 'Ti-am gasit chirie, boss' -message '#{rent_description}' -open '#{rent.link}'`
	end

	File.open("rents.json", "w") { |io|  io.write(JSON.pretty_generate(rents))}

	sleep(timeToWait)
end