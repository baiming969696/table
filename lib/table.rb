# encoding: UTF-8

# TODO: Write the document
class Table
	def initialize(arg)
		case arg
		when String
			fin = File.open(arg)
			
			# Headline
			@col_index = {}
			tmp_col_index = fin.readline.chomp.split(/\t/)
			raise ArgumentError, "Duplicated column names" if tmp_col_index != tmp_col_index.uniq
			tmp_col_index.each_with_index { |n, i| @col_index[n] = i>0 ? i-1 : :key }
			
			# Table content
			@table = {}
			col_size = @col_index.length
			fin.each_with_index do |line, line_index|
				tmp = (line.chomp+"\tTAIL").split(/\t/)
				tmp.pop
				raise ArgumentError, "Row size inconsistent in line #{line_index+2}" if tmp.length != col_size
				
				key = tmp.shift
				raise ArgumentError, "Duplicated primary key: #{key}" if @table[key]
				@table[key] = tmp
			end
			@index = @table.keys
			
		when Table
		
		else
			raise ArgumentError
		end			
	end
	
	# @overload col_index
	#   Return the names of columns
	# @overload col_index(key)
	#   Return the index of column +key+
	def col_index(key = nil)
		key ? @col_index[key] : @col_index
	end
	
	def keys
		@index
	end
	
	def row(id)
		@index.include?(id) ? @table[id] : nil
	end
	
	def col(col_name)
		if @col_index.has_key?(col_name)
			hash = {}
			location = @col_index[col_name]
			@table.each { |k, v| hash[k] = v[location] }
			return hash
		else
			raise ArgumentError, "No such column"
		end
	end
	
end
