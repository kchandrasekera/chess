class Game
  def initialize
    @game_board = Board.new
    @player1 = HumanPlayer.new
    @player2 = HumanPlayer.new
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

  attr_accessor :board

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


  def display
    @board.each do |row|
      p row
    end
  end

end

class HumanPlayer
end

module SlidingPieces

  def moves(board)
    moves = []
    move_dirs.each do |x, y|
      (1..7).each do |multiplier|
        target = [@pos[0] + x * multiplier, @pos[1] + y * multiplier]
        moves << target if valid_move?(target, [x,y], board)
      end
    end
    moves
  end

  def valid_move?(target, move_dir, board)
    return false if target[0] < 0 || target[0] > 7 || target[1] < 0 || target[1] > 7

    tested_pos = @pos
    test_x,test_y = @pos
    target_x, target_y = target
    until tested_pos == target
      if !board.board[test_x][test_y].nil?
        return false
      else
        test_x += move_dir[0]
        test_y += move_dir[1]
      end
    end

    if !board[target_x][target_y].nil?
      return false if board[target_x][target_y].color == self.color
    else

    #test for check
    true
  end

end

class Rook
  attr_reader :color
  include SlidingPieces

  def initialize(pos, color)
    @pos = pos
    @color = color
  end

  def move_dirs
    [[-1,0],[0,-1],[0,1],[1,0]]
  end
end

class Queen
  attr_reader :color
  include SlidingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_dirs
    [[-1,0],[0,-1],[0,1],[1,0],[1,1],[-1,-1],[1,-1][-1,1]]
  end
end

class Bishop
  attr_reader :color
  include SlidingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_dirs
    [[1,1],[-1,-1],[1,-1][-1,1]]
  end
end

module SteppingPieces

  def moves(board)
    moves = []
    curr_x, curr_y = @pos
    move_locations.each do |dx, dy|
      target = [curr_x + dx, curr_y + dy]
      moves << target if valid_move?(target, board)
    end
    moves
  end

  def valid_move?(target, board)
    target = target_x, target_y
    if !board[target_x][target_y].nil?
      return false if board[target_x][target_y].color == self.color
    else
      #check check
    end

    true
  end
end

class King
  attr_reader :color
  include SteppingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_locations
    [[-1,0],[0,-1],[0,1],[1,0],[1,1],[-1,-1],[1,-1][-1,1]]
  end
end

class Knight
  attr_reader :color
  include SteppingPieces
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def move_locations
    [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]
  end

end

class Pawn
  attr_reader :color
  def initialize(pos, color)
    @pos = pos
    @color = color
  end


  def moves(board)
    if @color == "white"
      move_offsets = [[1,0]]
      if @pos[0] == 1
        move_offsets << [2,0]
      end
    else
      move_offsets = [[-1,0]]
      if @pos[0] == 6
        move_offsets << [-2,0]
      end
    end



    if color == "white"
      if board[@pos[0] + 1][@pos[1] + 1].color == "black"
        move_offsets += [1,1]
      end
      if board[@pos[0] + 1][@pos[1] - 1].color == "black"
        move_offsets += [1,-1]
      end
    else
      if board[@pos[0] - 1][@pos[1] + 1].color == "white"
        move_offsets += [-1,1]
      end
      if board[@pos[0] - 1][@pos[1] - 1].color == "white"
        move_offsets += [-1,-1]
    end

    moves = move_offsets.select {|offset| valid_move?(offset, board)}
  end

  def valid_move?(offset, board)
    offset_vert, offset_horz = offset
    if offset_horz == 0
      (1..offset_vert).each do |moves_forward|
        return false if !board[@pos[0] +  moves_forward][@pos[1]].nil?
      end
    end
  end

    # def valid_move?(target, board)
#       target = target_x, target_y
#       if !board[target_x][target_y].nil?
#         return false if board[target_x][target_y].color == self.color
#       else
#         #check check
#       end
#
#       true
#     end
end