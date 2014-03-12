# encoding: UTF-8

# TODO: Write the document
class Table
	def initialize(arg=nil)
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
		
		when nil
		
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
	
	def merge(t2)
		t3 = Table.new
		index_1 = @index
		index_2 = t2.instance_variable_get(:@index)
		col_index_1 = @col_index
		col_index_2 = t2.instance_variable_get(:@col_index)
		table_1 = @table
		table_2 = t2.instance_variable_get(:@table)
		# index union
		index_3 = index_1 | index_2
		# rearrange column index 
		col_index_3 = {}
		col_index_1.each { |k,v| col_index_3[k] = v }
		size = col_index_1.length
		i = -1
		col_index_2.each do |k,v|
			unless col_index_3.has_key?(k)
				col_index_3[k] = size + i
				i += 1
			end
		end
		# create empty table
		table_3 = {}
		size = col_index_3.length - 1
		index_3.each { |i| table_3[i] = Array.new(size, "") }
		# fill table_3 with table_1
		index_1.each do |i|
			col_index_1.each do |k,v|
				table_3[i][col_index_3[k]] = table_1[i][v] if v != :key
			end
		end
		# fill table_3 with table_2
		index_2.each do |i|
			col_index_2.each do |k,v|
				table_3[i][col_index_3[k]] = table_2[i][v] if v != :key
			end
		end
		t3.instance_variable_set(:@table, table_3)
		t3.instance_variable_set(:@index, index_3)
		t3.instance_variable_set(:@col_index, col_index_3)
		t3
	end
	
	def select_row(r_array)
		t2 = Table.new
		index_2 = r_array & @index
		col_index_2 = @col_index
		table_2 = {}
		index_2.each { |r| table_2[r] = @table[r] }
		t2.instance_variable_set(:@table, table_2)
		t2.instance_variable_set(:@index, index_2)
		t2.instance_variable_set(:@col_index, col_index_2)
		t2
	end
	
	def select_col(c_array)
		t2 = Table.new
		index_2 = @index
		col_index_2 = {}
		i = 0
		c_array.each do |c|
			if @col_index.has_key?(c)
				col_index_2[c] = i
				i += 1
			end
		end
		table_2 = {}
		index_2.each do |i|
			table_2[i] = []
			col_index_2.each do |k,v|
				table_2[i][v] = @table[i][@col_index[k]]
			end
		end
		# add id name
		@col_index.each { |k,v| col_index_2[k] = v if v == :key }
		t2.instance_variable_set(:@table, table_2)
		t2.instance_variable_set(:@index, index_2)
		t2.instance_variable_set(:@col_index, col_index_2)
		t2
	end
	
	def export(file)
		File.open(file, "w") do |fout|
			tmp = {}
			@col_index.each { |k,v| tmp[v] = k }
			title = []
			0.upto(@col_index.length-2) { |i| title.push(tmp[i]) }
			fout.puts tmp[:key]+"\t"+title.join("\t")
			@index.each { |i| fout.puts i+"\t"+@table[i].join("\t") }
		end
	end
	
end

