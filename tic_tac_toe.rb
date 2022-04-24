class TicTacToe
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
  end
  def fill_board(array,width = 3)
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
    board.join()
  end
end

class Player
  def initialize(name,toekn)
    @name = name
    @token = token
  end
end

game = TicTacToe.new("a","b")
board = game.fill_board([7,8,9,4,5,6,1,2,3])
puts board
#=>
=begin
 7 | 8 | 9 
---|---|---
 4 | 5 | 6 
---|---|---
 1 | 2 | 3 
=end
