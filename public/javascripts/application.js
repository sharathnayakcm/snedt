if (menuItemName){}else{
  var menuItemName = "";
}
function notice(message, type, duration) {
  if (duration == null) {
    duration = 10;
  }

  if (type == null) {
    type = 'message';
  }

  $('notice_text').innerHTML = message;
  $('notice_text').className = type;
  Effect.SlideDown('generalNotif', {
    transition: Effect.Transitions.spring
  });
  setTimeout("Effect.SlideUp('generalNotif')", duration * 1000);
}


function show_menu()
{
  $j('#menu').slideDown().toggle();
  var w = $('add_tab').scrollWidth;
  var wl = $('home').scrollWidth;
  var tw = parseInt(w) + parseInt(wl) + 180;
  $('menu').style.left = tw.toString() + 'px';
}

/* Sign Up Page Starts */

function hide_all(){
  $j("span#full_name_warning").hide();

  $j("span#full_name_success").hide();


  $j("#user_name_warning").hide();
  $j("#user_name_error").hide();
  $j("span#user_name_success").hide();


  $j("span#password_warning").hide();
  $j("span#password_success").hide();


  $j("span#confirm_password_warning").hide();
  $j("span#confirm_password_success").hide();


  $j("span#email_warning").hide();
  $j("span#email_success").hide();
}
function empty_all(){
  $j("span#full_name_warning").empty();
  $j("span#full_name_success").empty();


  $j("span#user_name_warning").empty();
  $j("#user_name_error").empty();
  $j("span#user_name_success").empty();


  $j("span#password_warning").empty();
  $j("span#password_success").empty();


  $j("span#confirm_password_warning").empty();
  $j("span#confirm_password_success").empty();

  $j("span#email_warning").empty();
  $j("span#email_success").empty();
}
function login_tab_selection(){
  $j(".question_tab_2").click(function()
  {
    $j('#what_is_it').addClass("display_none");
    $j('.question_tab_1').removeClass("selected_tab");
    $j('.question_tab_1').addClass("non_selected_tab_1");
    $j('#is_it_for_me').addClass("display_none");
    $j('.question_tab_2').removeClass("non_selected_tab_2");
    $j('.question_tab_2').addClass("selected_tab_2");
    $j('.question_tab_3').removeClass("selected_tab_3");
    $j('.question_tab_3').addClass("non_selected_tab_3");
    $j('#how_it_works').removeClass("display_none");
  });

  $j(".question_tab_1").click(function()
  {
    $j('#what_is_it').removeClass("display_none");
    $j('.question_tab_1').removeClass("non_selected_tab_1");
    $j('.question_tab_1').addClass("selected_tab");
    $j('#is_it_for_me').addClass("display_none");
    $j('.question_tab_2').removeClass("selected_tab_2");
    $j('.question_tab_2').addClass("non_selected_tab_2");
    $j('#how_it_works').addClass("display_none");
    $j('.question_tab_3').removeClass("selected_tab_3");
    $j('.question_tab_3').addClass("non_selected_tab_3");
  });

  $j(".question_tab_3").click(function()
  {
    $j('#what_is_it').addClass("display_none");
    $j('.question_tab_1').removeClass("selected_tab");
    $j('.question_tab_1').addClass("non_selected_tab_1");
    $j('#is_it_for_me').removeClass("display_none");
    $j('.question_tab_2').removeClass("selected_tab_2");
    $j('.question_tab_2').addClass("non_selected_tab_2");
    $j('#how_it_works').addClass("display_none");
    $j('.question_tab_3').removeClass("non_selected_tab_3");
    $j('.question_tab_3').addClass("selected_tab_3");
  });
}
function sign_up_validations(){
  $j("#full_name").blur(function()
  {
    var value = new RegExp(/^([a-z][a-z ]*)$/i);
    full_name_text = $j("#full_name").val();
    full_name_length = $j("#full_name").val().length;
    if ($j("#full_name").val() != 'Your first and last name (John Smith)') {
      if (value.test(full_name_text) == true  && full_name_length > 2 && full_name_text != "Your first and last name (John Smith)")
      {
        $j("span#full_name_warning").hide();
        $j("#full_name_success").html('<img src="/images_1/validation_ok_button.png"/>');
        $j("span#full_name_success").show();
        $j(".error_field").hide();
      }
      else
      {
        $j("span#full_name_success").hide();
        $j("span#full_name_warning").show();
        $j("#full_name_warning").text("Name is invalid")
        $j("#full_name_warning").corner();
        $j(".error_field").hide();
      }
    }
    else{
      $j("span#full_name_warning").hide();
      $j(".error_field").hide();
      $j("span#full_name_success").hide();
    }
  });
  
  //  $j("#user_name").blur(function()
  //  {
  //    $j("#user_name_check").html('<p ><img src="/images/spinner.gif" width="32"/><span class="user_name_check_text"> Checking...</span></p>').fadeIn("slow");
  //    $j("#user_name_success").hide();
  //    $j("#user_name_warning").hide();
  //    $j("#observed").html("");
  //    user_name_text = $j("#user_name").val();
  //    $j.post("/user_validation",{
  //      user_name:$j(this).val()
  //    },function(data) {
  //      if(data=='true' && user_name_text != "Make it Unique") { //if username not avaiable
  //        $j("#user_name_warning").fadeTo(200,0.1,function() { //start fading the messagebox
  //          //add message and change the class of the box and start fading
  //          $j("#user_name_success").hide();
  //          $j(this).html('User Name already exists').addClass('messageboxerror').fadeTo(900,1);
  //          $j("#user_name_success").hide();
  //          $j("#observed").html("");
  //          $j(".error_field").hide();
  //        });
  //      }
  //      if(data=='blank' || user_name_text == "Make it Unique") { //if username is blank
  //        $j("#observed").html("");
  //        $j("#user_name_warning").fadeTo(200,0.1,function() { //start fading the messagebox
  //          //add message and change the class of the box and start fading
  //          $j("#user_name_check").hide();
  //          $j("#observed").html("");
  //          $j(this).html('User Name is invalid').addClass('messageboxerror').fadeTo(900,1);
  //          $j("#user_name_success").hide();
  //          msg = "Your profile URL:http://UserName.edintity.com"
  //          $j("#observed").html(msg);
  //          $j(".error_field").hide();
  //        });
  //      } else
  //        if (data=='false' && user_name_text != "Make it Unique"){
  //        $j("#user_name_success").hide();
  //        $j("#observed").html("");
  //        $j("#user_name_success").fadeTo(200,1.0,function() {  //start fading the messagebox
  //          //add message and change the class of the box and start fading
  //          $j(this).html('<img src="/images_1/validation_ok_button.png"/>');
  //          user = $j("input#user_name").val();
  //          msg1 = "Your profile URL:http://"
  //          msg2 = ".edintity.com"
  //          msg = msg1 + user +msg2
  //          $j("#observed").html(msg);
  //          $j("#user_name_warning").hide();
  //          $j("#user_name_check").hide();
  //          $j(".error_field").hide();
  //        });
  //      }
  //    });
  //  });


  //  $j("#email").blur(function()
  //  {
  //
  //    var value = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
  //    email_text = $j("#email").val();
  //    if($j("#email").val() != 'Activation link will be sent to this email'){
  //      if (value.test(email_text) == true)
  //      {
  //        $j("span#email_warning").hide();
  //        $j("#email_success").html('<img src="/images_1/validation_ok_button.png"/>');
  //        $j("span#email_success").show();
  //        $j(".error_field").hide();
  //      }
  //
  //      else
  //      {
  //        $j("span#email_success").hide();
  //        $j("span#email_warning").empty();
  //        $j("span#email_warning").show();
  //        $j("#email_warning").corner();
  //        $j("#email_warning").append("Email is invalid");
  //        $j(".error_field").hide();
  //      }
  //    }
  //    else
  //    {
  //      $j("span#email_warning").hide();
  //      $j(".error_field").hide();
  //      $j("span#email_success").hide();
  //    }
  //  });


  $j("#password").blur(function()
  {
    var user_name_length;
    var lower_case = new RegExp(/^[a-z]+$/i)
    var up_case = new RegExp(/^[A-Z]+$/i)
    var numeric = new RegExp(/^[0-9]+$/i)
    pwd_text = $j("#password").val();
    password_length = $j("#password").val().length;
    if(password_length > 0){
      if (password_length < 7  || pwd_text == "At least 7 characters and make it strong")
      {
        $j("span#password_success").hide();
        $j("span#password_warning").show();
        $j("#password_warning").text("Password is short/invalid. (Min 7 characters)");
        $j("#password_warning").corner();
        $j(".error_field").hide();
      }
      else if (((lower_case.test(pwd_text) == true) || (up_case.test(pwd_text) == true) || (numeric.test(pwd_text) == true)) && (password_length >= 7) && (pwd_text != "At least 7 characters and make it strong"))
      {
        $j("span#password_success").hide();
        $j("span#password_warning").show();
        $j("#password_warning").text("Password is weak");
        $j("#password_warning").corner();
        $("password_warning").setAttribute("style",  $("password_warning").getAttribute('style') + "; background: none; background-color: orange;");
        $j(".error_field").hide();
      }
      else
      {
        $j("span#password_success").show();
        $j("span#password_warning").hide();
        $j("#password_success").html('<img src="/images_1/validation_ok_button.png"/>');
        $j(".error_field").hide();
      }
    }
    else
    {
      $j("span#password_warning").hide();
      $j(".error_field").hide();
      $j("span#password_success").hide();
    }
  });

  $j("#password_confirm").blur(function()
  {
    var user_name_length;
    password_length = $j("#password_confirm").val().length;
    pwd_text = $j("#password").val();
    cnfm_pwd_text = $j("#password_confirm").val();
    $j("#confirm_password_warning").hide();
    if($j("#password").val().length > 0 && password_length > 0){
      if (pwd_text == cnfm_pwd_text &&  (cnfm_pwd_text != "At least 7 characters and make it strong") && (cnfm_pwd_text != ""))
      {
        $j("span#confirm_password_warning").hide();
        $j("#confirm_password_success").html('<img src="/images_1/validation_ok_button.png"/>');
        $j("span#confirm_password_success").show();
        $j(".error_field").hide();
      }
      else
      {
        $j("#confirm_password_success").hide();
        $j("span#confirm_password_warning").show();
        $j("#confirm_password_warning").text("Password does not match confirmation")
        $j("#confirm_password_warning").corner();
        $j(".error_field").hide();

      }
    }
    else
    {
      $j("#confirm_password_success").hide();
      $j("span#confirm_password_warning").hide();
      $j(".error_field").hide();
    }
  });

  validate_company_url();
}

