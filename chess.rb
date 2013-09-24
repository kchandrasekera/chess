class Board
  def initialize
    @board = Array.new(8) { Array.new(8) }
  end
end

module SlidingPieces

  def moves

  end
end

class Rook

  include SlidingPieces

  def initialize

  end

  def move_dirs

  end
end

class Queen
  include SlidingPieces
  def initialize

  end

  def move_dirs

  end
end

class Bishop
  include SlidingPieces
  def initialize

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
  def initialize

  end

  def move_dirs

  end
end

class Knight
  include SteppingPieces
  def initialize

  end

  def move_dirs

  end

end

class Pawn

  def initialize

  end

  def moves

  end

end