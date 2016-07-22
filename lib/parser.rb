require "utils"

class Parser
    def initialize()
        @unordered_items = []
        @ordered_items = []
        @multiline = false
    end

    def handle_multiline(text)
        if @multiline
            "%s\n" % text
        else
            text
        end
    end

    def html_text(text)
        text*""
    end

    def parse_unordered_items
        # Parse the collected unordered items

        html = ["<ul>\n"]

        for item in @unordered_items
            html.push("  <li>%s</li>\n" % item.sub("- ", ""))
        end

        html.push("</ul>\n")

        # Lets empty the unordered items list
        @unordered_items = []

        return html*""
    end

    def parse_ordered_items
        # Parse the collected ordered items

        html = ["<ol>\n"]

        for item in @ordered_items
            html.push("  <li>%s</li>\n" % item.sub(/^[1-9]\. /, ""))
        end

        html.push("</ol>\n")

        # Lets empty the unordered items list
        @ordered_items = []

        return html*""
    end

    def parse(text)
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
            if not line.start_with?('- ') and @unordered_items.count > 1
                html.push(parse_unordered_items())
            elsif line !~ /^[1-9]\. / and @ordered_items.count > 1
                html.push(parse_ordered_items())
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
        if @unordered_items.count > 1
            html.push(parse_unordered_items())
        end

        if @ordered_items.count > 1
            html.push(parse_ordered_items())
        end

        parse_styles(html_text(html))
    end
end
