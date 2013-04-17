
// Download
function download(format)
{
	if(format=='PNG')
	{
		$('#downloadloader-PNG').fadeIn('fast');
		setTimeout("$('#downloadloader-PNG').fadeOut('fast');",2000 );
	}
	else
	{
		$('#downloadloader-ICO').fadeIn('fast');
		setTimeout("$('#downloadloader-ICO').fadeOut('fast');",4000 );
	}
	//pageTracker._trackEvent('Download',format);
	_gaq.push(['_trackEvent', 'Download',format]);
	return false;
}

// Focus search field
function sfocus()
{
	$("#inputField").focus();
	return false;
}

// Load results
function loadJsResults()
{		
	$("#dropmenu").click(function()
	{
		showmenu();
	});
	
	$(".attribution").click(function()
	{
		showReadme(this);
	});
	
	$("#inputField").click(
	function()
	{
		sfocus();	
		return false;
	});
	
	$(".numberchoose").click(
	function()
	{
		$(".numberchoose").removeClass("numberselected");
		$(this).addClass("numberselected");
		updatenumber();
		return false;
	});
		
	$(".colorchoose").click(
	function()
	{
		$(".colorchoose").removeClass("colorselected");
		$(this).addClass("colorselected");
		updatecolor($(this).attr('id'));
		return false;
	});
	
	function updatecolor(id)
	{
		$('body').find('.icon').removeClass('white');
		$('body').find('.icon').removeClass('gray');
		$('body').find('.icon').removeClass('black');
		$('body').find('.icon').addClass(id);
		
		val = id;
		name = 'bgcolor';	

		$.get("/ajax/cookie/", 
		{ 
			name: name,
			val: val
		},
		function(data)
		{
			return false;
		});
		//pageTracker._trackEvent('Settings','Change color',val);	
		_gaq.push(['_trackEvent', 'Settings','Change color',val]);
		val 	= null;
		name 	= null;
		id 		= null;
		return false;
	}
			
	$("#licensefilter").change(
	function()
	{
		//alert('change');
		updatefilter();
		return false;
	});
	
	
	
	$(".designer").click(
	function()
	{	
		$(".designer").removeClass('slidedDown');
		$('.packagelist').hide();
		$(this).siblings("ul:first").show();
		$(this).siblings("ul:first").addClass('slidedDown');
		$(this).addClass('slidedDown');
		return false;
	});
	
	

	/* VOTES */	
	$(".vote").click(
	function()
	{
		$(this).parent().parent().parent().parent().slideUp('fast');
		id = $(this).siblings(".iconid").val();
		voted = $(this).val();
				
		$.get("/ajax/votetags/", 
		{ 
			id: id,
			voted: voted
		},
		function(data)
		{
			return false;
		});	
		return false;
	});
	
	update = 0;	
	loadinfo();	
	//loadrelated();
	//loadiconhover();
	
	$("#custom").submit(
	function()
	{
		form_name = $(this).find('#form_name').val();
		form_email = $(this).find('#form_email').val();
		form_description = $(this).find('#form_description').val();
		$(this).html('&nbsp;');
		$(this).parent().addClass('loading');
		
		$.post("/ajax/submitform/", 
		{ 
			form_name: form_name,
			form_email: form_email,
			form_description: form_description
		},
		function(data)
		{	
			$("#submitformwrapper").parent().removeClass("loading");
			$("#submitformwrapper").parent().html(data);
			return false;
		});
		//pageTracker._trackEvent('Submit form','Custom icon design');	
		return false;
	});
	

	$("#feedback-link").click(
	function()
	{
		$("#feedback").slideDown();
	});


	$("#feedbackbutton").click(
	function()
	{
		form_description = $('#feedbacktext').val();
		$("#feedback").html('&nbsp;');
		$("#feedback").addClass('loading');
		
		form_name = 'feedback';
		form_email = 'N/A';
		
		if(form_description != '')
		{
			$.post("/ajax/submitform/", 
			{ 
				form_name: form_name,
				form_email: form_email,
				form_description: form_description
			},
			function(data)
			{	
				$("#feedback").removeClass("loading");
				$("#feedback").html(data);
				setTimeout("$('#feedback').slideUp('fast');",1000);
				return false;
			});
		}
		else
		{
				$("#feedback").removeClass("loading");
				$('#feedback').slideUp('fast');
				return false;
		}

		//pageTracker._trackEvent('Submit form','Feedback');	
		return false;
	});
	
	
	/* Track external links */
	$("a.external").click(function()
	{	
		//pageTracker._trackEvent('Links','External',$(this).attr('href'));
		_gaq.push(['_trackEvent', 'Links','External',$(this).attr('href')]);
		return true;
	});	

	initstars();
	

	/* Settings */
	/*	
	$("#hidesettings").click(function() 
	{
		$("#hidesettings").fadeOut();
		$("div#settings").slideUp('fast');
		$("#showsettings").fadeIn();
		
		$.get("/ajax/cookie/", 
		{ 
			name: 'showsettings',
			val: 0
		},
		function(data)
		{
		});
		
		pageTracker._trackEvent('Settings','Toggle visibility',0);	
	});
	
	$("#showsettings").click(function() 
	{
		$("#showsettings").fadeOut();
		$("div#settings").slideDown('fast');
		$("#hidesettings").fadeIn();

		$.get("/ajax/cookie/", 
		{ 
			name: 'showsettings',
			val: 1
		},
		function(data)
		{
		});
		
		pageTracker._trackEvent('Settings','Toggle visibility',1);	
	});
	*/
	
	$("#logout").click(function()
	{
		$.get("/ajax/logout/", 
		{ 
			logout: 1
		},
		function(data)
		{
			window.location.reload(true);
		});		
	});
	
	
	
	$("a#list").click(function()
	{
		$("a#list").addClass("active");
		$("a#grid").removeClass("active");
		$("#iconsets").removeClass("grid"); 
		
		$.get("/ajax/cookie/", 
		{ 
			name: 'viewstyle',
			val: 'list'
		},
		function(data)
		{
		});
	}); 

	$("a#grid").click(function()
	{
		$("a#list").removeClass("active");
		$("a#grid").addClass("active");
		$("#iconsets").addClass("grid"); 
		
		$.get("/ajax/cookie/", 
		{ 
			name: 'viewstyle',
			val: 'grid'
		},
		function(data)
		{
		});
	}); 


	/*
	$("a#popular").click(function()
	{
		$("a#popular").addClass("active");
		$("a#newest").removeClass("active");
		
		$.get("/ajax/cookie/", 
		{ 
			name: 'order',
			val: 'popular'
		},
		function(data)
		{
		});
		return false;
	}); 

	$("a#newest").click(function()
	{
		$("a#popular").removeClass("active");
		$("a#newest").addClass("active");
		
		$.get("/ajax/cookie/", 
		{ 
			name: 'order',
			val: 'newest'
		},
		function(data)
		{
		});
		return false;
	});
	*/

	$(".largersize").hover(function()
	{
		id = $(this).attr('id').replace(/largersize-/,"");
		obj = $("#hiddenicon-" + id);
		obj.show();
	},
	function()
	{
		obj.hide();
	});
	
	
	var tag_search_timer;
	
	function showTagSearch(obj)
	{
		$('.tag_search').remove();
		obj.append('<span class="tag_search" id="tag-'+obj.attr('name')+'"><span>Loading preview ...</span></span>');
		var container = $("#tag-"+obj.attr('name'));

		container.addClass('loading');
		container.show();
		
		$.get("/ajax/tag_search/", 
		{ 
			tag: obj.attr('name')
		},
		function(data)
		{
			container.removeClass('loading');
			container.html(data);
			//container.fadeIn();
			setTimeout(function(){container.hide().remove();}, 5000);
		});	
	}	

	$(".tag").hover(function()
	{
		obj = $(this);
		clearTimeout(tag_search_timer);
		tag_search_timer = setTimeout(function(){showTagSearch(obj);}, 1000);
		//showTagSearch(obj);
	},
	function()
	{
		//clearTimeout(tagSearchTimer);
		clearTimeout(tag_search_timer);
		$('.tag_search').remove();
	});
		
	return false;
}

