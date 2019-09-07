require 'open-uri'
class PowerGeneratorsController < ApplicationController
  def index
    @power_generators = PowerGenerator.all

    @simple = params['simple_search']
    @advanced = params['advanced_search']
    @price = params['price_filter']

    if @simple.present?
      simple_search
    elsif @advanced.present?
      advanced_search
    end

    if @price.present?
      min = @price[:min_price].to_f
      max = @price[:max_price].to_f
      @power_generators = @power_generators.reject { |pgen| pgen.price < min } unless min.zero?
      @power_generators = @power_generators.reject { |pgen| pgen.price > max } unless max.zero?
    end

    @power_generators = Kaminari.paginate_array(@power_generators).page(params[:page]).per(6)
  end

  def show
    @power_generator = PowerGenerator.find(params[:id])
    @zip_code = params[:zip_code_input]
    if @zip_code.present?
      @zip_code_value = @zip_code[:code]
      url = "http://apps.widenet.com.br/busca-cep/api/cep/#{@zip_code_value.first(5)}-#{@zip_code_value.last(3)}.json"
      address_serialized = open(url).read
      @address = JSON.parse(address_serialized)

      @freights = Freight.all.where(state: @address['state'])
    else
      @freights = []
    end
  end

  private

  def simple_search
    @query = @simple[:query].split(' ')
    score_hash = {}
    @power_generators.each { |pgen| score_hash[pgen.id] = 0 }

    # 3 points for each query word present in name, 1 point for each query word present in description
    @query.each do |word|
      @power_generators.each do |pgen|
        score_hash[pgen.id] += 3 if pgen.name.downcase.include?(word.downcase)
        score_hash[pgen.id] += 1 if pgen.description.downcase.include?(word.downcase)
      end
    end

    score_ary = score_hash.sort_by { |_k, v| v }.reverse
    filtered_score = score_ary.reject { |_k, v| v.zero? }

    @power_generators = []

    filtered_score.each do |score|
      pgen = PowerGenerator.find(score[0])
      @power_generators.push(pgen)
    end
  end

  def advanced_search
    simple_search unless @advanced[:query] == ''

    if @advanced[:guarantee] == '1'
      @power_generators = @power_generators.select { |pgen| pgen.description.downcase.include?('garantia') }
    end
    if @advanced[:pid_free] == '1'
      @power_generators = @power_generators.select { |pgen| pgen.description.downcase.include?('pid free') }
    end
    unless @advanced[:structure] == ''
      @power_generators = @power_generators.select { |pgen| pgen.structure_type == @advanced[:structure] }
    end

    unless @advanced[:max_lenght] == ''
      @power_generators = @power_generators.select { |pgen| pgen.lenght <= @advanced[:max_lenght].to_f }
    end
    unless @advanced[:max_width] == ''
      @power_generators = @power_generators.select { |pgen| pgen.width <= @advanced[:max_width].to_f }
    end
    unless @advanced[:max_height] == ''
      @power_generators = @power_generators.select { |pgen| pgen.height <= @advanced[:max_height].to_f }
    end
    unless @advanced[:max_weight] == ''
      @power_generators = @power_generators.select { |pgen| pgen.weight <= @advanced[:max_weight].to_f }
    end
    unless @advanced[:min_kwp] == ''
      @power_generators = @power_generators.select { |pgen| pgen.kwp >= @advanced[:min_kwp].to_f }
    end
  end
end