function validate_company_url(){
  $j("#company_url").blur(function()
  {
    var url = $j("#company_url").val();
    var urlregex = new RegExp("^(http:\/\/|https:\/\/){1}([0-9A-Za-z]+\.)");
    if (urlregex.test(url) == true){
      $j("span#company_url_warning").hide();
      $j("#company_url_check").html('<img src="/images_1/validation_ok_button.png"/>');
      $j("span#company_url_check").show();
    }else{
      $j("span#company_url_check").hide();
      $j("span#company_url_warning").show();
      $j("span#company_url_warning").text("Please enter valid company URL");
      $j("span#company_url_warning").corner();
    }
  });
}

/* Sign Up Page Ends */
function add_close_button()
{
  var closeImageHeight = 16;	// Pixel height of close buttons
  var closeButton = document.createElement('IMG');
  closeButton.src = '../images/edit_tab.png';
  closeButton.height = closeImageHeight + 'px';
  closeButton.width = closeImageHeight + 'px';
  closeButton.setAttribute('height',closeImageHeight);
  closeButton.setAttribute('width',closeImageHeight);
  closeButton.style.top = '6px';
  closeButton.style.right = '0px';
  $j("#home").innerHTML = 	$j("#home").innerHTML + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
  closeButton.onclick = function(){
    deleteTab(this.parentNode.innerHTML)
  };
  var home = $j('#home');
  home.append(closeButton);
}


