
function PDRTJS_url_encode( s ) {
	return encodeURIComponent( s ).replace( /\%20/g, '+' ).replace( /!/g, '%21' ).replace( /'/g, '%27' ).replace( /\(/g, '%28' ).replace( /\)/g, '%29' ).replace( /\*/g, '%2A' ).replace( /\~/g, '%7E' );
}

function PDRTJS_is_defined( v ) {
    return (typeof v == "undefined")?  false: true;
}

// Default Text Strings
var ratings_text = new Array();
ratings_text['text_vote'] = 'Vote';
ratings_text['text_votes'] = 'Votes';
ratings_text['text_rate_this'] = 'Rate This';
ratings_text['text_1_star'] = '1 star';
ratings_text['text_2_star'] = '2 stars';
ratings_text['text_3_star'] = '3 stars';
ratings_text['text_4_star'] = '4 stars';
ratings_text['text_5_star'] = '5 stars';
ratings_text['text_thank_you'] = 'Thank You';
ratings_text['text_rate_up'] = 'Rate Up';
ratings_text['text_rate_down'] = 'Rate Down';
ratings_text['text_popcontent'] = 'Most Popular Content';
ratings_text['text_close'] = 'Close';
ratings_text['text_all'] = 'All';
ratings_text['text_today'] = 'Today';
ratings_text['text_thisweek'] = 'This Week';
ratings_text['text_thismonth'] = 'This Month';
ratings_text['text_rated'] = 'Rated';
ratings_text['text_noratings'] = 'There are no rated items for this period';               

function PDRTJS_RATING(settings) {

    var server = 'http://polldaddy.com';

    for (var property in settings) {
        this[property] = settings[property];
    }

    function $(id) {
        return document.getElementById(id);
    }

    var pc = '<p style="padding: 0px; margin: 0px; clear: both;"></p>';
    var c = 0;
    var token = '';

    this.make_call = function (url) {
        if (this.override != null) {
            url = url + '&override=true';
        }

        var s = document.createElement('SCRIPT');
        s.charset = 'utf-8';
        s.src = server + url;
        var h = document.getElementsByTagName('head').item(0);
        h.appendChild(s);

    }

    this.callback = function (cb_id, cb_unique_id, cb_type, cb_rating, cb_voter_id, cb_vote_change) {

        if (this.callback_url != null) {

            true_callback_url = this.callback_url.replace(/{id}/, cb_id);
            true_callback_url = true_callback_url.replace(/{unique_id}/, cb_unique_id);
            true_callback_url = true_callback_url.replace(/{type}/, cb_type);
            true_callback_url = true_callback_url.replace(/{r}/, cb_rating);
            true_callback_url = true_callback_url.replace(/{voter_id}/, cb_voter_id);

            if (cb_type == 'stars') {
                true_callback_url = true_callback_url.replace(/{scores}/, this.votes + ',' + this.avg_rating);
            }
            else {
                true_callback_url = true_callback_url.replace(/{scores}/, this.nero_up + ',' + this.nero_dn);
            }

            if (cb_vote_change) {
                true_callback_url = true_callback_url + '&change=true';
            }

            var s = document.createElement('SCRIPT');
            s.charset = 'utf-8';
            s.src = true_callback_url;
            var h = document.getElementsByTagName('head').item(0);
            h.appendChild(s);

        }
    }

    this.get_rating = function () {
        this.varname = 'PDRTJS_' + this.id + this.item_id;
        this.make_call('/ratings/rate.php?cmd=get&id=' + this.id + '&uid=' + this.unique_id + '&item_id=' + this.item_id);
    }

    this.init = function () {
        eval('settings = PDRTJS_settings_' + this.id + this.item_id + ';');
        for (var property in settings) {
            this[property] = settings[property];
        }
        this.build();
    }

    this.build = function () {
        this.font = this.font_italic + ' ' + this.font_bold + ' ' + this.font_size + '/' + this.font_line_height + ' ' + this.font_family;

        var p = $('pd_rating_holder_' + this.id + this.item_id);
        p.style.display = 'inline-block';
        this.star_margin = '1px';

        if (this.custom_star.length > 0) {
            this.star_image = this.custom_star;
            this.star_margin = '1px';
        }
        else {
            if (this.type == 'stars') {
                this.star_image = 'http://i0.poll.fm/ratings/images/star-' + this.star_color + '-' + this.size + '.png';
            }
            else {
                this.star_image = 'http://i0.poll.fm/ratings/images/nero-' + this.star_color + '-' + this.size + '.png';
            }
        }
        this.image_size = '16px';

        if (this.size == 'med') {
            this.image_size = '20px';
        }
        else if (this.size == 'lrg') {
            this.image_size = '24px';
        }


        if (this.type == 'stars') {
            var h = '';
            var t = '';
            var image_pos = 'bottom left';
            var msg = this.text_rate_this;

            if (this.votes > 0) {
                image_pos = 'top left';
                msg = this.votes + ' ';
                if (this.votes == 1 && (typeof this.text_vote != "undefined")) msg += this.text_vote;
                else msg += this.text_votes;
            }

            if (this.font_position == 'right') {
                t = '<div id="' + this.varname + '_msg" style="float:left; padding-left: 5px; text-align: ' + this.font_align + '; font:' + this.font + '; color: #' + this.font_color + ';">' + msg + '</div>';
            }
            else {
                t = '<div id="' + this.varname + '_msg" style="text-align: ' + this.font_align + ';font:' + this.font + ';color: #' + this.font_color + ';">' + msg + '</div>';
            }

            if (this.font_position == 'top') {
                h += t + pc;
            }

            for (c = 1; c <= 5; c++) {
                if (this.avg_rating > 0) {
                    if (this.avg_rating < c) {
                        image_pos = 'bottom left';
                    }
                    if (this.avg_rating == (c - 1 + 0.5)) {
                        image_pos = 'center left';
                    }
                }
                h += '<div onmouseout="' + this.varname + '.rebuild();" onclick="' + this.varname + '.rate(' + c + ');" onmouseover="' + this.varname + '.hover(' + c + ');" id="' + this.varname + '_stars_' + c + '" style="cursor: pointer; width: ' + this.image_size + '; height: ' + this.image_size + '; background: url(' + this.star_image + ') ' + image_pos + '; float: left; margin-right: ' + this.star_margin + ';"></div>';
            }

			h += this.buildPopup();
			
            if (this.font_position == 'bottom' || this.font_position == 'right') {
                h += t + pc;
            }
            
            p.innerHTML = h + '<img src="http://pixel.quantserve.com/pixel/p-ab3gTb8xb3dLg.gif" style="display: none;" border="0" height="1" width="1" alt="Quantcast"/>';
        }
        else // nero
        {
            var h = '';
            var t = '';
            var image_pos_v = 'bottom';
            var image_pos_h = 'left';
            var msg = new Array();
            msg[0] = this.text_rate_this;
            msg[1] = '';
            msg[2] = '';
            var c = 0;

            if (this.nero_up != null) {
                msg[1] = this.nero_up;
            }
            else {
                this.nero_up = 0;
                msg[1] = '0';
            }

            if (this.nero_dn != null) {
                msg[2] = this.nero_dn;
            }
            else {
                this.nero_dn = 0;
                msg[2] = '0';
            }

            if (this.font_position == 'right') {
                t = '<div id="' + this.varname + '_msg" style="float:left; padding-left: 5px; text-align: ' + this.font_align + '; font:' + this.font + '; color: #' + this.font_color + ';">' + msg[0] + '</div>';
            }
            else {
                t = '<div id="' + this.varname + '_msg" style="text-align: ' + this.font_align + '; font:' + this.font + '; color: #' + this.font_color + ';">' + msg[0] + '</div>';
            }

            if (this.font_position == 'top') {
                h += t + pc;
            }

            for (c = 1; c <= 2; c++) {
                if (c == 2) {
                    image_pos_h = 'right';
                }
                h += '<div onmouseout="' + this.varname + '.rebuild();" onclick="' + this.varname + '.rate(' + c + ');" onmouseover="' + this.varname + '.hover(' + c + ');" id="' + this.varname + '_nero_' + c + '" style="cursor: pointer; width: ' + this.image_size + '; height: ' + this.image_size + '; background: url(' + this.star_image + ') ' + image_pos_v + ' ' + image_pos_h + '; float: left; margin: 0px;"></div>';
                h += '<div id="' + this.varname + '_msg_' + c + '" style="text-align: center; font:' + this.font + '; color: #' + this.font_color + '; float:left; padding: 0px 4px;">' + msg[c] + '</div>';
            }

			h += this.buildPopup();

            if (this.font_position == 'bottom') {
                h += pc + t + pc;
            }
            else if (this.font_position == 'right') {
                h += t + pc;
            }

            p.innerHTML = h + '<img src="http://pixel.quantserve.com/pixel/p-ab3gTb8xb3dLg.gif" style="display: none;" border="0" height="1" width="1" alt="Quantcast"/>';
        }
    }
    
    this.buildPopup = function () {
		var show = true;
		if ( this.popup == 'off' ) {
			show = false;
			this.get_results(99);
		}		
		if ( $('pd_popup_holder_' + this.id + this.item_id) == null ){
			var _css = '#pd_popup_holder_' + this.id + this.item_id + ' { position:absolute; display:none; width:' + ( show ? '350':'175' ) + 'px; height:auto; top:0px; left:0px; z-index:10000; border:solid 1px #CCC; background-color:white; padding:0px 15px;font-family:Arial,Sans;box-shadow: -10px 10px 20px rgba(0, 0, 0, .5);-webkit-box-shadow: 0px 0px 6px rgba(0, 0, 0, .25);-moz-box-shadow: 0px 0px 6px rgba(0, 0, 0, .25); }';
			var _body = document.getElementsByTagName('body') [0];
			var _div = document.createElement('div');
			_div.id = 'pd_popup_holder_' + this.id + this.item_id ;	
			_body.appendChild(_div);		
			var _style = document.createElement("style");
        	_style.setAttribute("type", "text/css");
        	_style.setAttribute("id", "pd_popup_holder_style_" + this.id + this.item_id);
			if (_style.styleSheet) _style.styleSheet.cssText = _css;
			else _style.appendChild(document.createTextNode(_css));			
			_body.appendChild(_style);
		}
		return '&nbsp;<div id="rating_info_' + this.id + this.item_id + '" style="display:' + ( show ? 'block':'none' ) + ';float:left;background:url(http://i0.poll.fm/images/ratings/info.png) no-repeat 3px 2px;width:16px;height:16px;cursor:pointer;" onmouseover="javascript:' + this.varname + '.togglePopup();return false;"><span style="display:none">i</span></div>';
	}

    this.togglePopup = function () {
        var popup = $('pd_popup_holder_' + this.id + this.item_id);
        if (popup.style.display == 'block') {
            popup.style.display = 'none';
            $('rating_info_' + this.id + this.item_id).style.border = '';
        } else {
        	this.get_results(0);
        }
    }

    this.showPopup = function () {
        var popup = $('pd_popup_holder_' + this.id + this.item_id);
        var target = $('rating_info_' + this.id + this.item_id);
        popup.style.display = 'block';
        var border = 1;
        var x_offset = $('pd_rating_holder_' + this.id + this.item_id).offsetWidth;
        var tp = this.getElementPos(target); // target pos
        var ts = this.getElementSize(target); // target size
        var vp = this.getViewPos(); // view pos
        var vs = this.getViewSize(); // view size
        var ps = this.getElementSize(popup);
        var a = x = y = 0;
        var b = c = 1;
        var l = (ts[b] + ps[b]) / 2;
        var left = 0;

        if (-vp[a] + tp[a] + ps[a] > vs[a]) { 
            if (-vp[a] + tp[a] + ts[a] / 2 > vs[a] / 2 && tp[a] + ts[a] - ps[a] >= 0) {
                x = tp[a] + ts[a] - ps[a] + (border * 2);
                left = 1;
            } else {
                x = tp[a] - x_offset + (border * 2);
            }
        } else { 
            x = tp[a] - x_offset + (border * 2);
        }

        if (-vp[b] + tp[b] + ts[b] + ps[b] - l + l * c > vs[b]) {
            if (-vp[b] + tp[b] + ts[b] / 2 > vs[b] / 2 && tp[b] + ts[b] - l - l * c >= 0) {
                y = tp[b] + ts[b] - l - l * c;
                if (left > 0) y -= border;
                else y += (border * 2);
            } else {
                y = tp[b] + ts[b] - l + l * c;
            }
        } else {
            if (tp[b] + ts[b] - l + l * c >= 0) {
                y = tp[b] + ts[b] - l + l * c - (border * 2) + 5;
            } else {
                y = tp[b] + ts[b] - l - l * c;
            }
        }

        popup.style.left = x + 'px';
        popup.style.top = y + 'px';
        
        /*console.log( 'i icon positon:' + tp );
        console.log( 'i icon size:' + ts );
        console.log( 'view position:' + vp );
        console.log( 'view size:' + vs );
        console.log( 'popup size:'+ ps );
        console.log( 'popup position:' + [x, y ] );*/
    }

    this.popdown = function (parent) {
        $('pd_popup_holder_' + this.id + this.item_id).style.display = 'none';
    }

    this.getElementPos = function (e) {
        var e1 = e2 = e;
        var x = y = 0;
        if (e1.offsetParent) {
            do {
                x += e1.offsetLeft;
                y += e1.offsetTop;
            } while (e1 = e1.offsetParent);
        }
        while ((e2 = e2.parentNode) && e2.nodeName.toUpperCase() !== 'BODY') {
            x -= e2.scrollLeft;
            y -= e2.scrollTop;
        }
        return [x, y];
    }


    this.getElementSize = function (e) {
        return [e.offsetWidth, e.offsetHeight];
    }


    this.getViewPos = function () {
        if (typeof window.pageYOffset === 'number') {
            return [window.pageXOffset, window.pageYOffset];
        } else if (document.body && (document.body.scrollLeft || document.body.scrollTop)) {
            return [document.body.scrollLeft, document.body.scrollTop];
        } else if (document.documentElement && (document.documentElement.scrollLeft || document.documentElement.scrollTop)) {
            return [document.documentElement.scrollLeft, document.documentElement.scrollTop];
        } else {
            return [0, 0];
        }
    }

    this.getViewSize = function () {
        if (typeof window.innerWidth === 'number') {
            return [window.innerWidth, window.innerHeight];
        } else if (document.body && (document.body.clientWidth || document.body.clientHeight)) {
            return [document.body.clientWidth, document.body.clientHeight];
        } else if (document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight)) {
            return [document.documentElement.clientWidth, document.documentElement.clientHeight];
        } else {
            return [0, 0];
        }
    }

    this.get_results = function (period) {
    	var args = '';
        	
        for ( var key in ratings_text ) {
			if ( PDRTJS_is_defined( this[key] ) && this[key] != ratings_text[key] ) 
				args += '&' + key + '=' + PDRTJS_url_encode( this[key] );
		}
        
        var id = this.id;
        if (this.override != null)
        	id = this.override;	
        this.make_call('/ratings/rating-results.php?id=' + id + '&item_id=' + this.item_id + '&period=' + period + '&item_count=3' + ( ( this.popup == 'off' ) ? '&off' : '' ) + args );
    }

    this.rebuild = function () {
        if (!this.kill_hover) {
            this.timeout_id = setTimeout(this.varname + '.build()', 800);
        }
    }

    this.cancel_rebuild = function () {
        if (this.timeout_id != null) {
            clearTimeout(this.timeout_id);
            this.timeout_id = null;
        }
    }

    this.rate = function (rating) {
        if (!this.kill_hover) {
            var voter_id = this.get_voter_id();

            if (this.type == 'stars') {
                $(this.varname + '_msg').innerHTML = this.text_thank_you;
            }
            else {
                $(this.varname + '_msg').innerHTML = this.text_thank_you;

                if (voter_id == 0) {
                    if (rating == 1) {
                        $(this.varname + '_msg_1').innerHTML = (this.nero_up + 1);
                    }
                    else {
                        $(this.varname + '_msg_2').innerHTML = (this.nero_dn + 1);
                    }
                }
            }

            this.kill_hover = true;

            var url = '';
            var params = '&cmd=rate';
            var scores = '';

            if (this.type == 'stars') {
                scores = '&votes=' + this.votes + '&avg=' + this.avg_rating;
            }
            else {
                scores = '&up=' + this.nero_up + '&down=' + this.nero_dn;
            }

            if (voter_id != 0) {
                params = '&cmd=change&vid=' + PDRTJS_url_encode(voter_id);
            }
            else {
                params = '&cmd=rate';
            }

            url = '/ratings/rate.php?title=' + PDRTJS_url_encode(this.title) + '&permalink=' + PDRTJS_url_encode(this.permalink) + '&type=' + this.type + '&id=' + this.id + '&r=' + rating + '&uid=' + this.unique_id + '&item_id=' + this.item_id + scores + params + '&token=' + this.token;

            this.make_call(url);

            setTimeout(this.varname + '.build()', 2000);
            setTimeout(this.varname + '.kill_hover = false', 6000);
        }
    }

    this.hover = function (rating) {
        if (!this.kill_hover) {
            if (this.type == 'stars') {
                this.cancel_rebuild();

                for (c = 1; c <= 5; c++) {
                    if (c <= rating) {
                        $(this.varname + '_stars_' + c).style.background = 'url(' + this.star_image + ') top right';
                    }
                    else {
                        $(this.varname + '_stars_' + c).style.background = 'url(' + this.star_image + ') bottom right';
                    }
                }

                $(this.varname + '_msg').innerHTML = eval('this.text_' + rating + '_star');
            }
            else {
                this.cancel_rebuild();

                var image_pos = ' top left';
                var msg = this.text_rate_up;
                if (rating == 2) {
                    image_pos = ' top right';
                    msg = this.text_rate_down;
                }
                $(this.varname + '_nero_' + rating).style.background = 'url(' + this.star_image + ') ' + image_pos;
                $(this.varname + '_msg_' + rating).style.fontWeight = 'bold';
                $(this.varname + '_msg').innerHTML = msg;
            }
        }
    }

    this.set_voter_id = function () {
        if (this.voter_id != null) {
            var today = new Date();
            today.setTime(today.getTime());
            var expires = 90 * 60 * 60 * 24;
            var expires_date = new Date(today.getTime() + (expires));
            var name = 'PDRTJS_' + this.id + '_' + this.type + '_' + escape(this.unique_id);
            document.cookie = name + "=" + escape(this.voter_id) + ";expires=" + expires_date.toGMTString() + ";path=/;";
        }
    }

    this.get_voter_id = function () {
        var name = 'PDRTJS_' + this.id + '_' + this.type + '_' + escape(this.unique_id);
        var the_cookie = '' + document.cookie;
        var ind = the_cookie.indexOf(name + "=");
        if (ind == -1 || name == '') {
            return 0;
        }
        else {
            var ind1 = the_cookie.indexOf(';', ind);
            if (ind1 == -1) {
                ind1 = the_cookie.length;
            }
            return unescape(the_cookie.substring(ind + name.length + 1, ind1));
        }
    }

    if (this.item_id == null) {
        this.item_id = '';
    }

    this.get_rating();

}

var PDRTJS_doc = document.getElementsByTagName('div');
var PDRTJS_id = '';

for (var i = 0; i < PDRTJS_doc.length; i++) {
    if (PDRTJS_doc[i].id.substring(0, 17) == 'pd_rating_holder_') {
        PDRTJS_id = PDRTJS_doc[i].id.replace(/pd_rating_holder_/, "");

        eval("if ( typeof PDRTJS_" + PDRTJS_id + " == 'undefined' ){PDRTJS_" + PDRTJS_id + " = new PDRTJS_RATING( PDRTJS_settings_" + PDRTJS_id + " );}");

    }
}
