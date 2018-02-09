#!/usr/bin/ruby

###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Max Weimer
# maxsw16@gmail.com
#
###############################################################

$bigrams = Hash.new # The Bigram data structure
$name = "Max Weimer"

def cleanup_title(line)
	# {3} denotes which index of separator to capture after
	title_match = /^(?:[^>]*>){3}([^<]*)/.match(line)
	if title_match.nil?
		return nil
	end

	# Get title from match
	title = title_match[1].downcase
	# Filter out extra text
	title = title.sub(/[(\[{\\\/_\-:"`+=*].*|feat\..*/, "")
	# Filter out punctuation
	title = title.gsub(/[?¿!¡.;&@%#|]/, "")
	# Filter out stop words
	title = title.gsub(/\ba\b|\ban\b|\band\b|\bby\b|\bfor\b|\bfrom\b|\bin\b|\bof\b|\bon\b|\bor\b|\bout\b|\bthe\b|\bto\b|\bwith\b/, "")
	# Filter out double, leading and trailing spaces left over by the above line
	title = title.gsub(/\s+/, " ").sub(/^\s+/, "").sub(/\s+$/, "")


	# Return only latin only titles
	latin_validate_match = /^[\w\s']+$/.match(title)
	if latin_validate_match
		title
	else
		nil
	end
end

def mcw(word)
	# Word doesn't exist? Return nil
	if $bigrams[word].nil?
		return nil
	end

	# Get the map of all the words that follow the word we're looking for
	count_map = $bigrams[word]

	# Setup measuring tools to get the maximum count
	highest_key = nil
	highest_value = -1
	for key, value in count_map
		if value >= highest_value
			highest_key = key
			highest_value = value
		end
	end

	highest_key
end

def create_title(start_word)
	most_likely_title = start_word

	last_word = start_word
	for i in 1..19
		# Get the next most common word from the last word
		current_word = mcw(last_word)
		# No word ever appears after the current word, nothing to do here, break
		if current_word.nil?
			break
		end

		# If the word is already in the title, stop
		if /\b#{current_word}\b/.match(most_likely_title)
			break
		end

		# Append the current word to the end of the title
		most_likely_title += " #{current_word}"
		last_word = current_word
	end

	most_likely_title
end

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	#begin
		IO.foreach(file_name) do |line|
			# parse out the title from the raw data file
			clean_title = cleanup_title(line)

			# check if the title was rejected
			if not clean_title.nil?
				#puts clean_title
				# space delimited split to get individual words
				title_words = clean_title.split(' ')
				for i in 0..title_words.length-2
					# If there isn't a hashmap for occurrences of the current word, create one
					if $bigrams[title_words[i]].nil?
						$bigrams[title_words[i]] = Hash.new(0)
					end

					# Increment the value in the hashmap for the subsequent word
					$bigrams[title_words[i]][title_words[i+1]] += 1
				end
			end
		end

		puts "Finished. Bigram model built.\n"
	#rescue
	#	STDERR.puts "Could not open file"
	#	exit 4
	#end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
end

main_loop()