function deleteTab(s)
{
  alert(s);
}


function char_count()
{
  $j("#status_update_message").dodosTextCounter(100, {
    counterDisplayElement: "input",
    counterDisplayClass: "textareaCounter"
  });
};

function new_post_char_count_up() {
  var charLength = $j('#status_optional_message').val().length
  $j("#textareaCounter").html("<strong>"+charLength+"</strong> characters");
  $j("#twitterService #new_twitter_char_count").html("("+(180 - charLength)+" characters left )");

}

function char_count_up(id)
{
  //  alert(id);
  var charLength = $j('#status_optional_message_'+ id).val().length
  $j("#textareaCounter_"+ id).html("<strong>"+charLength+"</strong> characters");
  $j("#twitterService #twitter_char_count_"+ id).html("("+(180 - charLength)+" characters left )");
};

function comment_dialog(id)
{
  $j('#dialog_'+ id).dialog({
    closeOnEscape: true
  });
  $j('#dialog_'+ id).corner();
}

function tag_dialog(id)
{
  $j('#tab_dialog_'+ id).dialog({
    closeOnEscape: true
  });
  $j('#tab_dialog_'+ id).corner();
}


function toggle_arrow(elem){
  var text = elem.innerHTML;
  if(text.indexOf('arrow.png') > -1){
    text = text.replace('arrow.png', 'arrow-down.png');
    if($j('.stream')){
      $j('.stream').css('height','');
    }
  }else if(text.indexOf('arrow-down.png')){
    text = text.replace('arrow-down.png', 'arrow.png');
    if($j('.stream')){
      $j('.stream').css('height','');
    }
  }

  if(text.indexOf('arrow_up.png') > -1){
    text = text.replace('arrow_up.png', 'arrow_down.png');
    if($j('.stream')){
      $j('.stream').css('height','');
    }
  }else if(text.indexOf('arrow_down.png')){
    text = text.replace('arrow_down.png', 'arrow_up.png');
    if($j('.stream')){
      $j('.stream').css('height','');
    }
  }
  elem.innerHTML = text;

}