/* -------------------------- INFO MENU --------------------------- */

var timeout    = 0;
var closetimer = 0;
var ddmenuitem = 0;

function loadinfo()
{
	document.onclick = hideallinfo;

	$(".infolink").click(
	function()
	{
		id = $(this).attr('id').replace(/infolink-/,"");
		obj = $("#icon-" + id);		
		$("#infomenu-" + id).html('Please wait'); 	
		showinfo(id);
		return false;		
	});

	return false;
}

function showinfo(id)
{
	canceltimerinfo();
	hideinfo($(document).find('.infomenu'));
	infomenu = $('#infomenu-'+id);
	$('#infolink-'+id).addClass("selected");
	infomenu.css("display","block");	
	infomenu.addClass("loading");
	hiddensize = $('#size-'+id).val();
	
	$.get("/ajax/infomenu/", 
	{ 
		id: id,
		size: hiddensize
	},
	function(data)
	{	
		infomenu.html(data);
		infomenu.removeClass("loading");
		//pageTracker._trackEvent('Info menu','Show info',id);
		_gaq.push(['_trackEvent','Info menu','Show info',id]);
	});

	obj = null;
	//infomenu = null;
	id = null;
	hiddensize = null;
	return false;
}

function timerinfo(obj)
{
	closetimer = window.setTimeout(hideallinfo, timeout);
	return false;	
}

function hideallinfo()
{
	if(tagsedited==0)
		hideinfo($(document).find('.infomenu'));
	
	hidemenu();
	
	//if(switcheron==1)
	//	hideswitcher();	

	//if(coloron==1)
	//	hidecolorpicker();	
}

function hideinfo(obj)
{
	obj.siblings('.infolink').removeClass("selected");
	obj.fadeOut('fast');
}

function canceltimerinfo()
{  
	if(closetimer)
	{
		window.clearTimeout(closetimer);
		closetimer = null;
	}
	return false;
}

var menushown = 0; 

function showmenu()
{
	$("#menu-content").fadeIn();
	setTimeout(function(){menushown=1;},800);
}

function hidemenu()
{
	if(menushown == 1)
	{
		$("#menu-content").fadeOut();
		menushown = 0;
	}
}


/* -------------------------- TAGS --------------------------- */

	var tagsedited = 0;
	//var switcheron = 0;
	//var coloron = 0;
	
	// Display change tags dialog
	function showTaginfo(id,size)
	{
		$('#tagmenu-'+id).show();
		tagmenu = $('#innertag-'+id);
		tagmenu.addClass("loading");

		var winH = $(window).height();
		var winW = $(window).width();

		$('#tagmenu-'+id).css('top',  winH / 2 - tagmenu.height() / 2);
		$('#tagmenu-'+id).css('left', winW / 2 - tagmenu.width() / 2);

		tagmenu.show(); 
	
		$.get("/ajax/tagmenu/", 
		{ 
			id: id,
			size: size
		},
		function(data)
		{	
			tagmenu.html(data);
			tagmenu.removeClass("loading");
			//pageTracker._trackEvent('Info menu','Show info',id);
		});
		return false;
	}
	
	function tagsubmit(id, size)
	{
		// Get iconid from hidden input	
		//var size = $('#s'+id).val();
		//var iconid = $('#i'+id).val();
		
		var n = $('#n'+id).val();
		var iconid = id;
		var size = size;
		
		//alert(iconid + ' - ' + size + ' - ' + n);
		
		tagmenu = $('#innertag-'+id);
		tagmenu.addClass("loading");
		tagmenu.html("Submitting tags");
	
		$.get("/ajax/savetags/", 
		{ 
			iconid: iconid,
			size: size,
			n: n
		},
		function(data)
		{	
			tagsedited = 0;
			
			tagmenu.html(data);
			tagmenu.removeClass("loading");
			//tagmenu.hide();
			
			//window.setTimeout(hideallinfo, timeout);
			//pageTracker._trackEvent('Info menu','Submit tags',parseInt(id));	
			tagcancel();
			return false;
		});

		return false;
	}




	
	/*
	function savetags(button,iconid,size)
	{
		// Get iconid from hidden input	
		var n = $('#tags'+iconid).val();
		
		$('#tags'+iconid).addClass("loading");
		$(button).val('Submitting tags');
		
		//alert('xxxxxx ' + iconid + ' - ' + size + ' - ' + n);
	
		$.get("/ajax/savetags/", 
		{ 
			iconid: iconid,
			size: size,
			n: n
		},
		function(data)
		{	
			$('#tags'+iconid).removeClass("loading");
			$(button).val('Tags submitted');
			pageTracker._trackEvent('Icon details','Submit tags',parseInt(iconid));	
			return false;
		});
		return false;
	}
	
	
	function tagfocus(obj)
	{
		tagsedited = 1;
		return false;
	}
	
	*/
	
	function tagcancel()
	{
		$(document).find('.tagmenu').hide();
		tagsedited = 0;
		return false;
	}







