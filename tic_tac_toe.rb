class TicTacToe
  #Is this unnecessary?
  attr_reader :player1, :player2
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
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
  attr_reader :width, :height, :board
  def initialize(width,height)
    @width = width
    @height = height
    @board = create(width,height)
    @rows = @board
    @columns = @board.transpose
    @diagonals = get_all_diagonals
    @diagonals_basic = get_basic_diagonals 
  end

  private
  def create(width,height)
    board = []
    for row in 1..height
      board.push Array.new(width) {|index| ((width*row)-index).to_s}.reverse
      # row 1 index 0 width 3 => (3*1)-0 => 3 
      # row 1 => [3,2,1].reverse => [1,2,3]
    end
    board.reverse
  end

  def get_all_diagonals
    diagonals = []
    backslashes = []
    forwardslashes = []
    for i in 0...@height
      back_slash = []
      forward_slash = []
      for j in 0...@width
        back_slash.push(@board[i+j][j]) if (i+j) < @height
        forward_slash.push(@board[i-j][j]) if (i-j) >= 0
        if i == @height-1 || i == 0
          secondary_back_slash = []
          secondary_forward_slash = []
          for k in 0...@width
            if i == 0 && j > 0
              secondary_back_slash.push(@board[i+k][j+k]) if (i+k)<@height && (j+k)<@width
            elsif i == @height-1 && j > 0
              secondary_forward_slash.push(@board[i-k][j+k]) if (i-k) >= 0 && (j+k) < @width
            end
          end
          diagonals.push(secondary_back_slash) unless secondary_back_slash.empty?
          diagonals.push(secondary_forward_slash) unless secondary_forward_slash.empty?
        end
      end
      diagonals.push(back_slash,forward_slash)
    end
    p diagonals
    diagonals
  end

  def get_basic_diagonals
    back_slash = []
    forward_slash = []
    for i in 0...@height
      back_slash.push(@board[i][i])
      forward_slash.push(@board[i][-1-i])
    end
    puts "Basic Diagonals"
    p [back_slash,forward_slash]
    [back_slash,forward_slash]
  end


  public
  def update(square,token)
    for row in @board
      index = row.index(square)
      row[index] = token if index
    end
  end

  def display
    board = []
    @board.each_with_index do |sub_array, index|
      width = sub_array.length
      board.push "\t #{sub_array[0]} "
      for i in 1...sub_array.length
        board.push "| #{sub_array[i]} "
      end
      board.push "\n\t---" + "|---"*(width-1) + "\n" unless index == width-1
    end
    puts board.join()
  end
end

class Session < TicTacToe
  def initialize(board_width=3,board_height=3)
    super register_player("Player1"), register_player("Player2")
    #Can't figure out how to enter get prompts in debug console
    #super Player.new("jack","x"), Player.new("jill","o")
    @board = Board.new(board_width,board_height)
    player_turn(self.player1)
  end 

  private
  def register_player(player)
    print "Name of #{player}: "
    name = gets.strip
    print "#{player}'s Marking Token: "
    token = gets.strip
    Player.new(name,token)
  end

  def player_turn(player)
    self.print_board()
    print "#{player.name} select a square: "
    square = gets.strip
    @board.update(square,player.token)
    check_for_winner(player)
  end

  def check_for_winner(player,match=3)
    for row in @board.board
      puts "#{player.name} won!" if row.all?(player.token)
    end
  end

  public
  def print_board
    @board.display
  end
end

### Troubleshooting and testing below

### Test start_game
test_game = Session.new()
puts test_game.print_board()

#=>
=begin
 7 | 8 | 9 
---|---|---
 4 | 5 | 6 
---|---|---
 1 | 2 | 3 
=end