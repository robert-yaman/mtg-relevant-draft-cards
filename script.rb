require 'net/http'
require 'json'
require_relative 'search_trie'

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

InstantTrie = SearchTrie.new([
  "target creature",
  "destroy",
  "exile",
  "damage",
  "creatures you control",
  "creatures your opponent controls"
])

NonInstantTrie = SearchTrie.new([
  "flash"
])

all_cards = JSON.parse(Net::HTTP.get('mtgjson.com', '/json/BFZ.json'))["cards"]
p relevant_cards = cards.select do |card|
  if card["types"].include?("Instant")
    InstantTrie.has_occurence?(card["text"])
  else
    NonInstantTrie.has_occurence?(card["text"])
  end
end
