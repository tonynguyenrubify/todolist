class ListsController < ApplicationController
  respond_to :html, :xml, :js
  def index
    @lists = current_user.lists
  end  
  
  def new 
    @list = current_user.lists.new
  end
  
  def create
    @list = current_user.lists.new(params[:list])
    if @list.save
      flash[:notice] = "List created"
      redirect_to list_url(@list)
    else
      flash[:error] = "Could not create list"
      redirect_to new_list_url
    end
  end
    
  def show
    @list = current_user.lists.find(params[:id])
    @item = @list.items.new
    render layout: false if params[:is_ajax] == true
  end
  
  def edit
    @list = current_user.lists.find(params[:id])
    render :layout => false
  end
  
  def update
    @list = current_user.lists.find(params[:id])
    if @list.update_attributes(params[:list])
      flash[:notice] = "List updated"
      if params[:ajax] == "1"
        render :text => "successful"
      else
        redirect_to list_url(@list)
      end
    else 
      flash[:error] = "Could not update list"
      if params[:ajax] == "1"
        render :text => "failed"
      else      
        redirect_to edit_list_url(@list)
      end
    end
  end
  
  def destroy
    @list = current_user.lists.find(params[:id])
    if @list.destroy
      flash[:notice] = "List deleted"
      redirect_to lists_url
    else
      flash[:error] = "Could not delete list. Some thing wrong ?"
      redirect_to lists_url
    end
  end             
end