function toggle_arrow_normal(elem){
  var text = elem.innerHTML;
  if(text.indexOf('arrow_up.png') > -1){
    text = text.replace('arrow_up.png', 'arrow_down.png');
    if($j('.stream')){
      $j('.stream').css('height','');
    }
  }else if(text.indexOf('arrow_down.png')){
    text = text.replace('arrow_down.png', 'arrow_up.png');
    if($j('.stream')){
      $j('.stream').css('height','');
    }
  }
  elem.innerHTML = text;

}


function validate_fullname()
{
  var value = new RegExp(/^([a-z][a-z ]*)$/i);
  full_name_text = $j("#full_name").val();
  full_name_length = $j("#full_name").val().length;
  if (value.test(full_name_text) == true  && full_name_length > 4)
  {
    $j("span#full_name_warning").hide();
    $j('#full_name_verification_pic_success').hide();
    $j("#full_name_success").text("Name is valid");
    $j('#full_name_verification_pic_failure').html('<img id="tick" src="/images/tick.png" width="20" />')
    $j('#full_name_verification_pic_failure').show();
    $j("span#full_name_success").show();
    $j(".error_field").hide();
  }
  else
  {
    $j("span#full_name_success").hide();
    $j('#full_name_verification_pic_failure').hide();
    $j("span#full_name_warning").show();
    $j('#full_name_verification_pic_success').show();
    $j('#full_name_verification_pic_success').html('<img id="tick" src="/images/cross.png" width="20" />')
    $j("#full_name_warning").text("Name is invalid")
    $j(".error_field").hide();
  }

}

