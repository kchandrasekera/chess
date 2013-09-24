class Game
  def initialize
    @game_board = Board.new
    @player1 = Player.new
    @player2 = Player.new
    @turn = 1
  end

  def play
    until @game_board.checkmate?
      @game_board.display
      @turn % 2 == 1 ? @player1.move : @player2.move
      @turn += 1
    end

  end
end


class Board
  def initialize
    @board = Array.new(8) { Array.new(8) }

    @board[0] = [Rook.new([0,0], "white"), Knight.new([0,1], "white"), Bishop.new([0,2], "white"),
                 Queen.new([0,3], "white"), King.new([0,4], "white"),
                 Bishop.new([0,5], "white"), Knight.new([0,6], "white"), Rook.new([0,7], "white")]

    @board[1] = [Pawn.new([1,0], "white"), Pawn.new([1,1], "white"), Pawn.new([1,2], "white"),
                 Pawn.new([1,3], "white"), Pawn.new([1,4], "white"), Pawn.new([1,5], "white"),
                 Pawn.new([1,6], "white"), Pawn.new([1,7], "white")]

    @board[7] = [Rook.new([7,0], "black"), Knight.new([7,1], "black"), Bishop.new([7,2], "black"),
                Queen.new([7,3], "black"), King.new([7,4], "black"),
                Bishop.new([7,5], "black"), Knight.new([7,6], "black"), Rook.new([7,7], "black")]

    @board[6] = [Pawn.new([6,0], "black"), Pawn.new([6,1], "black"), Pawn.new([6,2], "black"),
                 Pawn.new([6,3], "black"), Pawn.new([6,4], "black"), Pawn.new([6,5], "black"),
                 Pawn.new([6,6], "black"), Pawn.new([6,7], "black")]
  end



end

class Player
end

module SlidingPieces

  def moves

  end
end

class Rook

  include SlidingPieces

  def initialize(pos, color)
    @pos = pos
    @color = color
  end

  def move_dirs

  end
end

class Queen
  include SlidingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_dirs

  end
end

class Bishop
  include SlidingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_dirs

  end
end

module SteppingPieces

  def moves

  end
end

class King
  include SteppingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_dirs

  end
end

class Knight
  include SteppingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_dirs

  end

end

class Pawn

  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def moves

  end

end