/* ---------------------------- RATING ----------------------------- */
	
	function rate(iconid,value,link)
	{
		i=0;
		$('.star').each(function()
		{
			if(i < value)
			{
				$(this).addClass('clicked');
			}
			i++;
		});
	
		$.get("/ajax/rate/", 
		{ 
			iconid: iconid,
			value: value
		},
		function(data)
		{
			$('#checkmark-'+iconid).css("display","inline");
			return false;
		});	
		//pageTracker._trackEvent('Icon details','Rate',value);
		_gaq.push(['_trackEvent','Icon details','Rate',value]);
		return false;
	}
	
	function initstars()
	{
		$(".star").hover(function()
		{
			$(this).addClass('hover');	
			$(this).prevALL('.star').addClass('hover');	
			return false;
		},
		function()
		{
			$(this).removeClass('hover');	
			$(this).prevALL('.star').removeClass('hover');	
			return false;	
		});
		
		
		$.fn.reverse = function() {
	    return this.pushStack(this.get().reverse(), arguments);
		};
	
		// create two new functions: prevALL and nextALL. they're very similar, hence this style.
		$.each( ['prev', 'next'], function(unusedIndex, name) {
		    $.fn[ name + 'ALL' ] = function(matchExpr) {
		        // get all the elements in the body, including the body.
		        var $all = $('body').find('*').andSelf();
		
		        // slice the $all object according to which way we're looking
		        $all = (name == 'prev')
		             ? $all.slice(0, $all.index(this)).reverse()
		             : $all.slice($all.index(this) + 1)
		        ;
		        // filter the matches if specified
		        if (matchExpr) $all = $all.filter(matchExpr);
		        return $all;
		    };
		});
	}



/* -------------------------- SETTINGS --------------------------- */

function updatenumber()
{
	val = $('.numberselected').attr("id").replace('n','');
	name = 'numberofresults';	
	$.get("/ajax/cookie/", 
	{ 
		name: name,
		val: val
	},
	function(data)
	{
		//alert(data);
		updatesearch();
	});		
	//pageTracker._trackEvent('Settings','Change number',val);	
	_gaq.push(['_trackEvent','Settings','Change number',val]);
	val = null;
	name = null;
	return false;
}

function updatefilter()
{
	val = $('#licensefilter').val();
	$.get("/ajax/cookie/", 
	{ 
		name: 'licensefilter',
		val: val
	},
	function(data)
	{
		//alert(data);
		updatesearch();
	});		
	//pageTracker._trackEvent('Settings','Change filter',val);	
	_gaq.push(['_trackEvent','Settings','Change filter',val]);
	val = null;
	name = null;
	return false;
}




var useBSNns;
if (useBSNns)
{
	if (typeof(bsn) == "undefined")
		bsn = {}
	_bsn = bsn;
}
else
{
	_bsn = this;
}

if (typeof(_bsn.Autosuggest) == "undefined")
	_bsn.Autosuggest = {}

_bsn.AutoSuggest = function (fldID, param)
{
	// no DOM - give up!
	if (!document.getElementById)
		return false;
	
	// get field via DOM
	this.fld = _bsn.DOM.getElement(fldID);

	if (!this.fld)
		return false;
	
	// init variables
	this.sInput 		= "";
	this.nInputChars 	= 0;
	this.aSuggestions 	= [];
	this.iHighlighted 	= 0;
	
	// parameters object
	this.oP = (param) ? param : {};
	
	// defaults	
	if (!this.oP.minchars)									this.oP.minchars = 3;
	if (!this.oP.method)									this.oP.meth = "get";
	if (!this.oP.varname)									this.oP.varname = "input";
	if (!this.oP.className)									this.oP.className = "autosuggest";
	if (!this.oP.timeout)									this.oP.timeout = 2000;
	if (!this.oP.delay)										this.oP.delay = 0;
	if (!this.oP.offsety)									this.oP.offsety = 0;
	if (!this.oP.shownoresults)								this.oP.shownoresults = false;
	if (!this.oP.noresults)									this.oP.noresults = "No exact match";
	if (!this.oP.maxheight && this.oP.maxheight !== 0)		this.oP.maxheight = 12;
	if (!this.oP.cache && this.oP.cache != false)			this.oP.cache = true;
	
	// set keyup handler for field
	// and prevent autocomplete from client
	var pointer = this;
	
	// NOTE: not using addEventListener because UpArrow fired twice in Safari
	//_bsn.DOM.addEvent( this.fld, 'keyup', function(ev){ return pointer.onKeyPress(ev); } );	
	this.fld.onkeypress 	= function(ev){ return pointer.onKeyPress(ev); }
	this.fld.onkeyup 		= function(ev){ return pointer.onKeyUp(ev); }
	
	this.fld.setAttribute("autocomplete","off");
}

