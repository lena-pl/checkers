require 'rails_helper'

RSpec.describe GamesHelper, type: :helper do
  describe "#display_draught_man_entity" do
    it "returns the correct draught man entity for given colour" do
      expect(helper.display_draught_man_entity(ConstructBoard::Piece.new("man", "white"))).to eq "&#9920;"
      expect(helper.display_draught_man_entity(ConstructBoard::Piece.new("man", "red"))).to eq "&#9922;"
    end

    it "returns the correct draught king entity for given colour" do
      expect(helper.display_draught_man_entity(ConstructBoard::Piece.new("king", "white"))).to eq "&#9921;"
      expect(helper.display_draught_man_entity(ConstructBoard::Piece.new("king", "red"))).to eq "&#9923;"
    end
  end
end
