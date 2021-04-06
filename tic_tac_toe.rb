INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
ROUNDS = 5
WIN_MESSAGE = ['W', 'I', 'N']
TURN_ORDER = { player: false, computer: false, choose: true }
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]

def prompt(message)
  puts ">> #{message}"
end

def welcome
  system 'clear'
  prompt("Welcome to Tic Tac Toe. First to #{ROUNDS} wins will be the grand champion!")
end

def display_scores(game_scores)
  system 'clear'
  puts "You: #{PLAYER_MARKER} ___ Score: #{game_scores[:player]}"
  puts "Computer: #{COMPUTER_MARKER} ___ Score: #{game_scores[:computer]}"
end

def display_board(board)
  puts ""
  puts "     |     |     "
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}   "
  puts "     |     |     "
  puts "-----+" * 2 + "-----"
  puts "     |     |     "
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}   "
  puts "     |     |     "
  puts "-----+" * 2 + "-----"
  puts "     |     |     "
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}   "
  puts "     |     |     "
  puts ""
end

def display(board, scores)
  display_scores(scores)
  display_board(board)
end

def scores
  { player: 0, computer: 0 }
end

def user_chooses_order
  loop do
    prompt("Please select who goes first (c for computer, p for player)")
    choice = gets.chomp.downcase
    return 'Computer' if choice == 'c'
    return 'Player' if choice == 'p'
    prompt("Sorry, that's not a valid option")
  end
end

def determine_first_mover
  return "Player" if TURN_ORDER[:player]
  return "Computer" if TURN_ORDER[:computer]
  user_chooses_order if TURN_ORDER[:choose]
end

def set_up
  [determine_first_mover, scores]
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def join_or(array, delim = ',', oxford = 'or')
  final = ""
  return array.first.to_s if array.length == 1
  array.each_with_index do |num, index|
    str_num =
      index == array.size - 1 ? oxford + ' ' + num.to_s : num.to_s + delim + ' '
    final << str_num
  end
  final
end

def empty_squares(board)
  board.keys.select { |num| board[num] == INITIAL_MARKER }
end

def validate_user_choice(board)
  loop do
    square = gets.chomp
    square = square.to_i if square == square.to_i.to_s
    return square if empty_squares(board).include?(square)
    display_invalid_square_choice(board, square)
  end
end

def display_invalid_square_choice(board, square)
  if board[square].nil?
    puts "Sorry, that's not a square on the board! Please try again"
  else
    puts "Oops, that square has already been chosen. Please try again"
  end
end

def player_places_piece!(board)
  prompt("Choose a square: ")
  prompt(join_or(empty_squares(board)))
  square = validate_user_choice(board)
  board[square] = PLAYER_MARKER
end

def track_moves(board)
  positions = {}
  WINNING_LINES.each do |line|
    positions[line] = [board[line[0]], board[line[1]], board[line[2]]]
  end
  positions
end

def determine_opportunities_threats(round_status)
  final = []
  parties = [COMPUTER_MARKER, PLAYER_MARKER]
  parties.each do |marker|
    opp_threat = round_status.find do |_k, v|
      v.count(marker) == 2 && v.count(INITIAL_MARKER) == 1
    end
    if opp_threat
      opp_threat[1].each_index do |index|
        final << opp_threat[0][index] if opp_threat[1][index] == INITIAL_MARKER
      end
    else final << 0
    end
  end
  final
end

def computer_places_piece!(board, analysis)
  prompt("Computer is thinking ...")
  sleep(1)
  square = computer_chooses_square(board, analysis)
  board[square] = COMPUTER_MARKER
  prompt("Computer chooses square #{square}!")
end

def computer_chooses_square(board, analysis)
  if analysis.first > 0 then analysis.first
  elsif analysis.last > 0 then analysis.last
  elsif analysis.sum == 0 && board[5] == INITIAL_MARKER then 5
  else
    empty_squares(board).sample
  end
end

def board_full?(board)
  empty_squares(board).empty?
end

def someone_won?(board)
  !!detect_winner(board)
end

def record_winning_squares(board)
  winning_line = {}
  WINNING_LINES.each do |line|
    if board.values_at(*line).count(PLAYER_MARKER) == 3
      winning_line[:player] = line
    elsif board.values_at(*line).count(COMPUTER_MARKER) == 3
      winning_line[:computer] = line
    end
  end
  winning_line
end

def detect_winner(board)
  winner = record_winning_squares(board)
  return "Player" if winner[:player]
  return "Computer" if winner[:computer]
  nil
end

def track_score(board, game_scores)
  case detect_winner(board)
  when 'Player' then game_scores[:player] += 1
  when 'Computer' then game_scores[:computer] += 1
  end
end

def computer_analysis(board)
  round_status = track_moves(board)
  determine_opportunities_threats(round_status)
end

def computer_turn(board)
  computer_places_piece!(board, computer_analysis(board))
end

def place_piece!(board, current_player, game_scores)
  display(board, game_scores)
  if current_player == 'Computer'
    computer_turn(board)
  elsif current_player == 'Player'
    player_places_piece!(board)
  end
end

def alternate_player(current_player)
  return 'Computer' if current_player == 'Player'
  return 'Player' if current_player == 'Computer'
end

def display_winner(board, game_scores)
  winner = record_winning_squares(board).keys.first.to_s.capitalize
  winning_line = record_winning_squares(board).values.flatten
  update_board_for_winner(winning_line, winner, board, game_scores)
end

def update_board_for_winner(winning_line, winner, board, game_scores)
  winning_line.each_with_index do |square, index|
    prompt "#{winner} won!"
    sleep(0.5)
    board[square] = WIN_MESSAGE[index]
    display(board, game_scores)
  end
end

def end_round(board, game_scores)
  if someone_won?(board)
    track_score(board, game_scores)
    display(board, game_scores)
    display_winner(board, game_scores)
  else
    prompt "It's a tie!"
  end
  sleep(0.5)
end

def full_turn(board, current_player, game_scores)
  loop do
    place_piece!(board, current_player, game_scores)
    current_player = alternate_player(current_player)
    break if someone_won?(board) || board_full?(board)
  end
end

def game_over?(game_scores)
  game_scores.value?(ROUNDS)
end

def end_game(_game_scores)
  prompt("Great game. Thanks for playing! Goodbye.")
  sleep(0.75)
  system 'clear'
  exit
end

welcome
current_player, game_scores = set_up

loop do
  board = initialize_board
  full_turn(board, current_player, game_scores)
  end_round(board, game_scores)
  end_game(board) if game_over?(game_scores)
end