_bsn.AutoSuggest.prototype.onKeyPress = function(ev)
{
	var key = (window.event) ? window.event.keyCode : ev.keyCode;

	// set responses to keydown events in the field
	// this allows the user to use the arrow keys to scroll through the results
	// ESCAPE clears the list
	// TAB sets the current highlighted value
	var RETURN = 13;
	var TAB = 9;
	var ESC = 27;
	var bubble = true;

	switch(key)
	{
		case RETURN:
			this.setHighlightedValue();
			bubble = false;
			document.getElementById("searchform").submit();
			break;
		case ESC:
			this.clearSuggestions();
			break;
	}

	return bubble;
}

_bsn.AutoSuggest.prototype.onKeyUp = function(ev)
{
	var key = (window.event) ? window.event.keyCode : ev.keyCode;
	// set responses to keydown events in the field
	// this allows the user to use the arrow keys to scroll through the results
	// ESCAPE clears the list
	// TAB sets the current highlighted value
	var ARRUP = 38;
	var ARRDN = 40;	
	var bubble = true;

	switch(key)
	{
		case ARRUP:
			this.changeHighlight(key);
			bubble = false;
			break;
		case ARRDN:
			this.changeHighlight(key);
			bubble = false;
			break;
		default:
			this.getSuggestions(this.fld.value);
	}
	return bubble;
}

_bsn.AutoSuggest.prototype.getSuggestions = function (val)
{
	// if input stays the same, do nothing
	if (val == this.sInput)
		return false;
	
	// input length is less than the min required to trigger a request
	// reset input string
	// do nothing
	if (val.length < this.oP.minchars)
	{
		this.sInput = "";
		return false;
	}
	
	// if caching enabled, and user is typing (ie. length of input is increasing)
	// filter results out of aSuggestions from last request
	if (val.length>this.nInputChars && this.aSuggestions.length && this.oP.cache)
	{
		var arr = [];
		for (var i=0;i<this.aSuggestions.length;i++)
		{
			if (this.aSuggestions[i].value.substr(0,val.length).toLowerCase() == val.toLowerCase())
				arr.push( this.aSuggestions[i] );
		}
		
		this.sInput = val;
		this.nInputChars = val.length;
		this.aSuggestions = arr;
		this.createList(this.aSuggestions);
		return false;
	}
	else
	// do new request
	{
		this.sInput = val;
		this.nInputChars = val.length;
		var pointer = this;
		clearTimeout(this.ajID);
		this.ajID = setTimeout( function() { pointer.doAjaxRequest() }, this.oP.delay );
	}
	return false;
}

_bsn.AutoSuggest.prototype.doAjaxRequest = function ()
{
	var pointer = this;
	
	// create ajax request
	var url = this.oP.script+this.oP.varname+"="+escape(this.fld.value);
	var meth = this.oP.meth;
	var onSuccessFunc = function (req) { pointer.setSuggestions(req) };
	var onErrorFunc = function (status) 
	{ 
	//alert("AJAX error: "+status); 
	};

	var myAjax = new _bsn.Ajax();
	myAjax.makeRequest( url, meth, onSuccessFunc, onErrorFunc );
}

_bsn.AutoSuggest.prototype.setSuggestions = function (req)
{
	this.aSuggestions = [];
	if (this.oP.json)
	{
		var jsondata = eval('(' + req.responseText + ')');
		for (var i=0;i<jsondata.results.length;i++)
		{
			this.aSuggestions.push(  { 'id':jsondata.results[i].id, 'value':jsondata.results[i].value, 'info':jsondata.results[i].info }  );
		}
	}
	else
	{
		var xml = req.responseXML;
	
		// traverse xml
		//
		try
		{
			var results = xml.getElementsByTagName('results')[0].childNodes;
			
			for (var i=0;i<results.length;i++)
			{
				if (results[i].hasChildNodes())
					this.aSuggestions.push(  { 'id':results[i].getAttribute('id'), 'value':results[i].childNodes[0].nodeValue, 'info':results[i].getAttribute('info') }  );
			}
		}
		catch(err)
		{
			//alert(err);
		}	
	}
	
	this.idAs = "as_"+this.fld.id;
	this.createList(this.aSuggestions);
}

