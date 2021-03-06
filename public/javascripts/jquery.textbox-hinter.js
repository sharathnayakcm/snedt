/* 
 * jQuery - Textbox Hinter plugin v1.0
 * http://www.aakashweb.com/
 * Copyright 2010, Aakash Chakravarthy
 * Released under the MIT License.
 */

(function($j){
	$j.fn.tbHinter = function(options) {
	var defaults = {
		text: 'Enter a text ...',
   		class: ''
	};
	
	var options = $j.extend(defaults, options);

	return this.each(function(){
	
		$j(this).focus(function(){
			if($j(this).val() == options.text){
				$j(this).val('');
				$j(this).removeClass(options.class);
			}
		});
		
		$j(this).blur(function(){
			if($j(this).val() == ''){
				$j(this).val(options.text);
				$j(this).addClass(options.class);
			}
		});
		
		$j(this).blur();
		
	});
};
})(jQuery);