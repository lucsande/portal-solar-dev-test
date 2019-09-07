class FreightsController < ApplicationController
  def index
    @zip_code = params[:zip_code_input]
    pgen_id = @zip_code[:pgen].to_i
    @power_generator = PowerGenerator.find(pgen_id)

    @zip_code_value = @zip_code[:code]
    url = "http://apps.widenet.com.br/busca-cep/api/cep/#{@zip_code_value.first(5)}-#{@zip_code_value.last(3)}.json"
    address_serialized = open(url).read
    @address = JSON.parse(address_serialized)
    @freights = Freight.all.where(state: @address['state'])

    @freight = @freights.select do |freight|
      (freight.weight_min <= @power_generator.weight) && (freight.weight_max >= @power_generator.weight)
    end
    puts @freight

    respond_to do |format|
      format.html { redirect_to 'power_generators/show'}
      format.js
    end
  end
end
