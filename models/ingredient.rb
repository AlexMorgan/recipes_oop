class Ingredient
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')

      yield(connection)

    ensure
      connection.close
    end
  end

  def self.for_recipe(recipe_id)
    @ingredient_info = []
    sql = 'SELECT * FROM ingredients WHERE recipe_id = $1'
    ingredients = db_connection do |conn|
      conn.exec_params(sql, [recipe_id])
    end
    ingredients.each do |ingredient|
      @ingredient_info << Ingredient.new(ingredient["name"])
    end
    @ingredient_info
  end
end
