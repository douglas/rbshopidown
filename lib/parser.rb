# encoding: utf-8

def parse_styles(text)
  # Parse styles into html
  # Style regex (finally made the regex work, phew)
  # Big thanks to the Patterns macOS app, because it
  # helps to see if the regex is really doing what it
  # is intented to do.

  # Replace bold for <strong> and </strong>
  parsed_text = text.gsub(/\*{2}([a-z]+)\*{2}/, '<strong>\1</strong>')

  # Replace italic for <em> and </em>
  parsed_text = parsed_text.gsub(/\*{1}([a-z]+)\*{1}/, '<em>\1</em>')

  parsed_text
end

class Parser
  def initialize()
    @unordered_items = []
    @ordered_items = []
    @multiline = false
  end

  def handle_multiline(text)
    # If the input text is a multiline string we
    # need to add a \n to the end of the text

    if @multiline
      "#{text}\n"
    else
      text
    end
  end

  def parse_list_items
    # Parse the collected list items

    html = []

    if not @unordered_items.empty?
      html.push("<ul>\n")

      @unordered_items.each do |item|
        processed_item = item.sub("- ", "")
        html.push("  <li>#{processed_item}</li>\n")
      end

      html.push("</ul>\n")

      # Lets empty the unordered items list
      @unordered_items = []
    end

    if not @ordered_items.empty?
      html.push("<ol>\n")

      @ordered_items.each do |item|
        processed_item = item.sub(/^[1-9]\. /, "")
        html.push("  <li>#{processed_item}</li>\n")
      end

      html.push("</ol>\n")

      # Lets empty the unordered items list
      @ordered_items = []
    end

    html.join
  end

  def parse(text)
    # Parse markdown text into html

    lines = text.split(/\n/)

    html = []

    if lines.count > 1
      @multiline = true
    end

    for line in lines
      if line.start_with?('# ')  # Title
        new_line = "<h1>%s</h1>" % line.sub('# ', '')
        new_line = handle_multiline(new_line)
        html.push(new_line)
        next
      elsif line.start_with?('## ') # Subtitle
        new_line = "<h2>%s</h2>" % line.sub('## ', '')
        new_line = handle_multiline(new_line)
        html.push(new_line)
        next
      elsif line.start_with?('- ') # Unordered item
        @unordered_items.push(line)
        next
      elsif /^[1-9]\. /.match(line) # Ordered item
        @ordered_items.push(line)
        next
      end

      # Lets see if we have to create the ul or ol tree
      if not line.start_with?('- ')
        html.push(parse_list_items())
      elsif line !~ /^[1-9]\. /
        html.push(parse_list_items())
      end

      if line == ""
        html.push("\n")
      else
        # Paragraph
        new_line = handle_multiline("<p>%s</p>" % line)
        html.push(new_line)
      end
    end

    # If we just had lists on our text we need to
    # process them after the loop
    html.push(parse_list_items())

    # To finish, lets parse the styles =)
    parse_styles(html.join)
  end
end
