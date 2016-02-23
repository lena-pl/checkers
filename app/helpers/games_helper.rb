module GamesHelper
  def display_draught_man_entity(colour)
    if colour == "white"
      "&#9920;".html_safe
    elsif colour == "red"
      "&#9922;".html_safe
    end
  end
end
