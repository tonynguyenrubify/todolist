class ItemsController < ApplicationController
  respond_to :htmk, :xml, :js
  
  #def new
   # @list = List.find(params[:list_id])
    #@item = @list.items.new
  #end
  
  def index
    @list = current_user.lists.find(params[:list_id])
    @item = @list.items.new    
  end
  
  def undone
    @list = current_user.lists.find(params[:list_id])
    @items = @list.items.where(completed: false)
    render :layout => false
  end
  
  def create
    @list = current_user.lists.find(params[:list_id])
    @item = @list.items.build(params[:item]) # use build instead of new. 
    # @item = Item.new
    if @item.save
      render json: {result: "succcessful", list_id: @list.id}
    else
      render json: {result: "failed"}
    end
  end    
  
  def show_form_create
    @list = current_user.lists.find(params[:list_id])
    @item = @list.items.build(params[:item]) # use build instead of new.
    render :partial => "/items/create_item"
  end
  
  def mark_an_item_as_done
    @list = current_user.lists.find(params[:list_id])
    @item = @list.items.find_by_id(params[:id])
    @item.update_attribute(:completed, true)
    render :text => "successful"
  end
  
  def unmark_an_item
    @list = current_user.lists.find(params[:list_id])
    @item = @list.items.find_by_id(params[:id])
    @item.update_attribute(:completed, false)
    render :text => "successful"
  end    
  
  def reorder
    @list = current_user.lists.find(params[:list_id])
    @item = @list.items.find_by_id(params[:id])
    #@item.update_attribute(:position, params[:position])
    #render :text =>"successful"
    render :layout => false
  end 
  
  def done_reorder
    @list = current_user.lists.find(params[:list_id])
    @list.update_attributes(params[:list])
    render :text => "successful"
  end
end
