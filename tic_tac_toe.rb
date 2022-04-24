require 'set'

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
      # row 1 index 0 width 3 => (3*1)-0 => 3 
      # row 1 => [3,2,1].reverse => [1,2,3]
    end
    board.reverse
  end

  def get_all_diagonals
    #How do I make this more readable?
    diagonals = []
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


  public
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
    @tokens = []
    super register_player("Player1"), register_player("Player2")
    @players = [self.player1,self.player2].cycle
    @board = Board.new(board_width,board_height)
    player_turn(next_player)
  end 

  private
  def register_player(player)
    print "Name of #{player}: "
    name = gets.strip
    print "#{player}'s Marking Token: "
    token = gets.strip
    @tokens.push(token)
    Player.new(name,token)
  end
  
  def next_player
    @current_player = @players.next
    @current_player
  end

  def player_turn(player)
    @board.display
    print "#{player.name} select a square: "
    square = gets.strip
    @board.update(square,player.token)
    if game_over?()
      play_again?
    else
      player_turn(next_player)
    end
  end

  def game_over?()
    if winner?
      @board.display
      puts "#{@current_player.name} won!"
      @current_player.record[:won] += 1
      true
    elsif draw?
      @board.display
      puts "It was a draw."
      true
    else
      false
    end
  end

  def winner?(match=3)
    for path in @board.paths
      if path.count(@current_player.token) == match
        return true
      end
    end
    false
  end

  def draw?()
    board = @board.paths.flatten.to_set
    for token in @tokens
      board.map! {|x| x == token ? "" : x}
    end
    board.all?("")
  end

  def play_again?
    
  end
end

### Troubleshooting and testing below

### Test start_game
test_game = Session.new()


#=>
=begin
 7 | 8 | 9 
---|---|---
 4 | 5 | 6 
---|---|---
 1 | 2 | 3 
=end