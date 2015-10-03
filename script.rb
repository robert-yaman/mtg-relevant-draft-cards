require 'net/http'
require 'json'
require 'csv'
require_relative 'search_trie'

require 'byebug'

# Conditions:
# 1 If instant, includes at least one of the following:
#     target creature
#     destroy
#     exile
#     damage
#     creatures you control
#     creatures your opponent controls
# 2 If not an instant, includes at least one of the following:
#     flash
#store each set in trie

if ARGV.empty?
  puts "Please provide three letter set abbreviation"
  abort
else
  SET = ARGV[0]
end

InstantTrie = SearchTrie.new([
  "target creature",
  "destroy",
  "exile",
  "damage",
  "creatures you control",
  "creatures your opponent controls",
  "counter target"
])

NonInstantTrie = SearchTrie.new([
  "flash"
])

begin
  data = JSON.parse(Net::HTTP.get('mtgjson.com', "/json/#{SET}.json"))
  all_cards = data["cards"]
rescue
  puts "Invalid Set Abbreviation"
  abort
end


CSV.open("#{SET}_relevant_limited_cards.csv", "w") do |csv|
  csv << ["NAME", "RARITY", "MANA COST", "CMC", "COLORS", "TEXT"]

  all_cards.each do |card|
    text = card["text"] || "" #for vanillas
    if (card["types"].include?("Instant") &&
          InstantTrie.has_occurence?(text)) ||
        NonInstantTrie.has_occurence?(text)
      csv << [
        card["name"],
        card["rarity"][0],
        card["manaCost"]
          .split("")
          .reject {|char| char == "{" || char == "}"}
          .join(""),
        card["cmc"],
        card["colors"] && card["colors"].join(" "),
        card["text"]
      ]
    end
  end
end
