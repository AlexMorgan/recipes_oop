require 'pg'
require 'pry'

class Recipe
  attr_reader :id, :name, :instructions, :description
  # def initialize(id, name, instructions = nil, description = nil, ingredients = nil)
  def initialize(attributes)
    @id = attributes['id']
    @name = attributes['name']
    @description = attributes['description']
    @instructions = attributes['instructions']

    # @id = id
    # @name = name
    # @instructions = instructions
    # @description = description
    # @ingredients = ingredients
  end

  def ingredients
    Ingredient.for_recipe(id)
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')

      yield(connection)

    ensure
      connection.close
    end
  end

  # @results = conn.exec('SELECT * FROM ingredients WHERE recipe_id = $1')

  def self.all
    recipes = []
    db_connection do |conn|
      @results = conn.exec('SELECT * FROM recipes ORDER BY name;')
    end
    @results.each do |recipe|
      recipes << Recipe.new(recipe)
    end
    recipes
  end

  def self.find(params)
    results = nil
    sql = 'SELECT recipes.id, recipes.name, recipes.instructions, recipes.description, ingredients.name
           AS ingredients FROM recipes JOIN ingredients ON recipes.id = ingredients.recipe_id WHERE recipes.id = $1'

    recipe = db_connection do |conn|
      conn.exec_params(sql,[params]).first
    end

    # ingredients = []
    # results.each do |recipe|
    #   ingredients << Ingredient.new(recipe["ingredients"])
    # end

    # if results[0]["description"].nil?
    #   results[0]["description"] = "foo"
    #   binding.pry
    # end

    Recipe.new(recipe)
  end

end

