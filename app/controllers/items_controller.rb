class ItemsController < ApplicationController

  def index
    @section = Section.find(params[:section_id])
    @items = @section.items
    tags = []
    @items.all.each{|item| tags << item.tags}
    # thumb_image_urls = @items.map { |item| item.image.url(:thumb) }
    # sm_image_urls = @items.map { |item| item.image.url(:small) }
    med_image_urls = @items.map { |item| item.image.url(:medium) }
    lrg_image_urls = @items.map { |item| item.image.url(:large) }
    render json: { items: @items, med_image_urls: med_image_urls, lrg_image_urls: lrg_image_urls, tags: tags }
  end

  def create
    image = StringIO.new(Base64.decode64(item_params.to_h[:image]))
    @item = Item.new(user_id: item_params.to_h[:user_id], section_id: item_params.to_h[:section_id], image: image)
    # @item = Item.new(item_params)
    if @item.save
      render json: @item, status: 201
    else
      @item.errors.full_messages << "Please try again."
      render json: @item.errors.full_messages, status: 422
    end
  end

  # def show
  #   @item = Item.find(params[:id])
  #   tags = @item.tags.map { |tag| tag.name }
  #   thumb_image_url = @item.image.url(:thumb)
  #   med_image_url = @item.image.url(:medium)
  #   render json: { item: @item, thumb_image_url: thumb_image_url, med_image_url: med_image_url, tags: tags }
  # end

  def destroy
    section = Section.find(params[:section_id])
    item = section.items.find(params[:id])
    item.destroy
    item.delete_associated_outfits_and_tags
    render nothing: true, status: 200
  end

  private
  def item_params
    params.fetch(:item, {}).permit!
    # params.require(:item).permit!
  end

end
