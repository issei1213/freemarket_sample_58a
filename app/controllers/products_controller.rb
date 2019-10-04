class ProductsController < ApplicationController

  before_action :authenticate_user!,       only:[:new,:create,:destroy,:edit,:update]
  before_action :create_products_instance,    only:[:new,:show,:destroy]
  before_action :set_products,             only:[:show,:edit,:destroy,:update]
  before_action :image_params,             only:[:update]
  
  def index
    @products = Product.includes(:images).where(status: 0).order("created_at DESC").limit(10)    #複数の指定なので返り値は配列
    @ladiesproducts = Product.includes(:images).where(category: 1..180).order("created_at DESC").limit(10)
    @mensproducts = Product.includes(:images).where(category: 181..310).order("created_at DESC").limit(10)
    @appliancesproducts = Product.includes(:images).where(category: 799..871).order("created_at DESC").limit(10)
    @toysproducts = Product.includes(:images).where(category: 612..669).order("created_at DESC").limit(10)
    # @category = MainCategory.all.includes(sub_categories: :sub2_categories)
  end

  def category
    @products = Product.page(params[:page]).per(100)
  end

  def new
    @product = Product.new
    # @categories = MainCategory.all
    @item_image = @product.images.build
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to controller: :products, action: :index
    else
      render "new"
    end
  end

  def show
    @images = @product.images
    @image = @images.first
    @comment = Comment.new
    @comments = @product.comments.includes(:user)
  end

  def edit
    # @categories = MainCategory.all
    @product= Product.find(params[:id])
    @images = @product.images.order(id: "DESC")
  end

  
  def show
    # @categories = MainCategory.all
    @product = Product.find(params[:id])
    @sub2_category = Sub2Category.includes(sub_category: :main_category).find(@product.category)
    @images = @product.images
    @image = @images.first
    @comment = Comment.new
    @comments = Comment.where(product_id: @product.id)
  end


  def update
    # if params[:product][:category] == "null"
      # redirect_to(root_path, notice: '編集できませんでした')
    # else
      if @images.present? && @product.update(product_params)
        beforeimgs=Image.where(product_id: @product.id)
        beforeimgs.each do |beforeimg|
          beforeimg.destroy
        end
        if @product.update(product_params)
          redirect_to root_path
        else
          render "edit"
          # redirect_to(root_path, notice: '編集できませんでした')
        end
      else
        render "edit"
        # redirect_to(root_path, notice: '編集できませんでした')
      end
    # end
  end


  def destroy
    @product.destroy if @product.user_id == current_user.id
    redirect_to controller: :products, action: :index
  end

private

  def product_params
    params.require(:product).permit(:name, :detail, :category, :price, :status, :state, :city, :delivery, :delivery_time, :fee_payer, images_attributes: [:image]).merge(user_id: current_user.id)
  end
  
  def image_params
    @images = params.require(:product).permit(images_attributes: [:image])
  end

  def create_products_instance
    @product = Product.new
  end

  def set_products
    @product = Product.find(params[:id])
  end

end
