class Node
  attr_reader :val

  def initialize(val)
    @val = val
    @children = []
  end

  def append(node)
    @children << node
  end

  def find_child(char)
    # this is linear, should be log
    @children.select { |child| child.val == char}[0]
  end

  def is_terminal?
    @children.any? { |child| child.val == :terminal}
  end
end

class SearchTrie
  def initialize(words, options = {})
    defaults = {
      case_insensitive: true
    }

    @options = defaults.merge(options)
    @root = Node.new(:root)
    construct_trie(words)
  end

  def can_find_occurence?(text)
    text.each_char.with_index do |_, index|
      return true if can_find_terminal_from?(text, index)
    end

    false
  end

  private

  def construct_trie(words)
    words.each do |word|
      curr_node = root

      word.each_char do |char|
        child = curr_node.find_child(char)
        if child
          curr_node = child
        else
          new_node = Node.new(char)
          curr_node.append(new_node)
          curr_node = new_node
        end
      end

      curr_node.append(Node.new(:terminal))
    end
  end

  def can_find_terminal_from?(text, i)
    curr_node = root
    counter = i

    loop do
      if options[:case_insensitive]
        curr_char = text[counter] && text[counter].downcase
      else
        curr_char = text[counter]
      end

      child = curr_node.find_child(curr_char)
      return false unless child
      return true if child.is_terminal?

      curr_node = child
      counter += 1
    end
  end

  attr_reader :root, :options
end

# s = SearchTrie.new(%w(this is search trie full of searchable words that rule) + ["string with spaces"])
# p s.has_occurence?("sTring with spaces are hard to parse") # => true
# p s.has_occurence?("strings with spaces are hard to parse") # => false
# p s.has_occurence?("hooray") # => false
# p s.has_occurence?("this should be true") # => true
