/**
* DodosTextCounter - jQuery plugin for text limit for input or textarea. The counter shows how many chars are remaining.
*						It will also disable the user from entering more characters after s/he reaches the maximum
* Written by Ying Zhang aka Dodo
* http://pure-essence.net/2008/05/30/dodos-text-counterdodos-text-counter/
*/

jQuery.fn.dodosTextCounter = function(max, options) {
	// if the counter display doesn't exist, the script will attempt to create it
	options = $j.extend({
		counterDisplayElement: "span",					// tag for the counter display
		counterDisplayClass: "dodosTextCounterDisplay",	// class for the counter display
		addLineBreak: true								// whether to add <br /> after the input element before the counter display
	}, options);

	$j(this).each(function(i) {
		updateCounter(this, max, options, i);
		$j(this).keyup(function() {
			updateCounter(this, max, options, i);
			return this;
		});
	});
	return this;
};

function updateCounter(input, max, options, index) {
	var currentLength = 0;
	var val = $j(input).val();
	if(val) {
		currentLength = val.length;
	}
	if(currentLength > max) {
		$j(input).val(val.substring(0, max));
	} else {
		var charLeft = max - currentLength;
		var counterDisplay = options.counterDisplayElement + "." + options.counterDisplayClass + ":eq("+index+")";
		var createNew = $j(counterDisplay).length == 0;
		if(createNew) {
			var element = document.createElement(options.counterDisplayElement);
			if(options.counterDisplayElement == 'input') {
				$j(element).val(charLeft.toString());
			} else {
				$j(element).html(charLeft.toString());
			}
			$j(element).addClass(options.counterDisplayClass).insertAfter($j(input));
			if(options.addLineBreak) {
				$j(input).after("<br />");
			}
		} else {
			if(options.counterDisplayElement == 'input') {
				$j(counterDisplay).val(charLeft.toString());
			} else {
				$j(counterDisplay).html(charLeft.toString());
			}
		}
		
	}
}