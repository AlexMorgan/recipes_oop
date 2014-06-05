require 'pg'
require 'pry'

class Recipe
  attr_reader :id, :name, :instructions, :description, :ingredients
  def initialize(id, name, instructions = nil, description = nil, ingredients = nil)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')

      yield(connection)

    ensure
      connection.close
    end
  end

  def self.all
    recipes = []
    db_connection do |conn|
      @results = conn.exec('SELECT * FROM recipes ORDER BY name;')
    end
    @results.each do |recipe|
      recipes << Recipe.new(recipe["id"],recipe["name"])
    end
    recipes
  end

  def self.find(params)
    results = nil
    sql = 'SELECT recipes.id, recipes.name, recipes.instructions, recipes.description, ingredients.name
    AS ingredients FROM recipes JOIN ingredients ON recipes.id = ingredients.recipe_id WHERE recipes.id = $1'
    db_connection do |conn|
      results = conn.exec_params(sql,[params])
    end
    ingredients = []
    results.each do |recipe|
      ingredients << Ingredient.new(recipe["ingredients"])
    end

    if results[0]["description"].nil?
      results[0]["description"] = "This recipe doesn't have a description."
    end

    Recipe.new(results[0]["id"],results[0]["name"],results[0]["instructions"],results[0]["description"],ingredients)
  end

end

