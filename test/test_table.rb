# encoding: UTF-8

# Test-framework
require 'test/unit'
require 'shoulda-context'

# Test-specific
require 'table'
require 'tempfile'

class Tabel_Test < Test::Unit::TestCase
  context "When initialized with" do
    context "duplicated columns, Table" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "ID\tA\tA\n1\tC++\tgood\n2\tRuby\tbetter\n"
        file.rewind
        assert_raise ArgumentError do
          Table.new(file.path)
		    end
        file.close!
      end
    end
  
    context "duplicated primary keys, Table" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "ID\tA\tB\n1\tC++\tgood\n1\tRuby\tbetter\n"
        file.rewind
        assert_raise ArgumentError do
          Table.new(file.path)
		    end
        file.close!
      end
    end

    context "an inconsistent-size row, Table" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "ID\tA\tA\n1\tC++\tgood\n2\tRuby\n"
        file.rewind
        assert_raise ArgumentError do
          Table.new(file.path)
		    end
        file.close!
      end
    end
  end

  context "When asked, a table" do
    setup do
      file = Tempfile.new('test')
      file.write <<-END_OF_DOC
ID\tA\tB\tC
1\tab\t1\t0.8
2\tde\t3\t0.2
5\tfk\t6\t1.9
      END_OF_DOC
      file.rewind
      @tab = Table.new(file.path)
      file.close!
    end

    should "return column names" do
      col_index = @tab.col_index
      assert_equal(@tab.col_index("ID"), :key) # Method way
      assert_equal(@tab.col_index["C"] , 2) # Hash way
    end

    should "return primary keys" do
      assert_equal(@tab.keys ,%w{1 2 5})
    end

    should "return a column" do
      assert_equal(@tab.col('A')['1'], 'ab')
      assert_equal(@tab.col('B')['5'], '6')
      assert_equal(@tab.col('C')['2'], '0.2')
    end

    should "return a row" do
      assert_equal(@tab.row('1')[1], '1')
      assert_equal(@tab.row('2')[0], 'de')
      assert_equal(@tab.row('5')[2], '1.9')
    end

    should "return selected rows as a Table" do
      tab = @tab.select_row(['2', '5'])
      assert_equal(tab.row('2')[0], 'de')
      assert_equal(tab.row('1', nil))
    end

    should "return selected columns as a Table" do
      tab = @tab.select_col(['C', 'A'])
      assert_raise ArgumentError do
        tab.col('B')
      end
      assert_equal(tab.col('C')['1'], 'ab')
      assert_equal(tab.row('1')[0], 'ab')
    end
    
    should "merge with another tablb" do
      file = Tempfile.new('test')
      file.write <<-END_OF_DOC
ID\tB\tD\tE
1\tab\t1\t0.8
2\tde\t3\t0.2
5\tfk\t6\t1.9
      END_OF_DOC
      file.rewind
      tab = @tab.merge(Table.new(file.path))
      file.close!
      assert(tab.is_a?(Table))
      assert_equal(tab.row('2')[1], 'de')
      assert_equal(tab.row('5')[3], '6')
      assert_equal(tab.col('B')['1'], 'ab')
    end
  end
end
