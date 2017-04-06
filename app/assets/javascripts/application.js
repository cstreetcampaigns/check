// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.foundation
//= require foundation
//= require_tree .

var table; 

$(function(){ 
	$(document).foundation({
		abide: { 
			patterns: { 	
				user_phone: /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/,
				user_email: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
			},
		} 
	}) 
});

function addRSVP() {
	var url = '/people/new';
	$.ajax({
		type: "GET",
		url: url,
		dataType: 'script',
		data: {
			'host_id': $(this).data('host-id')
		},
		success: function(result) {
			eval(result);
			$(this).hide();
		}
	})
}

function activateButtons() {

	$('.add').on('click', function(e) {
		e.preventDefault();
		$('#working').show();
		var url = '/people/new';
		$.ajax({
			type: "GET",
			url: url,
			dataType: 'script',
			data: {
				'host_id': $(this).data('host-id')
			},
			success: function(result) {
				eval(result);
				$(this).hide();
			}
		})
	})

	$('.checkin').on('click', function(e) {
		e.preventDefault();
		e.stopPropagation();
		$('#working').show();
		console.log($(this).data('id'))
		var url = '/rsvps/check_in';
		$.ajax({
			type: "POST",
		  url: url,
		  dataType: 'script',
		  data: {
		  	'id': $(this).data('id'),
		  	'attended': true
		  },
		  success: function(result) {
		    eval(result);
		  },
		});
	});


	$('.checkout').on('click', function(e) {
		e.preventDefault();
		e.stopPropagation();
		$('#working').show();
		console.log($(this).data('id'))
		var url = '/rsvps/check_out';
		$.ajax({
			type: "POST",
		  url: url,
		  dataType: 'script',
		  data: {
		  	'id': $(this).data('id'),
		  	'attended': false
		  },
		  success: function(result) {
		    eval(result);
		  },
		});
	});

	$('.edit').on('click', function(e) {
		e.preventDefault();
		e.stopPropagation();
		$('#working').show();
		person_id = $(this).data('person-id');
		rsvp_id = $(this).data('rsvp-id');
		var url = '/people/' + person_id + '/edit';
		$.ajax({
			type: "GET",
		  url: url,
		  dataType: 'script',
		  data: {
		  	'rsvp_id': rsvp_id
		  },
		  success: function(result) {
		    eval(result);
		  },
		});
	});
}

$(document).ready(function() {

	$('.search').on('click', function() {
		$('.search .overlay .text').fadeOut(function() {
			$('.search').addClass('active');
			setTimeout( function() {
				$('.search input').attr('placeholder', 'Name or Email').focus();
			}, 300);
		});
	})

	activateButtons();

	function activateThinking() {
		$('#thinking').show();
		$('body').css({'overflow': 'hidden'});
	}

	function activatePolling(event_id) {
  	var polling = setInterval(function(){
	  	$.ajax({
	  		type: "GET",
	  	  url: "/sync_status",
	  	  dataType: 'json',
	  	  data: {
	  	  	'event_id': event_id
	  	  },
	  	  success: function(result) {
	  	    if (result.sync_status == "pending") {
	  	      $('#thinking .percent').text(result.sync_percent + "% Complete");
	  	    } else {
	  	      $('#thinking .message').text("Done! Refreshing list...");
	  	      window.location = window.location.origin + '/rsvps';
	  	      clearInterval(polling);
	  	    }
	  	  }
	  	});
	  }, 1000);
	}

	$('.activate-thinking').on('click', function() {
		activateThinking();
	})

	$('.to-cache').on('click', function(e) {
		e.preventDefault();

		event_id = $(this).data('event');

		console.log(event_id)

		$.ajax({
			type: "GET",
		  url: "/rsvps/cache",
		  dataType: 'json',
		  data: {
		  	'id': event_id
		  },
		  success: function() {
		  	activatePolling(event_id);
		  }
		});

	});

	if($('.sync-mode').length > 0) {

    activateThinking();
    activatePolling($('.sync-mode').data('event'));
		
	}

	$('.reveal-modal').on('open.fndtn.reveal', '[data-reveal]', function () {
	    $('body').addClass('modal-open');
	});
	$('.reveal-modal').on('close.fndtn.reveal', '[data-reveal]', function () {
	    $('body').removeClass('modal-open');
	});
	
	initializeRsvpList();

})

function initializeRsvpList() {
	if($('#list').size() > 0) {
		$('#list tfoot th').each( function () {
		    var title = $('#list thead th').eq( $(this).index() ).text();
		    $(this).html( '<input type="text" placeholder="Search '+title+'" />' );
		} );

		// DataTable
		table = $('#list').DataTable({
			"order": [[ 0, 'asc' ]],
			"paging": false,
			"oLanguage": {
	      "sZeroRecords": "No one found."
	    }
		});

		// Apply the search
		table.columns().eq( 0 ).each( function ( colIdx ) {
		    $('#datatable-search').on( 'keyup change', function () {
		        table
		            .column( colIdx )
		            .search( this.value )
		            .draw();
		    } );
		} );
	}
}