_bsn.AutoSuggest.prototype.createList = function(arr)
{
	var pointer = this;
	
	// get rid of old list
	// and clear the list removal timeout
	//
	_bsn.DOM.removeElement(this.idAs);
	this.killTimeout();
	
	// create holding div
	//
	var div = _bsn.DOM.createElement("div", {id:this.idAs, className:this.oP.className});	
	var hcorner = _bsn.DOM.createElement("div", {className:"as_corner"});
	var hbar = _bsn.DOM.createElement("div", {className:"as_bar"});
	var header = _bsn.DOM.createElement("div", {className:"as_header"});
	header.appendChild(hcorner);
	header.appendChild(hbar);
	div.appendChild(header);
	
	// create and populate ul
	//
	var ul = _bsn.DOM.createElement("ul", {id:"as_ul"});
	
	// loop throught arr of suggestions
	// creating an LI element for each suggestion

	/* Set max number of items in list */
	var length;
	if(arr.length > this.oP.maxheight)
		length = this.oP.maxheight;
	else
		length = arr.length;
	
	for (var i=0;i<length;i++)
	{
		// format output with the input enclosed in a EM element
		// (as HTML, not DOM)
		//
		var val = arr[i].value;
		var st = val.toLowerCase().indexOf( this.sInput.toLowerCase() );
		var output = val.substring(0,st) + "<em>" + val.substring(st, st+this.sInput.length) + "</em>" + val.substring(st+this.sInput.length);
		
		
		var span 		= _bsn.DOM.createElement("span", {}, output, true);
		if (arr[i].info != "")
		{
			var br			= _bsn.DOM.createElement("br", {});
			span.appendChild(br);
			var small		= _bsn.DOM.createElement("small", {}, arr[i].info);
			span.appendChild(small);
		}
		
		var a 		= _bsn.DOM.createElement("a", { href:"#" });
		var tl 		= _bsn.DOM.createElement("span", {className:"tl"}, " ");
		var tr 		= _bsn.DOM.createElement("span", {className:"tr"}, " ");
		a.appendChild(tl);
		a.appendChild(tr);
		a.appendChild(span);
		a.name = i+1;
		a.onclick = function () { pointer.setHighlightedValue(); return false; }
		a.onmouseover = function () { pointer.setHighlight(this.name); }
		var li 			= _bsn.DOM.createElement(  "li", {}, a  );
		ul.appendChild( li );
	}
	
	// no results
	if (arr.length == 0)
	{
		var li 			= _bsn.DOM.createElement(  "li", {className:"as_warning"}, this.oP.noresults  );
		ul.appendChild( li );
	}
	
	div.appendChild( ul );
	var fcorner = _bsn.DOM.createElement("div", {className:"as_corner"});
	var fbar = _bsn.DOM.createElement("div", {className:"as_bar"});
	var footer = _bsn.DOM.createElement("div", {className:"as_footer"});
	footer.appendChild(fcorner);
	footer.appendChild(fbar);
	div.appendChild(footer);
		
	// get position of target textfield
	// position holding div below it
	// set width of holding div to width of field
	var pos = _bsn.DOM.getPos(this.fld);	
	div.style.left 		= pos.x + "px";
	div.style.top 		= ( pos.y + this.fld.offsetHeight + this.oP.offsety ) + "px";
	div.style.width 	= this.fld.offsetWidth + "px";
	
	// set mouseover functions for div
	// when mouse pointer leaves div, set a timeout to remove the list after an interval
	// when mouse enters div, kill the timeout so the list won't be removed
	div.onmouseover 	= function(){ pointer.killTimeout() }
	div.onmouseout 		= function(){ pointer.resetTimeout() }

	// add DIV to document
	document.getElementsByTagName("body")[0].appendChild(div);
	
	// currently no item is highlighted
	this.iHighlighted = 0;
	
	// remove list after an interval
	var pointer = this;
	this.toID = setTimeout(function () { pointer.clearSuggestions() }, this.oP.timeout);
}

_bsn.AutoSuggest.prototype.changeHighlight = function(key)
{	
	var list = _bsn.DOM.getElement("as_ul");
	if (!list)
		return false;
	var n;

	if (key == 40)
		n = this.iHighlighted + 1;
	else if (key == 38)
		n = this.iHighlighted - 1;
	
	if (n > list.childNodes.length)
		n = list.childNodes.length;
	if (n < 1)
		n = 1;
	
	this.setHighlight(n);
}

_bsn.AutoSuggest.prototype.setHighlight = function(n)
{
	var list = _bsn.DOM.getElement("as_ul");
	if (!list)
		return false;
	
	if (this.iHighlighted > 0)
		this.clearHighlight();
	
	this.iHighlighted = Number(n);
	list.childNodes[this.iHighlighted-1].className = "as_highlight";
	this.killTimeout();
}


_bsn.AutoSuggest.prototype.clearHighlight = function()
{
	var list = _bsn.DOM.getElement("as_ul");
	if (!list)
		return false;
	
	if (this.iHighlighted > 0)
	{
		list.childNodes[this.iHighlighted-1].className = "";
		this.iHighlighted = 0;
	}
}


_bsn.AutoSuggest.prototype.setHighlightedValue = function ()
{
	if (this.iHighlighted)
	{
		this.sInput = this.fld.value = this.aSuggestions[ this.iHighlighted-1 ].value;
		
		// move cursor to end of input (safari)
		this.fld.focus();
		if (this.fld.selectionStart)
			this.fld.setSelectionRange(this.sInput.length, this.sInput.length);
		this.clearSuggestions();

		// pass selected object to callback function, if exists
		if (typeof(this.oP.callback) == "function")
			this.oP.callback( this.aSuggestions[this.iHighlighted-1] );
	}
}

_bsn.AutoSuggest.prototype.killTimeout = function()
{
	clearTimeout(this.toID);
}

_bsn.AutoSuggest.prototype.resetTimeout = function()
{
	clearTimeout(this.toID);
	var pointer = this;
	this.toID = setTimeout(function () { pointer.clearSuggestions() }, 1000);
}

_bsn.AutoSuggest.prototype.clearSuggestions = function ()
{
	
	this.killTimeout();
	
	var ele = _bsn.DOM.getElement(this.idAs);
	var pointer = this;
	if (ele)
	{
		var fade = new _bsn.Fader(ele,1,0,250,function () { _bsn.DOM.removeElement(pointer.idAs) });
	}
}

// AJAX PROTOTYPE _____________________________________________


if (typeof(_bsn.Ajax) == "undefined")
	_bsn.Ajax = {}

_bsn.Ajax = function ()
{
	this.req = {};
	this.isIE = false;
}

_bsn.Ajax.prototype.makeRequest = function (url, meth, onComp, onErr)
{	
	if (meth != "POST")
		meth = "GET";
	
	this.onComplete = onComp;
	this.onError = onErr;
	
	var pointer = this;
	
	// branch for native XMLHttpRequest object
	if (window.XMLHttpRequest)
	{
		this.req = new XMLHttpRequest();
		this.req.onreadystatechange = function () { pointer.processReqChange() };
		this.req.open("GET", url, true); //
		this.req.send(null);
	// branch for IE/Windows ActiveX version
	}
	else if (window.ActiveXObject)
	{
		this.req = new ActiveXObject("Microsoft.XMLHTTP");
		if (this.req)
		{
			this.req.onreadystatechange = function () { pointer.processReqChange() };
			this.req.open(meth, url, true);
			this.req.send();
		}
	}
}

