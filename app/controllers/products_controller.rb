require "json"

class ProductsController < ApplicationController
  def index
    collection = Collection.find_by(:handle => params[:collection])
    @products = Product.includes(:variants).where( :collection => collection.id).where.not(:variants => { :id => nil }).order(created_at: :desc)
  end

  def scanAll
    # collections = Collection.includes(:products).where.not(:products => { :id => nil })
    # collections.each do |item|
      scan("new")
    # end
  end

  def scan(path = nil)
    if path == nil {
      path = params[:collection]
    }

    url = "http://www.fashionnova.com/collections/#{path}/products.json?limit=1000"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
    
    # Get the collection specified
    @collection = Collection.find_by(handle: path)
    
    @products = json["products"]
    
    @products.each do |item|
      product = Product.find_or_initialize_by(product_id: item["id"])
      product.title = item["title"]
      product.handle = item["handle"]
      product.product_type = item["product_type"]
      product.vendor = item["vendor"]
      product.collection_id = @collection.id
      product.save
      
      product_url = "http://www.fashionnova.com/products/#{product.handle}.json"
      product_uri = URI(product_url)
      product_response = Net::HTTP.get(product_uri)
      product_json = JSON.parse(product_response)
      
      variants = product_json["product"]["variants"]
      variants.each do |item_v|
        product.variants.create(
          title: item_v["title"],
          price: item_v["price"],
          inventory: item_v["inventory_quantity"],
          sku: item_v["sku"]
        )
      end

      puts "Scanned: #{product.handle}"
     end
  end
  
  def allowed_params
    params.require(:collection)
  end
end
