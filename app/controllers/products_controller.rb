class ProductsController < ApplicationController
  require 'nokogiri'
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all.order(:title)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        puts @product.errors.full_messages
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.js { render :update, curr }
        format.json { render :show, status: :ok, location: @product }

        @products = Product.all.order(:title)
        ActionCable.server.broadcast('products', { html: render_to_string('store/index', layout: false) })
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def who_bought
    @product = Product.find(params[:id])
    @latest_order = @product.orders.order(:updated_at).last
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.product do
        xml.title @product.title
        xml.description @product.description
        xml.price @product.price
        xml.image @product.image_url
        xml.orders do
          @product.orders.each do |order|
            xml.order do
              xml.name order.name
              xml.address order.address
              xml.email order.email
              xml.pay_type order.pay_type
              xml.created_at order.created_at
            end
          end
        end
      end
    end
    if stale?(@latest_order)
      respond_to do |format|
        format.atom
        #format.html { render xml: @product.to_xml(include: :orders) }
        format.html { render xml: builder }
        format.json { render json: @product.to_json(include: :orders) }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:title, :description, :image_url, :price)
  end
end
