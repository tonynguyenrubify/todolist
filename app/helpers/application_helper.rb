module ApplicationHelper
  
  def render_item_list(list, un_done=true, sorting=false, reorder=false)
    render :partial => "/items/list", locals: {list: list, un_done: un_done, sorting: sorting, reorder: reorder}
  end
  
end
