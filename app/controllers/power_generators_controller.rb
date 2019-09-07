require 'open-uri'
class PowerGeneratorsController < ApplicationController
  def index
    @search = params['search_terms']
    @power_generators = PowerGenerator.all

    full_search if @search.present?

    @power_generators = @power_generators.sort_by(&:name)
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

  def full_search
    @power_generators = PowerGenerator.all
    search_by_keywords if @search[:keywords] != ''

    filter_by_materiality
    filter_by_dimensions
    filter_by_quality
    filter_by_price
    filter_by_kwp

    @power_generators.uniq!
  end

  def search_by_keywords
    @keywords = @search[:keywords].split(' ')

    filtered_score = generate_search_scores
    @power_generators = []

    filtered_score.each do |score|
      pgen = PowerGenerator.find(score[0])
      @power_generators.push(pgen)
    end
  end

  def generate_search_scores
    score_hash = {}
    @power_generators.each { |pgen| score_hash[pgen.id] = 0 }

    # 3 points for each keyword present in name, 1 point for each keyword present in description
    @keywords.each do |word|
      @power_generators.each do |pgen|
        score_hash[pgen.id] += 3 if pgen.name.downcase.include?(word.downcase)
        score_hash[pgen.id] += 1 if pgen.description.downcase.include?(word.downcase)
      end
    end

    score_ary = score_hash.sort_by { |_k, v| v }.reverse
    score_ary.reject { |_k, v| v.zero? }
  end

  def filter_by_materiality
    max_wgt = @search[:max_weight].to_f
    @power_generators = @power_generators.reject { |pgen| pgen.weight > max_wgt } unless max_wgt.zero?

    return if (@search[:structure].nil?) || (@search[:structure] == '')

    @power_generators = PowerGenerator.all.select { |pgen| pgen.structure_type == @search[:structure] }
  end

  def filter_by_dimensions
    max_len = @search[:max_lenght].to_f
    max_wid = @search[:max_width].to_f
    max_hgt = @search[:max_height].to_f

    @power_generators = @power_generators.reject { |pgen| pgen.lenght > max_len } unless max_len.zero?
    @power_generators = @power_generators.reject { |pgen| pgen.width > max_wid } unless max_wid.zero?
    @power_generators = @power_generators.reject { |pgen| pgen.height > max_hgt } unless max_hgt.zero?
  end

  def filter_by_quality
    if @search[:guarantee] == '1'
      @power_generators += PowerGenerator.all.select { |pgen| pgen.description.downcase.include?('garantia') }
    end

    return unless @search[:pid_free] == '1'

    @power_generators += PowerGenerator.all.select { |pgen| pgen.description.downcase.include?('pid free') }
  end

  def filter_by_price
    min = @search[:min_price].to_f
    max = @search[:max_price].to_f

    @power_generators = @power_generators.reject { |pgen| pgen.price < min } unless min.zero?
    @power_generators = @power_generators.reject { |pgen| pgen.price > max } unless max.zero?
  end

  def filter_by_kwp
    min = @search[:min_kwp].to_f
    max = @search[:max_kwp].to_f
    @power_generators = @power_generators.reject { |pgen| pgen.kwp < min } unless min.zero?
    @power_generators = @power_generators.reject { |pgen| pgen.kwp > max } unless max.zero?
  end
end
