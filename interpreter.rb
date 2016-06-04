#!/usr/bin/env ruby

# TODO: abstract this from the loop, just have a function to interpret, and if nessessary store the ongoing work (levels)

class RubyInterpreter
	attr_accessor :show_return_value
	attr_writer :context
	attr_accessor :display_method, :prompt_method

	def context
		@context || TOPLEVEL_BINDING
	end
	def show_return_value b = true
		@show_return_value = b
	end
	def quit
		@run = false
	end

	def display msg
		@display_method.print msg
	end

	def prompt
		@prompt_method.gets
	end

	def show_prompter
		display ">" * @level + " "
	end

	def initialize disp = $stdout, promp = $stdin
		@display_method = disp
		@prompt_method = promp
	end

	# List of words that, if they appear at the beginning of an expression 
	# (ie preceded by nl '\n' or semicolon ';') mark a new level of indentation
	# 'do' can appear anywhere and is therefore not part of the list
	LEVEL_WORD_LIST = %w{ begin case class def if module unless until while }.join('|')
	LEVEL_UP = /^\s*(#{LEVEL_WORD_LIST})\s|\sdo\s/

	def run 
		yield self if block_given?
		@run = true
		#
		#Interpreting loop
		begin
			while @run
				input = ''
				@level = 1
				#
				#Get the user input
				loop do  
					show_prompter 
					inp = prompt
					
					@level += inp.scan(LEVEL_UP).length
					@level -= inp.scan(/(^|\s)end($|\s)/).length

					input += inp + "\n"

					break if @level <= 1
				end
				#
				# Evaluate it
				begin
					ret = eval(input, context).to_s
					if @show_return_value
						ret = 'nil' if ret == ""
						display  "=> " + ret + "\n"
					end
				rescue ScriptError => e
					display  "Syntax error: " + e.message + '\n'
				rescue SystemStackError => e
					display e.message + "\n"
					loop do
						display "Show backtrace? (y/n): "
						r = prompt.chomp 
						if r =~ /^y(es)?$/i
							display e.backtrace.to_s + "\n"
							break
						elsif r =~ /^no?$/i
							break
						end
					end
				rescue => e
					display e.message + "\n"
				end
			end
			#
			# Rescue Ctrl+C cuz I'm to lazy to type quit
		rescue Interrupt
			display "Aborting\n"
		end
	end
end

if __FILE__ == $0 
	def self.method_missing s, *args, &blck
		Interpreter.send s, *args, &blck
	end
	Interpreter = RubyInterpreter.new
	Interpreter.run do |i|
		i.show_return_value
	end
end