function validate_username(){
  var value = new RegExp(/^([a-z0-9]*)$/i);
  user_name_text = $j("#user_name").val();
  user_name_length = $j("#user_name").val().length;
  $j("#user_name_warning").empty();
  if (value.test(user_name_text) == true  && user_name_length > 4)
  {
    $j("span#user_name_warning").hide();
    $j('#user_name_verification_pic_success').hide();
    $j("#user_name_success").text("Username is valid");
    $j('#user_name_verification_pic_failure').html('<img id="tick" src="/images/tick.png" width="20" />')
    $j('#user_name_verification_pic_failure').show();
    $j("span#user_name_success").show();
    $j(".error_field").hide();
  }
  else
  {
    $j("span#user_name_success").hide();
    $j('#user_name_verification_pic_failure').hide();
    $j("span#user_name_warning").show();
    $j('#user_name_verification_pic_success').show();
    $j('#user_name_verification_pic_success').html('<img id="tick" src="/images/cross.png" width="20" />')
    $j("#user_name_warning").text("Username is invalid")
    $j(".error_field").hide();
  }
}

function validate_email(){
  var value = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
  email_text = $j("#email").val();
  if (value.test(email_text) == true)
  {
    $j("span#email_warning").hide();
    $j('#email_verification_pic_success').hide();
    $j("#email_success").text("Email is valid");
    $j('#email_verification_pic_failure').html('<img id="tick" src="/images/tick.png" width="20" />')
    $j('#email_verification_pic_failure').show();
    $j("span#email_success").show();
    $j(".error_field").hide();
  }

  else
  {
    $j("span#email_success").hide();
    $j("span#email_warning").empty();
    $j('#email_verification_pic_failure').hide();
    $j("span#email_warning").show();
    $j('#email_verification_pic_success').show();
    $j('#email_verification_pic_success').html('<img id="tick" src="/images/cross.png" width="20" />')
    $j("#email_warning").append("Email is invalid");
    $j(".error_field").hide();
  }
}

function validate_password(){
  var user_name_length;
  password_length = $j("#password").val().length;
  $j("#password_warning").empty();
  if (password_length < 8)
  {
    $j("span#password_success").hide();
    $j('#password_verification_pic_failure').hide();
    $j("span#password_warning").show();
    $j('#password_verification_pic_success').show();
    $j('#password_verification_pic_success').html('<img id="tick" src="/images/cross.png" width="20" />')
    $j("#password_warning").text("Password is weak")
    $j(".error_field").hide();
  }
  else
  {
    $j("span#password_warning").hide();
    $j('#password_verification_pic_success').hide();
    $j("#password_success").text("Password is strong");
    $j('#password_verification_pic_failure').html('<img id="tick" src="/images/tick.png" width="20" />')
    $j('#password_verification_pic_failure').show();
    $j("span#password_success").show();
    $j(".error_field").hide();
  }
}
function validate_confirm_password(){
  var user_name_length;
  password_length = $j("#password_confirm").val().length;
  $j("#confirm_password_warning").hide();
  if (password_length < 8)
  {
    $j("#confirm_password_success").hide();
    $j('#confirm_password_verification_pic_failure').hide();
    $j("span#confirm_password_warning").show();
    $j('#confirm_password_verification_pic_success').show();
    $j('#confirm_password_verification_pic_success').html('<img id="tick" src="/images/cross.png" width="20" />')
    $j("#confirm_password_warning").text("Password is weak")
    $j(".error_field").hide();
  }
  else
  {
    $j("span#confirm_password_warning").hide();
    $j('#confirm_password_verification_pic_success').hide();
    $j("#confirm_password_success").text("Password is strong");
    $j('#confirm_password_verification_pic_failure').html('<img id="tick" src="/images/tick.png" width="20" />')
    $j('#confirm_password_verification_pic_failure').show();
    $j("span#confirm_password_success").show();
    $j(".error_field").hide();
  }
}

