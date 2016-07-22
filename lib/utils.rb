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
