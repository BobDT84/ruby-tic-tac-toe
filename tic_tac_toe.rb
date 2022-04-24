class TicTacToe
  attr_reader :player1, :player2
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
  end

  def print_board(array)
    #would it be better/easier to handle a nested array?
    board = []
    array.each_with_index do |sub_array, index|
      width = sub_array.length
      board.push "\t #{sub_array[0]} "
      for i in 1...sub_array.length
        board.push "| #{sub_array[i]} "
      end
      board.push "\n\t---" + "|---"*(width-1) + "\n" unless index == array.length-1
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
  def initialize(board_width=3,board_height=3)
    super register_player("Player1"), register_player("Player2")
    @board = new_board(board_width,board_height)
  end 

  private
  def register_player(player)
    print "Name of #{player}: "
    name = gets.strip
    print "#{player}'s Marking Token: "
    token = gets.strip
    Player.new(name,token)
  end

  def new_board(width,height)
    board = []
    for row in 1..height
      board.push Array.new(width) {|index| (width*row)-index}.reverse
      # row 1 index 0 width 3 => (3*1)-0 => 3 
      # row 1 => [3,2,1].reverse => [1,2,3]
    end
    board.reverse
  end

  public
  def print_board
    super(@board)
  end
end

### Troubleshooting and testing below

### Test start_game
test_game = Session.new()
puts test_game.player1.name
puts test_game.player1.token
puts test_game.print_board()

#=>
=begin
 7 | 8 | 9 
---|---|---
 4 | 5 | 6 
---|---|---
 1 | 2 | 3 
=end