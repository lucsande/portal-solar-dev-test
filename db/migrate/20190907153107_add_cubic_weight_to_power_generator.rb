class AddCubicWeightToPowerGenerator < ActiveRecord::Migration[5.2]
  def change
    add_column :power_generators, :cubic_weight, :float
  end
end
