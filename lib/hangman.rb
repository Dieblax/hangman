# HANGMAN
class Hangman

	def initialize
		@word = random_word
		@word_arr = Array.new(@word.size, "_")
		@tries_left = 6
		@used = []
	end

	def play
		puts `clear`
		puts "Let's play Hangman!".rjust(80, ' ')
		turn = 0

		loop do

			turn += 1

			info(turn)

			break if over?

			p @word
			ask_input
		end
	end

	private

	def ask_input
		begin
				puts "Enter a letter : "
				letter = gets.chomp.downcase
				if @used.include?(letter)
					raise "Letter '#{letter}' has already been used"
				end
				check(letter)
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

	def over?

		if @word_arr.join("") == @word
			puts "Congratulations you found the hidden word!"
			return true
		elsif @tries_left == 0
			puts "What a bummer, you lose..."
			puts "The word was #{@word}"
			return true
		end

		return false

	end

	def random_word
		@dictionary = IO.readlines('../5desk.txt')
		@dictionary[(rand * @dictionary.size).round].strip.downcase
	end

	def check(letter)
		good_guess = false
		@word_arr.each_with_index do |chr, i|
			if letter == @word[i]
				@word_arr[i] = letter
				good_guess = true
			end
		end
		if good_guess
			puts "Nice!"
		else
			@used.push(letter)
			puts "Wrong letter!"
			@tries_left -= 1
		end
	end

end

hangman = Hangman.new
hangman.play

