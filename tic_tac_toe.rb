class TicTacToe
  attr_reader :player1, :player2
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
  end
  
  def print_board(array,width = 3)
    #would it be better/easier to handle a nested array?
    board = []
    h_spacer = "\t---" + "|---"*(width-1) + "\n"
    array.each.with_index(1) do |value, index|
      case true
      when index%width == 1 
        board.push("\t #{value} ")
      when index%width == 0 && index < array.length
        board.push("| #{value} \n" + h_spacer)
      else
        board.push("| #{value} ")
      end
    end
    puts board.join()
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

class Session < TicTacToe
  def initialize(board_size=[3,3])
    super register_player("Player1"), register_player("Player2")
    @board_size = board_size
  end 

  private
  def register_player(player)
    print "Name of #{player}: "
    name = gets.strip
    print "#{player}'s Marking Token: "
    token = gets.strip
    Player.new(name,token)
  end
end

### Troubleshooting and testing below

### Test start_game
test_game = Session.new()
p test_game
puts test_game.player1.name
puts test_game.player1.token


### Test fill_board
game = TicTacToe.new("a","b")
board = game.print_board([7,8,9,4,5,6,1,2,3])

#=>
=begin
 7 | 8 | 9 
---|---|---
 4 | 5 | 6 
---|---|---
 1 | 2 | 3 
=end
