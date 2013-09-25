# coding: utf-8
require "colorize"

class Game
  attr_accessor :game_board, :player1, :player2, :turn
  def initialize
    @game_board = Board.new
    @player1 = HumanPlayer.new(:white)
    @player2 = HumanPlayer.new(:green)
    @turn = 1
  end

  def play
    until @game_board.checkmate?
      @game_board.display
      puts "Check" if @game_board.check?(:white) || @game_board.check?(:green)
      begin
        @turn % 2 == 1 ? move = @player1.move : move = @player2.move
        execute_valid_move
      rescue
        retry
      end
      @turn += 1
    end
  end
end


class Board

  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8) }

    @board[0] = [Rook.new([0,0], :white, "\u2656"), Knight.new([0,1], :white, "\u2658"), Bishop.new([0,2], :white, "\u2657"),
                 Queen.new([0,3], :white, "\u2655"), King.new([0,4], :white, "\u2654"),
                 Bishop.new([0,5], :white, "\u2657"), Knight.new([0,6], :white, "\u2658"), Rook.new([0,7], :white, "\u2656")]

    @board[1] = [Pawn.new([1,0], :white, "\u2659"), Pawn.new([1,1], :white, "\u2659"), Pawn.new([1,2], :white, "\u2659"),
                 Pawn.new([1,3], :white, "\u2659"), Pawn.new([1,4], :white, "\u2659"), Pawn.new([1,5], :white, "\u2659"),
                 Pawn.new([1,6], :white, "\u2659"), Pawn.new([1,7], :white, "\u2659")]

    @board[6] = [Pawn.new([6,0], :green, "\u2659"), Pawn.new([6,1], :green, "\u2659"), Pawn.new([6,2], :green, "\u2659"),
                Pawn.new([6,3], :green, "\u2659"), Pawn.new([6,4], :green, "\u2659"), Pawn.new([6,5], :green, "\u2659"),
                Pawn.new([6,6], :green, "\u2659"), Pawn.new([6,7], :green, "\u2659")]

    @board[7] = [Rook.new([7,0], :green, "\u2656"), Knight.new([7,1], :green, "\u2658"), Bishop.new([7,2], :green, "\u2657"),
                Queen.new([7,3], :green, "\u2655"), King.new([7,4], :green, "\u2654"),
                Bishop.new([7,5], :green, "\u2657"), Knight.new([7,6], :green, "\u2658"), Rook.new([7,7], :green, "\u2656")]


  end


  def display
    reversed_board = @board.reverse
    reversed_board.each do |row|
      row.each do |object|
        if object.nil?
          print "\u25A1".colorize(:gray) + " "
        else
          color = object.color
          unicode_format = object.unicode
          print unicode_format.colorize(color) + " "
        end
      end
      puts
    end
  end

  def execute_move(current_pos, intended_pos)

    @board[current_pos[0]][current_pos[1]].pos = intended_pos
    @board[intended_pos[0]][intended_pos[1]] = @board[current_pos[0]][current_pos[1]]
    @board[current_pos[0]][current_pos[1]] = nil

  end

  def execute_valid_move(current_pos, intended_pos)
    self.is_a?(Array)
    if @board[current_pos[0]][current_pos[1]].moves(self).include?(intended_pos)
      execute_move(current_pos, intended_pos)
    else
      #invalid move - raise exception
      raise InvalidMoveError.new "Invalid move"
    end

  end

  def check?(color, current_pos = nil, intended_pos = nil)

    if current_pos && intended_pos
      duped_positions = @board.deep_dup
      duped_board = Board.new
      duped_board.board = duped_positions
      duped_board.execute_move(current_pos, intended_pos)
    else
      duped_board = self
    end

    king_pos = nil
    duped_board.board.flatten.each do |square|
      if !square.nil?
        if square.color == color && square.is_a?(King)
          king_pos = square.pos
        end
      end
    end

    duped_board.board.flatten.each do |square|
      p square
      if !square.nil? && square.color != color
        return true if square.moves(duped_board).include?(king_pos)
      end
    end

    false
  end

  def checkmate?
  end

end

class HumanPlayer
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def move
    puts "What piece would you like to move? e.g. [x,y]"
    start_pos = gets.chomp
    puts "Where would you like to move it to? e.g. [x,y]"
    end_pos = gets.chomp

    [start_pos, end_pos]
  end

