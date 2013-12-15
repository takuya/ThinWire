#!/usr/bin/env ruby 
# coding : utf-8

require 'stringio'

require 'mail'


class ThinWire
	attr_accessor :last_hash,:target_dir,:report


	def initialize(target="/etc")
		@target_dir = target
		@target_dir = @target_dir+"/" unless @target_dir =~ /\\$/
		@last_hash = {}
		@report = Proc.new{|msg| puts msg}
	end
	def start
		self.thread.join();
	end
	def make_hash_list
		str = `find '#{self.target_dir}' -type f -exec md5sum {} \\; 2>/dev/null `
		hash = Hash[*str.split]
		hash.invert
	end

	def thread
		Thread.new{
			current = self.make_hash_list
			last_hash = current 
			loop{
				sleep 1;
				current = self.make_hash_list
				# puts (current.keys - last_hash.keys ).inspect
				#puts current["a"]
				alert(current.clone,last_hash.clone) unless current == last_hash
				last_hash = current 
				#puts :wake			
			}
		}
	end
	def alert(new_hash, old_hash)
		Thread.new{
			##新規追加されたファイル => new で増えたkey がある。
			add_files = Hash[*(new_hash.keys - old_hash.keys).map{|e| [e,new_hash[e]]}.flatten]
			##削除されたファイル => new でなくなった key
			del_files = Hash[*(old_hash.keys - new_hash.keys).map{|e| [e,old_hash[e]]}.flatten]
			##編集されたファイル => hash が違う
			mod_files = old_hash.select{|e| old_hash[e] != new_hash[e] }
			call_report( add_files,del_files,mod_files )
		}
	end
	def call_report( add_files,del_files,mod_files )
		message = StringIO.new
		
		message.puts "ファイルの改変がありました。\n"
		message.puts "-"*10
		message.puts "\n"
		unless add_files.empty? then
			message.puts "\n"
			message.puts "「追加」されました。\n"
			message.puts  add_files.map{|k,v|"#{v} => #{k}"}.join("\n")
			message.puts "\n"
			message.puts "-"*10
			message.puts "\n"
		end
		unless del_files.empty? then
			message.puts "\n"
			message.puts "「削除」されました。\n"
			message.puts  del_files.map{|k,v|"#{v} => #{k}"}.join("\n")
			message.puts "\n"
			message.puts "-"*10
			message.puts "\n"
		end
		unless mod_files.empty? then
			message.puts "\n"
			message.puts "「更新」されました。\n"
			message.puts  mod_files.map{|k,v|"#{v} => #{k}"}.join("\n")
			message.puts "\n"
			message.puts "-"*10
			message.puts "\n"
		end
		message.rewind
		self.report.call(message.read)
	end

end