_bsn.Ajax.prototype.processReqChange = function()
{
		// only if req shows "loaded"
	if (this.req.readyState == 4) {
		// only if "OK"
		if (this.req.status == 200)
		{
			this.onComplete( this.req );
		} else {
			this.onError( this.req.status );
		}
	}
}

// DOM PROTOTYPE _____________________________________________

if (typeof(_bsn.DOM) == "undefined")
	_bsn.DOM = {}

_bsn.DOM.createElement = function ( type, attr, cont, html )
{
	var ne = document.createElement( type );
	if (!ne)
		return false;
		
	for (var a in attr)
		ne[a] = attr[a];
		
	if (typeof(cont) == "string" && !html)
		ne.appendChild( document.createTextNode(cont) );
	else if (typeof(cont) == "string" && html)
		ne.innerHTML = cont;
	else if (typeof(cont) == "object")
		ne.appendChild( cont );

	return ne;
}

_bsn.DOM.clearElement = function ( id )
{
	var ele = this.getElement( id );
	
	if (!ele)
		return false;
	
	while (ele.childNodes.length)
		ele.removeChild( ele.childNodes[0] );
	
	return true;
}


_bsn.DOM.removeElement = function ( ele )
{
	var e = this.getElement(ele);
	
	if (!e)
		return false;
	else if (e.parentNode.removeChild(e))
		return true;
	else
		return false;
}

_bsn.DOM.replaceContent = function ( id, cont, html )
{
	var ele = this.getElement( id );
	
	if (!ele)
		return false;
	
	this.clearElement( ele );
	
	if (typeof(cont) == "string" && !html)
		ele.appendChild( document.createTextNode(cont) );
	else if (typeof(cont) == "string" && html)
		ele.innerHTML = cont;
	else if (typeof(cont) == "object")
		ele.appendChild( cont );
}

_bsn.DOM.getElement = function ( ele )
{
	if (typeof(ele) == "undefined")
	{
		return false;
	}
	else if (typeof(ele) == "string")
	{
		var re = document.getElementById( ele );
		if (!re)
			return false;
		else if (typeof(re.appendChild) != "undefined" ) {
			return re;
		} else {
			return false;
		}
	}
	else if (typeof(ele.appendChild) != "undefined")
		return ele;
	else
		return false;
}

_bsn.DOM.appendChildren = function ( id, arr )
{
	var ele = this.getElement( id );
	
	if (!ele)
		return false;
	
	if (typeof(arr) != "object")
		return false;
		
	for (var i=0;i<arr.length;i++)
	{
		var cont = arr[i];
		if (typeof(cont) == "string")
			ele.appendChild( document.createTextNode(cont) );
		else if (typeof(cont) == "object")
			ele.appendChild( cont );
	}
}

_bsn.DOM.getPos = function ( ele )
{
	var ele = this.getElement(ele);
	var obj = ele;
	var curleft = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			curleft += obj.offsetLeft
			obj = obj.offsetParent;
		}
	}
	else if (obj.x)
		curleft += obj.x;

	var obj = ele;
	var curtop = 0;
	
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			curtop += obj.offsetTop
			obj = obj.offsetParent;
		}
	}
	else if (obj.y)
		curtop += obj.y;

	return {x:curleft, y:curtop}
}

// FADER PROTOTYPE _____________________________________________
if (typeof(_bsn.Fader) == "undefined")
	_bsn.Fader = {}

_bsn.Fader = function (ele, from, to, fadetime, callback)
{	
	if (!ele)
		return false;
	
	this.ele = ele;
	
	this.from = from;
	this.to = to;
	
	this.callback = callback;
	
	this.nDur = fadetime;
		
	this.nInt = 50;
	this.nTime = 0;
	
	var p = this;
	this.nID = setInterval(function() { p._fade() }, this.nInt);
}

_bsn.Fader.prototype._fade = function()
{
	this.nTime += this.nInt;
	
	var ieop = Math.round( this._tween(this.nTime, this.from, this.to, this.nDur) * 100 );
	var op = ieop / 100;
	
	if (this.ele.filters) // internet explorer
	{
		try
		{
			this.ele.filters.item("DXImageTransform.Microsoft.Alpha").opacity = ieop;
		} catch (e) { 
			// If it is not set initially, the browser will throw an error.  This will set it if it is not set yet.
			this.ele.style.filter = 'progid:DXImageTransform.Microsoft.Alpha(opacity='+ieop+')';
		}
	}
	else // other browsers
	{
		this.ele.style.opacity = op;
	}
	
	if (this.nTime == this.nDur)
	{
		clearInterval( this.nID );
		if (this.callback != undefined)
			this.callback();
	}
}



_bsn.Fader.prototype._tween = function(t,b,c,d)
{
	return b + ( (c-b) * (t/d) );
}



jQuery.cookie = function(name, value, options) {
    if (typeof value != 'undefined') { // name and value given, set cookie
        options = options || {};
        if (value === null) {
            value = '';
            options.expires = -1;
        }
        var expires = '';
        if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) {
            var date;
            if (typeof options.expires == 'number') {
                date = new Date();
                date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000));
            } else {
                date = options.expires;
            }
            expires = '; expires=' + date.toUTCString(); // use expires attribute, max-age is not supported by IE
        }
        // CAUTION: Needed to parenthesize options.path and options.domain
        // in the following expressions, otherwise they evaluate to undefined
        // in the packed version for some reason...
        var path = options.path ? '; path=' + (options.path) : '';
        var domain = options.domain ? '; domain=' + (options.domain) : '';
        var secure = options.secure ? '; secure' : '';
        document.cookie = [name, '=', encodeURIComponent(value), expires, path, domain, secure].join('');
    } else { // only name given, get cookie
        var cookieValue = null;
        if (document.cookie && document.cookie != '') {
            var cookies = document.cookie.split(';');
            for (var i = 0; i < cookies.length; i++) {
                var cookie = jQuery.trim(cookies[i]);
                // Does this cookie string begin with the name we want?
                if (cookie.substring(0, name.length + 1) == (name + '=')) {
                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                    break;
                }
            }
        }
        return cookieValue;
    }
};