end

module SlidingPieces

  def moves(game_board)
    moves = []
    move_dirs.each do |dir_vert, dir_horz|
      (1..7).each do |multiplier|
        target = [@pos[0] + (dir_vert * multiplier), @pos[1] + (dir_horz * multiplier)]
        moves << target if valid_move?(target, [dir_vert, dir_horz], game_board)
      end
    end
    moves
  end

  def valid_move?(target, move_dir, game_board)
    return false if target[0] < 0 || target[0] > 7 || target[1] < 0 || target[1] > 7

    tested_pos = @pos
    test_vert,test_horz = @pos
    target_vert, target_horz = target
    until tested_pos == target
      if !game_board.board[test_vert][test_horz].nil?
        return false
      else
        test_vert += move_dir[0]
        test_horz += move_dir[1]
      end
    end

    if !game_board.board[target_vert][target_horz].nil?
      return false if game_board.board[target_vert][target_horz].color == self.color
    end

    return false if game_board.check?(@color, @pos, [target_vert, target_horz])
    true
  end

end

class Rook
  attr_accessor :color, :pos, :unicode
  include SlidingPieces

  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end

  def move_dirs
    [[-1,0],[0,-1],[0,1],[1,0]]
  end
end

class Queen
  attr_accessor :color, :pos, :unicode
  include SlidingPieces
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end



  def move_dirs
    [[-1,0],[0,-1],[0,1],[1,0],[1,1],[-1,-1],[1,-1][-1,1]]
  end
end

class Bishop
  attr_accessor :color, :pos, :unicode
  include SlidingPieces
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end



  def move_dirs
    [[1,1],[-1,-1],[1,-1][-1,1]]
  end
end

module SteppingPieces

  def moves(game_board)
    moves = []
    curr_x, curr_y = @pos
    move_locations.each do |dx, dy|
      target = [curr_x + dx, curr_y + dy]
      moves << target if valid_move?(target, game_board)
    end
    moves
  end

  def valid_move?(target, game_board)
    target_x, target_y = target
    if !game_board.board[target_x][target_y].nil?
      return false if game_board.board[target_x][target_y].color == self.color
    else
      #check check
    end
    return false if game_board.check?(@color, @pos, [target[0], target[1]])
    true
  end
end

class King
  attr_accessor :color, :pos, :unicode
  include SteppingPieces
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end



  def move_locations
    [[-1,0],[0,-1],[0,1],[1,0],[1,1],[-1,-1],[1,-1][-1,1]]
  end
end

class Knight
  attr_accessor :color, :pos, :unicode
  include SteppingPieces
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end



  def move_locations
    [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]
  end

end

class Pawn
  attr_accessor :color, :pos, :unicode
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end



  def moves(game_board)
    if @color == :white
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



    if color == :white
      if !game_board.board[@pos[0] + 1][@pos[1] + 1].nil? && game_board.board[@pos[0] + 1][@pos[1] + 1].color == :green
        move_offsets += [1,1]
      end
      if !game_board.board[@pos[0] + 1][@pos[1] - 1].nil? && game_board.board[@pos[0] + 1][@pos[1] - 1].color == :green
        move_offsets += [1,-1]
      end
    else
      if !game_board.board[@pos[0] - 1][@pos[1] + 1].nil? && game_board.board[@pos[0] - 1][@pos[1] + 1].color == :white
        move_offsets += [-1,1]
      end
      if !game_board.board[@pos[0] - 1][@pos[1] - 1].nil? && game_board.board[@pos[0] - 1][@pos[1] - 1].color == :white
        move_offsets += [-1,-1]
      end
    end

    moves = move_offsets.select {|offset| valid_move?(offset, game_board)}
  end

  def valid_move?(offset, game_board)
    offset_vert, offset_horz = offset
    if offset_horz == 0
      (1..offset_vert).each do |moves_forward|
        return false if !game_board.board[@pos[0] +  moves_forward][@pos[1]].nil?
      end
    end

    return false if game_board.check?(@color, @pos, [@pos[0] + offset_vert, @pos[1] + offset_horz])
  end

end

class Array
  def deep_dup
    duped_array = []
    if self.flatten == self
      return self.dup
    else
      self.each do |el|
        duped_array << el.deep_dup
      end
    end
    duped_array
  end
end

chess = Game.new
chess.play