function round_corner(){
  $j('#confirm_password_warning').corner();
  $j('#confirm_password_success').corner();
  $j("span#full_name_warning").corner();
  $j("span#full_name_success").corner();
  $j("#user_name_warning").corner();
  $j("#user_name_error").corner();
  $j("span#user_name_success").corner();
  $j("span#password_warning").corner();
  $j("span#password_success").corner();
  $j("span#email_warning").corner();
  $j("span#email_success").corner();
  $j("#warning_on_create_account").corner();
  $j(".signup_btn").corner();
  $j(".error_field").corner();
  $j(".warning_on_create_account").corner();
}
// Floating layer script

var y1 = 0;   // change the # on the left to adjuct the Y co-ordinate
(document.getElementById) ? dom = true : dom = false;

function hideIt(id) {
  if (dom && document.getElementById(id)) {
    document.getElementById(id).style.visibility='hidden';
  }
}

function showIt(id) {
  if (dom && document.getElementById(id)) {
    document.getElementById(id).style.visibility='visible';
  }
}

function placeIt(id) {
  if(!document.getElementById(id))
    return;
  if (dom && !document.all) {
    document.getElementById(id).style.top =  window.pageYOffset + (window.innerHeight - document.getElementById(id).clientHeight)/2 + "px"
  }
  if (document.all) {
    document.all[id].style.top = document.documentElement.scrollTop + (document.documentElement.clientHeight - (document.documentElement.clientHeight-y1)) + "px";
  }
  window.setTimeout("placeIt('" + id + "')", 10);
}

function setFloatLayer() {
  placeIt('RB_window');
  showIt('RB_window');
// var width = $('r5_wrapper_redbox').style.minWidth.replace('px', '');
// $('RB_window').style.width = (parseInt(width) + 10).toString() + 'px';
//    $('RB_window').style.left = '0px';
}

function replaceHourGlass(action_id, html_id) {
  var anchor_elem = $(html_id);
  var spinner_elem = $(action_id);
  if (spinner_elem) {
    var h = spinner_elem.scrollWidth;
    if (anchor_elem) {
      Element.hide(html_id);
      var imgId = action_id.toString() + 'img'
      if ($(imgId)) {
        Element.show(imgId)
        $(imgId).style.display = 'inline-block';
      } else {
        var imgSpan = document.createElement("SPAN");
        h = (h - 16) * 50 / 100;
        if (h < 0) {
          h = h * -1;
        }
        imgSpan.style.paddingRight = h.toString() + 'px';
        imgSpan.style.paddingLeft = h.toString() + 'px';
        imgSpan.style.display = 'inline-block';
        imgSpan.className = 'align_center';
        imgSpan.id = imgId;
        spinner_elem.appendChild(imgSpan);
        var img = document.createElement("IMG");
        img.src = '/images/spinner-blue.gif';
        imgSpan.appendChild(img);
      }
    }
  }
}


function upload_file(form_id) {
  var form = $(form_id);
  var original_form_action = form.action;
  form.target = "upload_frame";
  form.action = '/skins/upload_image';
  form.submit();
  form.action = original_form_action;
  form.target = "";
}

function validate_company_form_fields(){
  var url = $j("#company_url").val();
  var urlregex = new RegExp("^(http:\/\/|https:\/\/){1}([0-9A-Za-z]+\.)");

  if($j('#company_name').val()==''){
    notice('Name should not be blank');
    return false;
  }
  else if($j('#company_url').val()==''){
    notice('URL can not be blank');
    return false;
  }
  else if (urlregex.test(url) == false){
    notice('URL is not valid');
    return false;
  }
  return true
}