/* COPY TO CLIPBOARD PLUGIN */

jQuery.copy=function(t)
{
	if(typeof t=='undefined')
	{
		t='';
	}
	d=document;
	if (window.clipboardData)
	{
		window.clipboardData.setData('Text',t);
	}
	else
	{
		var f='flashcopier';
		if(!d.getElementById(f))
		{
			var dd=d.createElement('div');
			dd.id=f;
			d.body.appendChild(dd);
		}
		d.getElementById(f).innerHTML='';
		var i='<embed src="copy.swf" FlashVars="clipboard='+encodeURIComponent(t)+'" width="0" height="0" type="application/x-shockwave-flash"></embed>';
		d.getElementById(f).innerHTML=i;
	}
}








/*
 * --------------------------------------------------------------------
 * jQuery-Plugin - selectToUISlider - creates a UI slider component from a select element(s)
 * by Scott Jehl, scott@filamentgroup.com
 * http://www.filamentgroup.com
 * reference article: http://www.filamentgroup.com/lab/update_jquery_ui_16_slider_from_a_select_element/
 * demo page: http://www.filamentgroup.com/examples/slider_v2/index.html
 * 
 * Copyright (c) 2008 Filament Group, Inc
 * Dual licensed under the MIT (filamentgroup.com/examples/mit-license.txt) and GPL (filamentgroup.com/examples/gpl-license.txt) licenses.
 *
 * Usage Notes: please refer to our article above for documentation
 *  
 * --------------------------------------------------------------------
 */

