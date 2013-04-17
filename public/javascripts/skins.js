
function changeStyle(styleAttribute, elements, style){
  if((styleAttribute == 'background-color' || styleAttribute == 'background-image') && elements == '#ednt-Header, #previewHeader'){
    if(style == ''){
      $j(elements).css('background-image',  'none !important');
    }else{
      $j(elements).css('background', style + ' !important');
    }
  }else{
    $j(elements).css(styleAttribute, style);
  }
}



function setLeftContentEvent(){
  $j('#preview_left_content').bind('click', function () {
    $j('.style_attribute').hide();
    $('style_attribute_left_content').toggle();
  });
}
function removeLeftContentEvent(){
  $j('#preview_left_content').bind('click', function () {
    $j('.style_attribute').hide();
    $('style_attribute_stream').toggle();
  });
}

