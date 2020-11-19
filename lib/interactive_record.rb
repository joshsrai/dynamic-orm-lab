require_relative "../config/environment.rb"
require 'active_support/inflector'
#https://learning.flatironschool.com/courses/2155/assignments/53900?module_item_id=103524
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end
#This method takes the name of the class, (self.) turns it into a string with #to_s, downcases that string and then "pluralizes" it.

  def self.column_names
    DB[:conn].results_as_hash = true
    #This line of code that utilizes <a href="#resources">PRAGMA</a> will return to us (thanks to  #results_as_hash method) an array of hashes describing the table itself. Each hash will contain information about one column.

    sql = "pragma table_info('#{table_name}')"
    #Here we write a SQL statement using the pragma keyword and the #table_name method (to access the name of the table we are querying). 

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
      #We iterate over the resulting array of hashes to collect just the name of each column. 
    end
    column_names.compact
    #We call #compact on that just to be safe and get rid of any nil values that may end up in our collection.
  end

  def initialize(options={})
    options.each do |property, value|
        #Here, we define our method to take in an argument of options, which defaults to an empty hash. We expect #new to be called with a hash, so when we refer to options inside the #initialize method, we expect to be operating on a hash.
      self.send("#{property}=", value)
      #We iterate over the options hash and use the #send method to interpolate the name of each hash key as a method that we set equal to that key's value. As long as each property has a corresponding attr_accessor, this #initialize method will work.
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    #the conventional #save is an instance method. So, inside a #save method, self will refer to the instance of the class, not the class itself. In order to use a class method inside an instance method to access the table name we want to INSERT into from inside our #save method, we will use the following
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
  DB[:conn].execute(sql, name)
end

def  self.find_by(x)
    column = x.keys[0].to_s
    value = x.values[0]
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{column} = ?", value)
end

end