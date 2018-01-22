require_relative "interpreter"

class IMS
	# prompt for command input
	PROMPT = "ims> "   

	def initialize
		@runnable = true
    @input = ""
	end

	attr_accessor :runnable
  attr_accessor :input
	
	def main
		# greeting
		puts """
		******************************************************
			Welcome to use Interactive music shell
		******************************************************
		######## use 'Help' to get a list of commands ########"""

		# initialize new processor
		interpreter = Interpreter.new

		# Main execution from here
		while @runnable
			# request user to input command
			print PROMPT
			@input = $stdin.gets.chomp.to_s

			# interpret input and represent result message
			@runnable, msg = interpreter.interpret(@input)
			if msg != nil then puts msg end
		end
	end

	imsShell = IMS.new
	imsShell.main

end
