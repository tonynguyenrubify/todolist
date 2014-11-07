// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
/// View keep is stupid
/// Logic keep at server side
$(document).ready(function() {
	// delegation
	// event bubbling
	$(document.body).delegate("#submit_item_button", "click", function(event) {
		var self = $(this);
		$(this).val("Saving...").attr("disabled", "disabled");
		form = $(this).parents("form:first");
		$.ajax({
			url: form.attr("action"),
			type: form.attr("method"),
			data: form.serialize(),
			success: function(responseObj) {
				if(responseObj.result == "succcessful") {
					reloadDoneList(responseObj.list_id);
					form[0].reset();
				}//end if
				else {
					alert("Something Wrong!");
				}//end else
			}
		});
		
		event.preventDefault();
		return false;
	});
	
	$(document.body).delegate("a.ajax-link", "click", function(event) {
		
		$('#stage').load($(this).attr("href"), function() {
		});
		event.preventDefault();
		return false;
	});
	
	$(document.body).delegate("a.show_hide", "click", function(event) {
		$.ajax({
			url: '/lists/' + $("#todolist_id").html() + '/items/show_form_create',
			type: "PUT",
			success: function(response) {
				$("#new_item_form_container").html(response);				
			}
		});
		return false;
	});
	
	$(document.body).delegate("input.item-complete-checkbox", "change", function() {
		var isChecked = $(this).attr('checked')
		var self = $(this);
		if(isChecked) {
			$.ajax({
				url: '/lists/' + $("#todolist_id").html() + '/items/' + self.data('item-id') + '/mark_an_item_as_done',
				type: "PUT",				
				success: function(response) {
					if(response == "successful") {
						$("img.drag_img").addClass('drag_img_none');
						// this is a successful request, do something with this
						self.parent().fadeOut(function() {
							$("#form_done ul").append(self.parent().fadeIn());
						})
					}//end if
				}
			});
		}//end if
		else {
			$.ajax({
				url: '/lists/' + $("#todolist_id").html() + '/items/' + self.data('item-id') + '/unmark_an_item',
				type: "PUT",
				success: function(response) {
					if(response == "successful"){			
						self.parent().fadeOut(function() {
							$("#form_not_done ul").append(self.parent().fadeIn());
						})
					}
				}
			});
		}//end else
	});
	
	$(document.body).delegate("a.show_done_drag_img", "click", function() {
		$("a.show_hide").removeClass('display_none');
		var frm = $("form#form_not_done");
		$.ajax({
			url: frm.attr('action'),
			type: "PUT",
			data: frm.serialize() + "&ajax=1",
			success: function(res){
				if(res == "successful"){
					$("a.show_drag_img").removeClass("display_none");
					$("a.show_done_drag_img").addClass("display_none");
					$("img.drag_img").addClass('drag_img_none').removeClass('drag_img_show');
					$("#done_list").removeClass('display_none');
					$("input.item-complete-checkbox").removeClass('display_none');
					$("#not_done_list_drag").attr("id","not_done_list");
					$("#form_done").removeClass('display_none');
				}
			}
		});	
		return false;		
	});
	
	$(document.body).delegate("a.show_drag_img2", "click", function(e){
		$("a.show_drag_img").addClass("display_none");
		$("a.show_done_drag_img").removeClass("display_none");
		$("img.drag_img").removeClass('drag_img_none').addClass('drag_img_show');
		$("#done_list").addClass('display_none');
		$("a.show_hide").addClass('display_none');
		$("input.item-complete-checkbox").addClass('display_none');
		$("#form_done").addClass('display_none');
		$("#not_done_list").attr("id","not_done_list_drag");
    $( "ul, li" ).disableSelection();
		$("#not_done_list_drag").sortable({
			stop: function( event, ui ) {
				$("#not_done_list_drag").children('li').each(function(index){
					$(this).find(".item-hidden-field-position").val(index++);		
			 });
			var frm = $("form#form_not_done");
			$.ajax({
				url: '/lists/' + $("#todolist_id").html() + '/items/done_reorder',
				type: "PUT",
				data: frm.serialize(),
				success: function(response) {
					if(response == "successful"){				
					}
				}
			});	
			}
		});
		return false;
	});	
	
	$(document.body).delegate("a.show_drag_img", "click", function() {
		//alert("/lists/" + $("#todolist_id").html() + "/items/reorder");
		$(".content_list").load("/lists/" + $("#todolist_id").html() + "/items/reorder", function() {
			$("#not_done_list").sortable({
				stop: function( event, ui ) {
					$("#not_done_list").children('li').each(function(index){
						$(this).find(".item-hidden-field-position").val(index++);		
				 });
				//alert('ok2');
				var frm = $("form#form_not_done");
				$.ajax({
					url: '/lists/' + $("#todolist_id").html() + '/items/done_reorder',
					type: "PUT",
					data: frm.serialize(),
					success: function(response) {
						if(response == "successful"){				
						}
					}
				});	
				}
			});			
		});
		//$("#not_done_list").attr("id","not_done_list_drag");
    //$( "ul, li" ).disableSelection();
		
		return false;		
	});
});

function reloadDoneList(list_id) { //dependent
	$("#form_not_done").parent().load("/lists/" + list_id + "/items/undone", function() {
		$("#submit_item_button").val("Add this item").removeAttr("disabled");
	});
}
