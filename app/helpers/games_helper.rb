module GamesHelper
  def display_draught_man_entity(piece)
    if piece.colour == "white" && piece.rank == "man"
      "&#9920;".html_safe
    elsif piece.colour == "white" && piece.rank == "king"
      "&#9921;".html_safe
    elsif piece.colour == "red" && piece.rank == "man"
      "&#9922;".html_safe
    elsif piece.colour == "red" && piece.rank == "king"
      "&#9923;".html_safe
    end
  end
end
