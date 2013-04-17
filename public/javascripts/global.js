jQuery(document).ready(function()
{
	jQuery(".tabLink").each(function(){
      jQuery(this).click(function(){
        tabeId = jQuery(this).attr('id');
        jQuery(".tabLink").removeClass("activeLink");
        jQuery(this).addClass("activeLink");
        jQuery(".updateStreamBox").addClass("hide");
        jQuery("#"+tabeId+"-1").removeClass("hide")
        return false;
      });
    });

	jQuery(".brandTab").each(function(){
      jQuery(this).click(function(){
        tabeId = jQuery(this).attr('id');
        jQuery(".brandTab").removeClass("activeTab");
        jQuery(this).addClass("activeTab");
        jQuery(".tabShow").addClass("hide");
        jQuery("#"+tabeId+"-1").removeClass("hide")
        return false;
      });
    });
	jQuery(".styleCustom").each(function(){
      jQuery(this).click(function(){
        tabeId = jQuery(this).attr('id');
        jQuery(".styleCustom").removeClass("styleActiveTab");
        jQuery(this).addClass("styleActiveTab");
        jQuery(".styleEditorContent").addClass("hide");
        jQuery("#"+tabeId+"-1").removeClass("hide")
        return false;
      });
    });
	jQuery(".friendTab").each(function(){
      jQuery(this).click(function(){
        tabeId = jQuery(this).attr('id');
        jQuery(".friendTab").removeClass("activeTab");
        jQuery(this).addClass("activeTab");
        jQuery(".fullPage").addClass("hide");
        jQuery("#"+tabeId+"-1").removeClass("hide")
        return false;
      });
    });
	jQuery(".sortTab").each(function(){
      jQuery(this).click(function(){
        tabeId = jQuery(this).attr('id');
        jQuery(".sortTab").removeClass("sortTabActive");
        jQuery(this).addClass("sortTabActive");
        jQuery(".fr-tabContent").addClass("hidden");
        jQuery("#"+tabeId+"-1").removeClass("hidden")
        return false;
      });
    });

	jQuery("#accountSetup .contentHeading .contentHeadingSpan").click(function()
	{
	    jQuery(this).parent().css({backgroundColor: "tansparent"}).next("div.accSetupContent").slideToggle(500).siblings("div.accSetupContent").slideUp("slow");
	    jQuery(this).parent().siblings().css({backgroundColor:"tansparent"});
		if (jQuery("#accSetupContent3").css('display')=='block'){
			console.log(jQuery("#accSetupContent3").css('display'))
			jQuery("#contentHeadingSection3").addClass('last')
		}else{
			jQuery("#contentHeadingSection3").removeClass('last')
		}

	});
	jQuery("#accountPersonalSetting .contentHeading").click(function()
	{
	    jQuery(this).css({backgroundColor: "tansparent"}).next("div.accSetupContent").slideToggle(500).siblings("div.accSetupContent").slideUp("slow");
	    jQuery(this).siblings().css({backgroundColor:"tansparent"});
		if (jQuery("#accSettingPersonalContent6").css('display')=='block'){
			console.log(jQuery("#accSettingPersonalContent6").css('display'))
			jQuery("#contentHeadPersonal6").addClass('last')
		}else{
			jQuery("#contentHeadPersonal6").removeClass('last')
		}

	});
	jQuery("#accountBrandSetting .contentHeading").click(function()
	{
	    jQuery(this).css({backgroundColor: "tansparent"}).next("div.accSetupContent").slideToggle(500).siblings("div.accSetupContent").slideUp("slow");
	    jQuery(this).siblings().css({backgroundColor:"tansparent"});
		if (jQuery("#accSettingBrandContent7").css('display')=='block'){
			console.log(jQuery("#accSettingBrandContent7").css('display'))
			jQuery("#contentHeadBrand7").addClass('last')
		}else{
			jQuery("#contentHeadBrand7").removeClass('last')
		}

	});
	jQuery("#customStyle .yourSkinHead").click(function()
	{
	    jQuery(this).css({backgroundColor: "tansparent"}).next("div.editingSkinsContent").slideToggle(500).siblings("div.editingSkinsContent").slideUp("slow");
	    jQuery(this).siblings().css({backgroundColor:"tansparent"});
		if (jQuery("#yourSkin02").css('display')=='block'){
			console.log(jQuery("#yourSkin02").css('display'))
			jQuery("#yourSkin02").addClass('last')
		}else{
			jQuery("#yourSkin02").removeClass('last')
		}

	});

	jQuery("a[rel=example_group]").fancybox({
		'transitionIn'		: 'none',
		'transitionOut'		: 'none',
		'titlePosition' 	: 'over',
		'titleFormat'		: function(title, currentArray, currentIndex, currentOpts) {
			return '<span id="fancybox-title-over">Image ' + (currentIndex + 1) + ' / ' + currentArray.length + (title.length ? ' &nbsp; ' + title : '') + '</span>';
		}
	});
});


