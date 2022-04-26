module CheckInput
  def check_token(token, prompt)
    case false
    when length?(token, 1)
      puts 'Token must be only one character'
      ask_and_check(prompt, :check_token)
    when not_number?(token)
      puts 'Token can not be a number'
      return ask_and_check(prompt, :check_token)
    end
    token
  end

  def check_name(name,prompt,max_length=12)
    if length?(name,max_length)
      name
    else
      "Name must be between 1 and #{max_length} characters"
      return ask_and_check(prompt, :check_name, [max_length])
    end
  end

  def check_number(number, prompt, max = 0, min = 0)
    case false
    when number?(number)
      puts 'You must enter a valid number'
      return ask_and_check(prompt, :check_number, [max, min])
    when between?(number, max, min)
      puts "The number must be between #{min} and #{max}"
      return ask_and_check(prompt, :check_number, [max, min])
    end
    number
  end

  def check_input(input, prompt, expects, modify = false)
    if modify
      input = method(modify).call(input)
    end
    if expects.include?(input)
      input
    else
      puts 'Incorrect Input'
      return ask_and_check(prompt, :check_input, [expects, modify])
    end
    input
  end

  def length?(subject, max, min = 1)
    subject.length <= max && subject.length >= min
  end

  def between?(subject, max, min = 1)
    subject = subject.to_i
    subject <= max && subject >= min
  end

  def call_downcase(subject)
    subject.downcase
  end

  def number?(subject)
    subject =~ /[0-9]/
  end

  def not_number?(subject)
    !number?(subject)
  end

  def ask_and_check(prompt, check, arguments = false)
    print prompt
    input = gets.strip
    if arguments
      method(check).call(input, prompt, *arguments)
    else
      method(check).call(input, prompt)
    end
  end
end

=begin
used to troubleshoot methods
class Test
  include CheckInput
  def run
    check_number('3', 'Please select number: ', 10, 2)
    check_token('@', 'Please select token: ')
    check_token('2', 'Please select token: ')
    check_number('@', 'Please select number: ', 10, 2)
    check_number('2', 'Please select number: ', 10, 2)
    check_input('y', 'Play again? (y/n)', ['y', 'n'])
    check_input('n', 'Play again? (y/n)', ['y', 'n'])
    check_input('Y', 'Play again? (y/n)', ['y', 'n'])
  end
end

check = Test.new
check.run
=end