function validate_brand_form_fields(){
  var url = $j("#brand_url").val();
  var urlregex = new RegExp("^(http:\/\/|https:\/\/){1}([0-9A-Za-z]+\.)");

  if($j('#brand_name').val()==''){
    notice('Name should not be blank');
    return false;
  }
  else if($j('#brand_url').val()==''){
    notice('URL can not be blank');
    return false;
  }
  else if (urlregex.test(url) == false){
    notice('URL is not valid');
    return false;
  }
  return true
}

function toggle_dashboard_panel(panel_type){
  var panel_types = ["user_report", "usage_report", "service_report", "conversion_report"]
  for(i=0; i<=3; i++){
    if(panel_types[i] == panel_type){
      $(panel_type).slideDown();
    }else{
      $(panel_types[i]).hide();
    }
  }
}

function dashBoardMenuHiglightion(type){
  var dt_type = type + '_dt';
  var types = ['company_dt', 'brand_dt', 'stream_dt', 'manage_dt', 'site_dt', 'review_dt'];
 
  for(var i=0; i<types.length; i++){
    if(types[i] == dt_type){
      //      alert(menuItemName);
      $j('#'+dt_type).addClass('active');
    //      var j = $j('#'+dt_type+' a')[0].innerHTML;
    //      var aa = j.split("<")[0].trim();
    //      var jj = j.replace(aa, menuItemName);
    //      $j('#'+dt_type+' a')[0].innerHTML = jj;
    }else{
      $j('#'+types[i]).removeClass('active');
    //      var MenuHTML = $j('#'+dt_type+' a')[0].innerHTML;
    //      var MenuName = MenuHTML.split("<")[0].trim();
    //      var SelectedMenuHTML = MenuHTML.replace(MenuName, type);
    //      $j('#'+dt_type+' a')[0].innerHTML = SelectedMenuHTML;
    }
  }
}

function scrollPage(){
  jQuery(function() {
    var $elem = jQuery('#baseContainer');

    jQuery('#nav_up').fadeIn('slow');
    jQuery('#nav_down').fadeIn('slow');

    jQuery(window).bind('scrollstart', function(){
      jQuery('#nav_up,#nav_down').stop().animate({
        'opacity':'1'
      });
    });
    jQuery(window).bind('scrollstop', function(){
      jQuery('#nav_up,#nav_down').stop().animate({
        'opacity':'0.1'
      });
    });

    jQuery('#nav_down').click(
      function (e) {
        jQuery('html, body').animate({
          scrollTop: $elem.height()
        }, 800);
      }
      );
    jQuery('#nav_up').click(
      function (e) {
        jQuery('html, body').animate({
          scrollTop: '0px'
        }, 800);
      }
      );
  });
}


jQuery(document).ready(function(){
  jQuery('.stream_thumb').embedly({
    maxWidth: 450,
    key: '2addb48161b54a00b4e73bb9071775e6'
  });
  
  jQuery('.homeHeader .streamHeader ul#topNavigation li a').removeClass('topNavActive');
  if(topNavLinkId){
    jQuery('#'+topNavLinkId).addClass('topNavActive');
  }else{
    jQuery('#myStreamIco').addClass('topNavActive');
  }
//    jQuery('.homeHeader .streamHeader ul li a').live('click', function(){
//      topNavLinkId = jQuery(this).attr('id')
//    })
});


function check_tags(){
  var tags = []
  if(jQuery('.tagit-choice').length > 0) {
    jQuery('.tagit-choice').each(function(){
      tags.push(jQuery(this).text().replace("x",""));
    })
    jQuery('#tags').attr("value",tags)
  }
  return true
  
  
}