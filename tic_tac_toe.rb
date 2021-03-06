require 'set'
require_relative 'CheckInput'

class TicTacToe
  include CheckInput
  attr_reader :players, :tokens

  def initialize
    @tokens = []
    @players = []
    add_players
    @session = Session.new(self)
  end

  private

  def add_players
    puts '-- Player Registration --'
    print 'How many players? (2-6)'
    player_count = gets.strip.to_i
    player_count = check_number(player_count, 6, 2)
    for i in 1..player_count
      @players.append(register_player(i))
    end
  end

  def register_player(number)
    name = ask_and_check("Name of Player#{number}: ", :check_name)
    token = ask_and_check("Player#{number}'s Marking Token: ", :check_token)
    @tokens.push(token)
    Player.new(name,token)
  end

  def yes?(answer)
    answer == 'y'
  end

  public

  def log_win_loss(winner)
    losers = @players.reject{|x| x == winner}
    winner.record[:won] += 1
    for loser in losers
      loser.record[:lost] += 1
    end
  end

  def log_draw
    for player in @players
      player.record[:draw] += 1
    end
  end

  def game_over
    answer = ask_and_check(
      'Rematch with same players? (y/n) ', 
      :check_input, 
      [%w[y n], :call_downcase])
    if yes?(answer)
      @session = Session.new(self)
    end
  end
end

class Player
  attr_reader :name, :token, :record

  def initialize(name,token)
    @name = name
    @token = token
    @record = { won: 0, lost: 0, draw: 0}
  end
end

class Board
  attr_reader :width, :height, :board, :rows, :columns, :diagonals, :paths

  def initialize(width,height)
    @width = width
    @height = height
    @board = create(width,height)
  end

  private

  def create(width,height)
    board = []
    for row in 1..height
      board.push Array.new(width) {|index| ((width*row)-index).to_s}.reverse
      # 3 width 3 row 1
      #index 0 => (3*1)-0 => 3
      #index 1 => (3*1)-1 => 2
      # row 1 => [3,2,1].reverse => [1,2,3]
      # 3x3 [[1,2,3],[4,5,6],[7,8,9]]
    end
    board.reverse
    # 3x3 [[7,8,9],[4,5,6],[1,2,3]]
  end

  def large_board?(width, height)
    width*height >= 10
  end

  def get_all_diagonals
    #I could use some advice on making this more readable
    diagonals = []
    for i in 0...@height
      back_slash = [] # diagonals in \ direction
      forward_slash = [] #diagonals in / direction
      for j in 0...@width
        back_slash.push(@board[i+j][j]) if (i+j) < @height 
        #as i stays the same j moves the selection down for every move to the right \
        forward_slash.push(@board[i-j][j]) if (i-j) >= 0
        #as i stays the same j moves the selction up for every move right /
        if i == @height-1 || i == 0
          # if top or bottom row
          secondary_back_slash = []
          secondary_forward_slash = []
          for k in 0...@width
            if i == 0 && j > 0 
              #only collects diagonals from the top row that are not the first column
              secondary_back_slash.push(@board[i+k][j+k]) if (i+k)<@height && (j+k)<@width
              # i and j set the starting point from the top row and k moves the selection
              # down and to the right once an iteration \
            elsif i == @height-1 && j > 0
              #only collects diagonals from the bottom row that are not the first column
              secondary_forward_slash.push(@board[i-k][j+k]) if (i-k) >= 0 && (j+k) < @width
              # i and j set the starting point from the bottom row and k moves the selection
              # up and to the right once an iteration /
            end
          end
          diagonals.push(secondary_back_slash) unless secondary_back_slash.empty?
          diagonals.push(secondary_forward_slash) unless secondary_forward_slash.empty?
        end
      end
      diagonals.push(back_slash,forward_slash)
    end
    diagonals
  end

  def get_basic_diagonals
    back_slash = []
    forward_slash = []
    for i in 0...@height
      back_slash.push(@board[i][i])
      forward_slash.push(@board[i][-1-i])
    end
    [back_slash,forward_slash]
  end

  def format_square_value(square)
    # if the board includes double digts
    # add a space before single digit values
    if large_board?(@width, @height) && (square.to_i < 10 || @tokens.include?(square))
      " #{square}"
    else
      square
    end
  end

  public

  def log_tokens(tokens)
    @tokens = tokens
  end

  def update(square,token)
    for row in @board
      index = row.index(square)
      row[index] = token if index
    end
    @rows = @board
    @columns = @board.transpose
    @diagonals = get_all_diagonals
    @diagonals_basic = get_basic_diagonals
    @paths = [*@rows,*@columns,*@diagonals]
  end

  def open_squares(tokens)
    squares = @board.clone.flatten
    for token in tokens
      squares.delete(token)
    end
    squares
  end

  def display
    display_board = []
    spacer = large_board?(@width,@height) ? '----' : '---' 
    # extra spacer to account for squares with double digit numbers
    @board.each_with_index do |inner_array, index|
      square = format_square_value(inner_array[0])
      display_board.push "\t #{square} " # first column value

      width = inner_array.length
      for i in 1...inner_array.length
        square = format_square_value(inner_array[i])
        display_board.push "| #{square} " # values in row index after first column value
      end
      display_board.push("\n\t#{spacer}" + "|#{spacer}"*(width-1) + "\n") unless index == width - 1
      #row spacer ---|---|---
    end

    puts display_board.join
  end
end

class Session
  include CheckInput
  def initialize(game)
    @game = game
    @cycle_players = game.players.cycle
    setup_board
    player_turn(next_player)
  end

  private

  def setup_board
    puts '--Game Board Setup--'
    columns = ask_and_check(
      'How many columns on the game board? (3-9)',
      :check_number,
      [9, 3]
    ).to_i

    rows = ask_and_check(
      'How many rows on the game board? (3-9)',
      :check_number,
      [9, 3]
    ).to_i

    max = [columns, rows].max
    @match = ask_and_check(
      "How many in a row to win? (3-#{max})",
      :check_number,
      [max, 3]
    ).to_i

    @board = Board.new(columns,rows)
    @board.log_tokens(@game.tokens)
  end

  def next_player
    @current_player = @cycle_players.next
    @current_player
  end

  def player_turn(player)
    @board.display
    square = ask_and_check(
      "#{player.name} select a square: ",
      :check_input,
      [@board.open_squares(@game.tokens)]
    )

    @board.update(square,player.token)
    if game_over?
      @game.game_over
    else
      player_turn(next_player)
    end
  end

  def game_over?
    if winner?
      @board.display
      puts "#{@current_player.name} won!"
      @game.log_win_loss(@current_player)
      true
    elsif draw?
      @board.display
      puts 'It was a draw.'
      @game.log_draw
      true
    else
      false
    end
  end

  def winner?
    for path in @board.paths
      for i in 0..path.length-@match
        if path.slice(i,@match).all?(@current_player.token)
          return true
        end
      end
    end
    false
  end

  def draw?
    @board.open_squares(@game.tokens).empty?
  end
end

TicTacToe.new
