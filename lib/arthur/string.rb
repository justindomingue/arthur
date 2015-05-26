require 'cgi'

class String
  # Removes non alpha-numeric characters minus the space
  def remove_non_alpha_numeric
    self.gsub(/[^0-9a-z ']/i, '').strip
  end

  def unescape_html
    CGI.unescapeHTML(self)
    return self
  end

  def remove_html_tags
    self.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '')  # html tags
  end

  def remove_new_lines
    self.gsub('\n','')
  end

  # Removes dates with regex `format`
  def remove_dates(format=/\w{3} \d{1,2}, \d{4} \.{3} /)
    self.gsub(format, '')
  end

  def remove_incomplete_sentences(format= /[^\.]+\.{3,}/)
    self.gsub(format, '')
  end
end