if (window['console'] === undefined) {
    window.console = {
        log: function (){}
    };
};


jQuery(document).ready(function() {
  BrowserDetect.init();
});

(function() {
    BrowserDetect = {
        init: function() {
            this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
            this.version = this.searchVersion(navigator.userAgent) || this.searchVersion(navigator.appVersion) || "an unknown version";
            this.OS = this.searchString(this.dataOS) || "an unknown OS";
			if (document.body.className != ''){
				document.body.className = document.body.className + " " + this.browser.toLowerCase() + " " + this.OS.toLowerCase();
			}else{
				document.body.className = this.browser.toLowerCase() + " " + this.OS.toLowerCase();
			}

        },
        searchString: function(b) {
            for (var a = 0; a < b.length; a++) {
                var c = b[a].string,
                d = b[a].prop;
                this.versionSearchString =
                b[a].versionSearch || b[a].identity;
                if (c) {
                    if (c.indexOf(b[a].subString) != -1) return b[a].identity;
                } else if (d) return b[a].identity;
            }
        },
        searchVersion: function(b) {
            var a = b.indexOf(this.versionSearchString);
            if (a != -1) return parseFloat(b.substring(a + this.versionSearchString.length + 1));
        },
        dataBrowser: [{
            string: navigator.userAgent,
            subString: "Chrome",
            identity: "Chrome"
        },
        {
            string: navigator.userAgent,
            subString: "OmniWeb",
            versionSearch: "OmniWeb/",
            identity: "OmniWeb"
        },
        {
            string: navigator.vendor,
            subString: "Apple",
            identity: "Safari",
            versionSearch: "Version"
        },
        {
            prop: window.opera,
            identity: "Opera"
        },
        {
            string: navigator.vendor,
            subString: "iCab",
            identity: "iCab"
        },
        {
            string: navigator.vendor,
            subString: "KDE",
            identity: "Konqueror"
        },
        {
            string: navigator.userAgent,
            subString: "Firefox",
            identity: "Firefox"
        },
        {
            string: navigator.vendor,
            subString: "Camino",
            identity: "Camino"
        },
        {
            string: navigator.userAgent,
            subString: "Netscape",
            identity: "Netscape"
        },
        {
            string: navigator.userAgent,
            subString: "MSIE",
            identity: "IE",
            versionSearch: "MSIE"
        },
        {
            string: navigator.userAgent,
            subString: "Gecko",
            identity: "Mozilla",
            versionSearch: "rv"
        },
        {
            string: navigator.userAgent,
            subString: "Mozilla",
            identity: "Netscape",
            versionSearch: "Mozilla"
        }],
        dataOS: [{
            string: navigator.platform,
            subString: "Win",
            identity: "Windows"
        },
        {
            string: navigator.platform,
            subString: "Mac",
            identity: "Mac"
        },
        {
            string: navigator.userAgent,
            subString: "iPhone",
            identity: "iPhone/iPod"
        },
        {
            string: navigator.platform,
            subString: "Linux",
            identity: "Linux"
        }]
    };

})();