jQuery.fn.selectToUISlider = function(settings){
	var selects = jQuery(this);
	
	//accessible slider options
	var options = jQuery.extend({
		labels: 3, //number of visible labels
		tooltip: true, //show tooltips, boolean
		tooltipSrc: 'text',//accepts 'value' as well
		labelSrc: 'value',//accepts 'value' as well	,
		sliderOptions: null
	}, settings);


	//handle ID attrs - selects each need IDs for handles to find them
	var handleIds = (function(){
		var tempArr = [];
		selects.each(function(){
			tempArr.push('handle_'+jQuery(this).attr('id'));
		});
		return tempArr;
	})();
	
	//array of all option elements in select element (ignores optgroups)
	var selectOptions = (function(){
		var opts = [];
		selects.eq(0).find('option').each(function(){
			opts.push({
				value: jQuery(this).attr('value'),
				text: jQuery(this).text()
			});
		});
		return opts;
	})();
	
	//array of opt groups if present
	var groups = (function(){
		if(selects.eq(0).find('optgroup').size()>0){
			var groupedData = [];
			selects.eq(0).find('optgroup').each(function(i){
				groupedData[i] = {};
				groupedData[i].label = jQuery(this).attr('label');
				groupedData[i].options = [];
				jQuery(this).find('option').each(function(){
					groupedData[i].options.push({text: jQuery(this).text(), value: jQuery(this).attr('value')});
				});
			});
			return groupedData;
		}
		else return null;
	})();	
	//check if obj is array
	function isArray(obj) {
		return obj.constructor == Array;
	}
	//return tooltip text from option index
	function ttText(optIndex){
		return (options.tooltipSrc == 'text') ? selectOptions[optIndex].text : selectOptions[optIndex].value;
	}
	
	//plugin-generated slider options (can be overridden)
	var sliderOptions = {
		step: 1,
		min: 0,
		orientation: 'horizontal',
		max: selectOptions.length-1,
		range: selects.length > 1,//multiple select elements = true
		slide: function(e, ui) 
		{
			//slide function
				var thisHandle = jQuery(ui.handle);
				//handle feedback 
				var textval = ttText(ui.value);
				thisHandle
					.attr('aria-valuetext', textval)
					.attr('aria-valuenow', ui.value)
					.find('.ui-slider-tooltip .ttContent')
						.text( textval );

				//control original select menu
				var currSelect = jQuery('#' + thisHandle.attr('id').split('handle_')[1]);
				currSelect.find('option').eq(ui.value).attr('selected', 'selected');

				$("#min-disp").val($("#valueA").val() + ' px');
				$("#max-disp").val($("#valueB").val() + ' px');
		},
		stop: function(event, ui) 
		{
			var minimum = $("#valueA").val();
			var maximum = $("#valueB").val();
			
			//pageTracker._trackEvent("Settings","Change sizes","Minimum",parseInt(minimum));
			//pageTracker._trackEvent("Settings","Change sizes","Maximum",parseInt(maximum));
			
			$.get("/ajax/cookie/", 
			{ 
				name: "minimum",
				val: minimum
			},
			function(data)
			{
				return false;
			});
				
			$.get("/ajax/cookie/", 
			{ 
				name: "maximum",
				val: maximum
			},
			function(data)
			{
				updatesearch();
				return false;
			});
		},
		values: (function(){
			var values = [];
			selects.each(function(){
				values.push( jQuery(this).get(0).selectedIndex );
			});
			return values;
		})()
	};
	
	//slider options from settings
	options.sliderOptions = (settings) ? jQuery.extend(sliderOptions, settings.sliderOptions) : sliderOptions;
		
	//select element change event	
	selects.bind('change keyup click', function()
	{
		var thisIndex = jQuery(this).get(0).selectedIndex;
		var thisHandle = jQuery('#handle_'+ jQuery(this).attr('id'));
		var handleIndex = thisHandle.data('handleNum');
		thisHandle.parents('.ui-slider:eq(0)').slider("values", handleIndex, thisIndex);
	});
	

	//create slider component div
	var sliderComponent = jQuery('<div></div>');

	//CREATE HANDLES
	selects.each(function(i){
		var hidett = '';
		
		//associate label for ARIA
		var thisLabel = jQuery('label[for=' + jQuery(this).attr('id') +']');
		//labelled by aria doesn't seem to work on slider handle. Using title attr as backup
		var labelText = (thisLabel.size()>0) ? 'Slider control for '+ thisLabel.text()+'' : '';
		var thisLabelId = thisLabel.attr('id') || thisLabel.attr('id', 'label_'+handleIds[i]).attr('id');
		
		
		if( options.tooltip == false ){hidett = ' style="display: none;"';}
		jQuery('<a '+
				'href="#" tabindex="0" '+
				'id="'+handleIds[i]+'" '+
				'class="ui-slider-handle" '+
				'role="slider" '+
				'aria-labelledby="'+thisLabelId+'" '+
				'aria-valuemin="'+options.sliderOptions.min+'" '+
				'aria-valuemax="'+options.sliderOptions.max+'" '+
				'aria-valuenow="'+options.sliderOptions.values[i]+'" '+
				'aria-valuetext="'+ttText(options.sliderOptions.values[i])+'" '+
			'><span class="screenReaderContext">'+labelText+'</span>'+
			'<span class="ui-slider-tooltip ui-widget-content ui-corner-all"'+ hidett +'><span class="ttContent"></span>'+
				'<span class="ui-tooltip-pointer-down ui-widget-content"><span class="ui-tooltip-pointer-down-inner"></span></span>'+
			'</span></a>')
			.data('handleNum',i)
			.appendTo(sliderComponent);
	});
	
	//CREATE SCALE AND TICS
	
	//write dl if there are optgroups
	if(groups) {
		var inc = 0;
		var scale = sliderComponent.append('<dl class="ui-slider-scale ui-helper-reset" role="presentation"></dl>').find('.ui-slider-scale:eq(0)');
		jQuery(groups).each(function(h){
			scale.append('<dt style="width: '+ (100/groups.length).toFixed(2) +'%' +'; left:'+ (h/(groups.length-1) * 100).toFixed(2)  +'%' +'"><span>'+this.label+'</span></dt>');//class name becomes camelCased label
			var groupOpts = this.options;
			jQuery(this.options).each(function(i){
				var style = (inc == selectOptions.length-1 || inc == 0) ? 'style="display: none;"' : '' ;
				var labelText = (options.labelSrc == 'text') ? groupOpts[i].text : groupOpts[i].value;
				scale.append('<dd style="left:'+ leftVal(inc) +'"><span class="ui-slider-label">'+ labelText +'</span><span class="ui-slider-tic ui-widget-content"'+ style +'></span></dd>');
				inc++;
			});
		});
	}
	//write ol
	else {
		var scale = sliderComponent.append('<ol class="ui-slider-scale ui-helper-reset" role="presentation"></ol>').find('.ui-slider-scale:eq(0)');
		jQuery(selectOptions).each(function(i){
			var style = (i == selectOptions.length-1 || i == 0) ? 'style="display: none;"' : '' ;
			var labelText = (options.labelSrc == 'text') ? this.text : this.value;
			scale.append('<li style="left:'+ leftVal(i) +'"><span class="ui-slider-label">'+ labelText +'</span><span class="ui-slider-tic ui-widget-content"'+ style +'></span></li>');
		});
	}
	
	function leftVal(i)
	{
		return (i/(selectOptions.length-1) * 100).toFixed(2)  +'%';
	}
	
	//show and hide labels depending on labels pref
	//show the last one if there are more than 1 specified
	if(options.labels > 1) sliderComponent.find('.ui-slider-scale li:last span.ui-slider-label, .ui-slider-scale dd:last span.ui-slider-label').addClass('ui-slider-label-show');

	//set increment
	var increm = Math.max(1, Math.round(selectOptions.length / options.labels));
	//show em based on inc
	for(var j=0; j<selectOptions.length; j+=increm){
		if((selectOptions.length - j) > increm){//don't show if it's too close to the end label
			sliderComponent.find('.ui-slider-scale li:eq('+ j +') span.ui-slider-label, .ui-slider-scale dd:eq('+ j +') span.ui-slider-label').addClass('ui-slider-label-show');
		}
	}

	//style the dt's
	sliderComponent.find('.ui-slider-scale dt').each(function(i){
		jQuery(this).css({
			'left': ((100 /( groups.length))*i).toFixed(2) + '%'
		});
	});
	

	//inject and return 
	sliderComponent
	.insertAfter(jQuery(this).eq(this.length-1))
	.slider(options.sliderOptions)
	.attr('role','application')
	.find('.ui-slider-label')
	.each(function(){
		jQuery(this).css('marginLeft', -jQuery(this).width()/2);
	});
	
	//update tooltip arrow inner color
	sliderComponent.find('.ui-tooltip-pointer-down-inner').each(function(){
				var bWidth = jQuery('.ui-tooltip-pointer-down-inner').css('borderTopWidth');
				var bColor = jQuery(this).parents('.ui-slider-tooltip').css('backgroundColor')
				jQuery(this).css('border-top', bWidth+' solid '+bColor);
	});
	
	var values = sliderComponent.slider('values');
	
	if(isArray(values)){
		jQuery(values).each(function(i){
			sliderComponent.find('.ui-slider-tooltip .ttContent').eq(i).text( ttText(this) );
		});
	}
	else {
		sliderComponent.find('.ui-slider-tooltip .ttContent').eq(0).text( ttText(values) );
	}
	
	return this;
}

$(function() {                  
    // positions for each overlay 
    var positions = [];     
         
    // setup triggers 
    $("button[rel]").each(function(i) { 
             
        $(this).overlay({ 
 
            // common configuration for each overlay 
            oneInstance: false,  
            closeOnClick: true,  
              
            // setup custom finish position 
            finish: positions[i]} 
        );             
    }); 
     
});