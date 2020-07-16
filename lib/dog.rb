require 'pry'
class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def self.create_table
    sql = <<-S
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    S
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create(attr)
    pup = Dog.new(attr)
    pup.save
  end

  def self.find_by_id(id)
    sql = <<-S
      SELECT * FROM dogs WHERE id = ?
    S
    info = DB[:conn].execute(sql, id).flatten
    Dog.new(id: info[0], name: info[1], breed: info[2])
  end

  def self.find_or_create_by(info)
    sql = <<-S
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    S
    dog_data = DB[:conn].execute(sql, info[:name], info[:breed]).flatten
    if dog_data.empty?
      dog = Dog.create(info)
    else
      dog_data = { id: dog_data[0], name: dog_data[1], breed: dog_data[2] }
      dog = Dog.new(dog_data)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-S
      SELECT * FROM dogs WHERE name = ?
    S
    Dog.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def update
    sql = <<-S
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    S
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if @id.nil?
      sql = <<-S
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      S
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT MAX(id) FROM dogs").flatten[0]
    end
    self
  end
end
