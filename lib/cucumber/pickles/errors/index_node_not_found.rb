class IndexNodeNotFound < Capybara::ElementNotFound

  def initialize(text, index, nodes)
    @text = text
    @index = index
    @nodes = nodes
  end

  def message
    if @nodes.empty?
      _not_found_at_all_message
    else
      _not_found_by_index_message
    end
  end

  def _not_found_by_index_message
    "Element with text #{@text}[#{@index}] was not found on the page, " \
    "but #{@text}[0] found; Maybe used incorrect index?"
  end

  def _not_found_at_all_message
    "Element with text #{@text}[#{@index}] was not found on the page; " \
    "Maybe used incorrect text?"
  end

end
