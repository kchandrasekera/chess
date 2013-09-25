# coding: utf-8
require "colorize"

require 'debugger'
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
      puts "Check!" if @game_board.check?(:white) || @game_board.check?(:green)
      begin
        @turn % 2 == 1 ? player = @player1 : player = @player2
        move = player.move(player.color)
        @game_board.check_color(move, player.color)
        @game_board.execute_valid_move(move)
      rescue InvalidMoveError
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

  def check_color(move, color)
    pos_vert = move[0][0]
    pos_horz = move[0][1]

    raise InvalidMoveError.new if @board[pos_vert][pos_horz].color != color
  end


  def execute_move(current_pos, intended_pos)
    p "current: #{current_pos}"
    p "intended: #{intended_pos}"
    moving_piece = @board[current_pos[0]][current_pos[1]]
    moving_piece.pos = intended_pos
    @board[intended_pos[0]][intended_pos[1]] = moving_piece
    @board[current_pos[0]][current_pos[1]] = nil

  end

  def execute_valid_move(move)
    p move
    current_pos, intended_pos = move[0], move[1]
    p "here outside loop"
    if @board[current_pos[0]][current_pos[1]].valid_moves(self).include?(intended_pos)
      p "here inside loop"
      execute_move(current_pos, intended_pos)
    else
      p "error inside loop"
      raise InvalidMoveError.new
    end

  end

  def check?(color, current_pos = nil, intended_pos = nil)

    king_pos = get_king_pos(color)



    if current_pos && intended_pos
      duped_positions = @board.deep_dup
      duped_board = Board.new
      duped_board.board = duped_positions
      duped_board.execute_move(current_pos, intended_pos)
      duped_board.board.flatten.each do |square|
        if !square.nil? && square.color != color
          return true if square.moves(duped_board).include?(king_pos)
        end
      end
    else
      @board.flatten.each do |square|
        if !square.nil? && square.color != color
          return true if square.moves(self).include?(king_pos)
        end
      end
    end

    false
  end

  def get_king_pos(color)
    king_pos = nil
    @board.flatten.each do |square|
      if !square.nil?
        if square.color == color && square.is_a?(King)
          king_pos = square.pos
        end
      end
    end
  end

  def checkmate?
    false
  end

end

class HumanPlayer
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def move(color)
    puts "#{color} move: "
    puts "What piece would you like to move? e.g. '1, 3'"
    start_pos = gets.chomp.split(", ").map(&:to_i)
    puts "Where would you like to move it to? e.g. '2, 3'"
    end_pos = gets.chomp.split(", ").map(&:to_i)

    [start_pos, end_pos]
  end


end

class Piece
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

  def valid_moves(game_board)
    valid_moves = moves(game_board)
    p valid_moves
    valid_moves.select do |move|
      p "our current position is "
      !game_board.check?(@color, @pos, [move[0], move[1]])
    end
  end

  def valid_move?(target, move_dir, game_board)
    target_vert, target_horz = target
    return false if target_vert < 0 || target_vert > 7 || target_horz < 0 || target_horz > 7

    #p "pos: #{@pos}"
    #p "target: {target}"
    tested_pos = [@pos[0] + move_dir[0], @pos[1] + move_dir[1]]
    test_vert,test_horz = tested_pos

    until [test_vert, test_horz] == target
      if !game_board.board[test_vert][test_horz].nil?
        #p "tested_pos: #{[test_vert, test_horz]}, intermediary square occupied, false"
        return false
      end
      test_vert += move_dir[0]
      test_horz += move_dir[1]
    end

    if !game_board.board[target_vert][target_horz].nil?
      #p "you are already occupying square"
      return false if game_board.board[target_vert][target_horz].color == self.color
    end

    #p "this is gonna be a valid move"
    true
  end

end

class Rook < Piece
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

class Queen < Piece
  attr_accessor :color, :pos, :unicode
  include SlidingPieces
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end



  def move_dirs
    [[-1,0],[0,-1],[0,1],[1,0],[1,1],[-1,-1],[1,-1],[-1,1]]
  end
end

class Bishop < Piece
  attr_accessor :color, :pos, :unicode
  include SlidingPieces
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end

  def move_dirs
    [[1,1],[-1,-1],[1,-1],[-1,1]]
  end
end

module SteppingPieces

  def moves(game_board)
    moves = []
    curr_vert, curr_horz = @pos
    move_locations.each do |dx, dy|
      target = [curr_vert + dx, curr_horz + dy]
      moves << target if valid_move?(target, game_board)
    end
    moves
  end

  def valid_moves(game_board)
    valid_moves = moves(game_board)
    valid_moves.select do |move|
      !game_board.check?(@color, @pos, [move[0], move[1]])
    end
  end

  def valid_move?(target, game_board)
    target_vert, target_horz = target
    return false if target_vert < 0 || target_vert > 7 || target_horz < 0 || target_horz > 7

    if !game_board.board[target_vert][target_horz].nil?
      return false if game_board.board[target_vert][target_horz].color == self.color
    end

    true
  end
end

class King < Piece
  attr_accessor :color, :pos, :unicode
  include SteppingPieces
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end



  def move_locations
    [[-1,0],[0,-1],[0,1],[1,0],[1,1],[-1,-1],[1,-1],[-1,1]]
  end
end

class Knight < Piece
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

class Pawn < Piece
  attr_accessor :color, :pos, :unicode
  def initialize(pos, color, unicode)
    @pos = pos
    @color = color
    @unicode = unicode
  end

  def moves(game_board)
    curr_vert = @pos[0]
    curr_horz = @pos[1]

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
        move_offsets << [1,1]
      end
      if !game_board.board[@pos[0] + 1][@pos[1] - 1].nil? && game_board.board[@pos[0] + 1][@pos[1] - 1].color == :green
        move_offsets << [1,-1]
      end
    else
      if !game_board.board[@pos[0] - 1][@pos[1] + 1].nil? && game_board.board[@pos[0] - 1][@pos[1] + 1].color == :white
        move_offsets << [-1,1]
      end
      if !game_board.board[@pos[0] - 1][@pos[1] - 1].nil? && game_board.board[@pos[0] - 1][@pos[1] - 1].color == :white
        move_offsets << [-1,-1]
      end
    end

    moves = []
    move_offsets.each do |dx, dy|
      target = [curr_vert + dx, curr_horz + dy]

      moves << target if valid_move?([dx, dy], target, game_board)
    end

    moves
  end

  def valid_moves(game_board)
    valid_moves = moves(game_board)
    valid_moves.select do |move|
      !game_board.check?(@color, @pos, [move[0], move[1]])
    end
  end

  def valid_move?(offset, target, game_board)
    offset_vert, offset_horz = offset
    target_vert, target_horz = target
    return false if target_vert < 0 || target_vert > 7 || target_horz < 0 || target_horz > 7

    if offset_horz == 0
      (1..offset_vert).each do |moves_forward|
        return false if !game_board.board[@pos[0] +  moves_forward][@pos[1]].nil?
      end
    end

    true
  end
end



class Array
  def deep_dup
    duped_array = []
    self.each_with_index do |el, idx|
      if el.is_a?(Array)
        duped_array << el.deep_dup
      elsif el.is_a?(Piece)
        duped_piece = el.dup
        duped_pos = el.pos.dup
        duped_piece.pos = duped_pos
        duped_array << duped_piece
      else
        duped_array << nil
      end
    end
    duped_array
  end
end


class InvalidMoveError < StandardError
  def initialize
    puts "Invalid move. Please reenter a move:"
  end
end

chess = Game.new
chess.play