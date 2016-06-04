# class RubyInterpreter
#
# Very simple class which eval the input it receives on a given context and supports partial instructions

class RubyInterpreter
	attr_reader :level, :input
	attr_accessor :context

	# List of words that, if they appear at the beginning of an expression 
	# (ie preceded by nl '\n' or semicolon ';') mark a new level of indentation
	# 'do' can appear anywhere and is therefore not part of the list
	LEVEL_WORD_LIST = %w{ begin case class def if module unless until while }.join('|')
	LEVEL_UP = /^\s*(#{LEVEL_WORD_LIST})\s|\sdo\s/

	# Ctor
	# Takes the context the code should be executed in. If no argument is provided, defaults to the top level
	def initialize c = TOPLEVEL_BINDING
		@context = c
		@level = 0
	end

	# Runs a string given in input as Ruby code or buffers it if the command is incomplete
	# Test against level or input to check if the command has been executed
	def run str
		@input ||= ''
		@level += str.scan(LEVEL_UP).length
		@level -= str.scan(/(^|\s)end($|\s)/).length # Will probably fail with a character chain
		@input += str + "\n"
		if @level <= 0	
			tmp = input
			reset
			eval tmp, context 
		end
	end

	def reset 
		@input = nil
		@level = 0
	end

	def reset?
		level == 0 and input.nil?
	end
end

