# HANGMAN

class Game
	require 'yaml'

	attr_reader :name

	def initialize
		@name = Time.now
		@dictionary = IO.readlines('5desk.txt').map { |word| word.downcase.chomp }
		@tries_left = 10
		@used = []
		@saved = false
	end

	def play_ai
		
		turn = 0
		puts "\nEnter 'save' at anytime to save the game"
		puts "Press enter when you're ready to start"
		gets
		choose_word

		loop do
			turn += 1

			info(turn)
			puts "(Enter)"
			gets

			break if over?(true)

			ai

			break if @saved

		end
	end

	def play
		turn = 0
		puts "\nEnter 'save' at anytime to save the game"
		puts "Press enter when you're ready to start"
		gets
		random_word

		loop do

			turn += 1

			info(turn)

			break if over?

			ask_input

			break if @saved
		end
	end

	private

	def choose_word
		begin
			puts "Enter a word : "
			@word = gets.chomp.downcase
			@word_arr = Array.new(@word.size, "_")
			if @dictionary.none? { |w| w.chomp.downcase == @word }
				raise "The word you chose isn't in the dictionary"
			elsif @word.size < 5 || @word.size > 12
				raise "The word needs to be between 5 and 12 characters"
			end
		rescue Exception => e
			puts "#{e}, please retry"
			retry
		end
	end

	def ai
		
		@dictionary.select! { |word| check_size(word) && check_letters(word) }

		best_move = highest_frequency

		puts "The computer chose #{best_move}"
		check(best_move)

	end

	def check_size(word)
		return word.size == @word_arr.size
	end

	def check_letters(word)
		word.split("").each_with_index do |letter, i|
			unless letter == @word_arr[i] || @word_arr[i] == "_"
				return false
			end
		end
		if word.split("").any? { |letter| @used.include?(letter) }
			return false
		end
		return true 
	end

	def highest_frequency
		letter_frequency = Hash.new { |hash, key| hash[key] = 0 }
		@dictionary.each do |word|
			word.split("").each do |letter|
				letter_frequency[letter] += 1 unless @word_arr.include?(letter)
			end
		end
		return letter_frequency.key(letter_frequency.values.max) unless @dictionary.size == 1
		return @dictionary[0]
	end

	def ask_input
		begin
			puts "Enter a letter : "
			input = gets.chomp.downcase
			if input == "save"
				save
			elsif @used.include?(input) || @word_arr.include?(input)
				raise "Letter '#{input}' has already been used"
			elsif input.size != 1
				unless input.size == @word.size
					raise "Please enter one letter at a time or try to guess the word" 
				end
			end
			check(input) unless input == "save"
		rescue Exception => e
			puts "#{e}, please retry"
			sleep 0.5
			retry
		end
	end

	def info(turn)
		print `clear`
		puts "Turn #{turn} \n"
		puts "Tries left : #{@tries_left}\n"
		unless @used.empty?
			puts "Used letters : "
			@used.each do |chr|
			print "#{chr}\t"
			end
			print "\n"
		end
		puts "Word so far : "
		puts @word_arr.join(" ")
	end

	def over?(ai = false)

		if @word_arr.join("") == @word
			if ai
				puts "The computer found the hidden word, you lose..."
			else
				puts "Congratulations you found the hidden word!"
			end
			delete
			return true
		elsif @tries_left < 1
			if ai
				puts "You fooled the computer, congrats!"
			else
				puts "What a bummer, you lose..." 
				puts "The word was #{@word}"
			end
			delete
			return true
		end

		return false

	end

	def random_word
		@word = ""
		until (5..12) === @word.size
			@word = @dictionary[(rand * @dictionary.size).round].strip.downcase
		end
		@word_arr = Array.new(@word.size, "_")
	end

	def check(input)
		good_guess = false
		if input.size == 1
			@word_arr.each_with_index do |chr, i|
				if input == @word[i]
					@word_arr[i] = input
					good_guess = true
				end
			end
		elsif input.size == @word.size
			if input == @word
				@word_arr = @word.split("")
				good_guess = true
			end
		end
		if good_guess
			puts "Nice!"
			sleep 0.8
		else
			@used.push(input)
			puts "Nope!"
			sleep 0.8
			@tries_left -= 1
		end
	end

	def save
		puts "What do you want to name this file? (You can leave this empty)"
		name_game = gets.chomp.downcase
		unless name_game.empty?
			@name = name_game
		end
		$/ = "--_--"
		File.open("save_files/save_#{@name}", "w") do |f|
			YAML.dump(self, f)
		end
		@saved = true
	end

	def delete
		Dir.glob("save_files/*").each do |file|
			filename = file.scan(/save_files\/save_(.*)/).flatten[0]
			if filename == @name
				File.delete(file)
			end
		end
	end

end

class Hangman
	require 'yaml'
	def self.start_game
		saves = Dir.glob("save_files/*")
		if saves.size > 0
			puts "\nDo you want to load a previous game? (y/n)"
			input = gets.chomp.downcase
			if input == "y"
				return Hangman.load_game
			end
		end
		return Game.new
	end

	def self.load_game
		saves = Dir.glob("save_files/*")
		saves.each_with_index do |file, i|
			name = file.scan(/save_files\/save_(.*)/).flatten[0]
			puts "#{i + 1}. #{name}"
		end
		choice = gets.chomp.downcase.to_i - 1
		File.open(saves[choice], 'r') do |f|
			YAML.load(f)
		end
	end

end

puts `clear`
puts "Let's play Hangman!"
again = true
while again
	game = Hangman.start_game
	puts "Who guesses the word?"
	puts "1. The computer"
	puts "2. You"
	mode = gets.chomp
	if mode == "1"
		game.play_ai
	else
		game.play
	end
	puts "Play again? (y/n)"
	user = gets.chomp.downcase
	if user == "y"
		again = true
	else
		again = false
	end
end
