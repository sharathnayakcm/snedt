# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  require "json"
  require 'open-uri'
  require 'tzinfo'

  def stylesheet_sources
    if session[:locale] == "arabic"
      [
        'arabic/styles',
        'rounded_box',
        'redbox',
        'jslider_arabic',
        'fileuploader',
        'highslide',
        'jquery-ui-1.8.5.custom',
        'jquery.multiSelect',
        'jquery.fancybox-1.3.4.css',
        'common',
        'progressBar',
        'styleAddons',
        'tagit-simple-blue',
        'edintity_firefox_rtl',
        'edintity_ie9_rtl'
      ]
    else
      [
        'edintity',
        'rounded_box',
        'redbox',
        'jslider',
        'fileuploader',
        'highslide',
        'jquery-ui-1.8.5.custom',
        'jquery.multiSelect',
        'jquery.fancybox-1.3.4.css',
        'common',
        'progressBar',
        'styleAddons',
        'edintity_firefox',
        'tagit-simple-blue',
        'edintity_ie9',
        'redactor'
      ]
    end
  end

  def admin_stylesheet_sources
    if session[:locale] == "arabic"
      [
        'style_arabic',
        'style2_arabic',
        'application_arabic',
        'constants',
        'grid_arabic',
        'rounded_box',
        'tables',
        'menu_arabic',
        'qm_styles_arabic',
        'redbox',
        'jquery.rating',
        'jquery.multiSelect',
        'jquery-ui-1.8.5.custom',
        'jquery.ui.autocomplete.custom',
        'tagit-simple-blue',
        'jslider_arabic',
        'superfish',
        'superfish-navbar',
        'superfish-vertical',
        'jquery.jqplot',
        'visualize',
        'visualize-light',
        'highslide',
        'jquery.treeview',
        'tooltip'
      ]
    else
      [
        'style',
        'style2',
        'application',
        'constants',
        'grid',
        'rounded_box',
        'tables',
        'menu',
        'qm_styles',
        'redbox',
        'jquery.rating',
        'jquery.multiSelect',
        'jquery-ui-1.8.5.custom',
        'jquery.ui.autocomplete.custom',
        'tagit-simple-blue',
        'jslider',
        'superfish',
        'superfish-navbar',
        'superfish-vertical',
        'visualize',
        'visualize-light',
        'highslide',
        'jquery.treeview',
        'tooltip',
        'edintity_admin',
      ]
    end
  end


  def javascript_sources
    [
      :defaults,
      'jquery',
      'menu',
      'jquery-1.4.2.min',
      'jquery-ui-1.8.5.custom.min.js',
      'jquery-1.6.2.js',
      #      'jquery.textbox-hinter.js',
      'redactor.min.js',
      'jquery.corner',
      'jquery.dodosTextCounter-0.1',
      'jquery-ui/jquery-ui-1.8.core-and-interactions.min.js',
      'jquery-ui/jquery-ui-1.8.autocomplete.min.js',
      'tagit/tagit.js',
      'tagit/autocomplete.js',
      'jquery.jslide.js',
      'jquery.dependClass.js',
      'hoverIntent.js',
      'visualize.jQuery.js',
      'jquery.media',
      'handlers.js',
      'highcharts.js',
      'exporting.js',
      'mootools-adapter.js',
      'highslide-full.min.js',
      'highslide.config.js',
      'jquery.cookie.js',
      'jwplayer.js',
      'jquery.treeview.js',
      'jquery.tools.min.js',
      'swfupload',
      'jquery-asyncUpload-0.1',
      'jquery.rating',
      'swfobject',
      'tumblelog.js',
      "#{session[:locale] == 'arabic' ? 'jquery.slider-arabic.js' : 'jquery.slider.js'}",
      'excanvas.js',
      'jquery_conflict',
      'application',
      'slide_effect/qm',
      'slide_effect/qm_slide_effect',
      'redbox',
      'superfish.js',
      'supersubs.js',
      'jquery.embedly.min.js',
      'global',
      'prototype',
      'triggeronview',
      'jquery.easing-1.3.pack',
      'jquery.fancybox-1.3.4',
      'jquery.fancybox-1.3.4.pack',
      'jquery.mousewheel-3.0.4.pack',
      'jquery.pngFix.pack',
      'selectivizr',
      'jquery.multiSelect',
      'fileuploader',
      'datepicker',
      'mColorPicker.js',
      'skins',
      'scroll-startstop.events.jquery'
    ]
  end

  def around_partial(partial, locals = {}, &block)
    render(:partial => partial, :locals => locals.merge(:inner_content => capture(&block)))
  end

  def page_title
    " - #{controller_name.titleize}" unless controller_name == "user_sessions"
  end

  def shorten_with_bitly(url)
    # build url to bitly api
    url = url.gsub("^equal_to^", "=")
    url = url.gsub("^question_mark^", "?")
    url = url.gsub("^and^", "&")
    user = "sumeru"
    apikey = "R_1557bd1406a82885437743d1cb5aaffa"
    version = "2.0.1"
    bitly_url = "http://api.bit.ly/shorten?version=#{version}&longUrl=#{url}&login=#{user}&apiKey=#{apikey}"
    buffer = open(bitly_url, "UserAgent" => "Ruby-ExpandLink").read
    result = JSON.parse(buffer)
    short_url = result['results'].blank? ? nil : result['results'][url]['shortUrl']
    [short_url, result['errorMessage']]
  end

  def sign_up
    @sign_up = "false"
    return @sign_up
  end

  def sign_in
    @sign_in = "true"
    return @sign_in
  end

  def link_or_span(title, path, html_class)
    link_to_unless_current title, path, html_class do
      if html_class[:class] != "header_link"
        content_tag :span, title, html_class = {:class => 'navigae active' }
      else
        content_tag :span, title, html_class = {:class => 'header_link_activ' }
      end
    end
  end

  def to_local(date)
    unless current_user && current_user.time_zone.blank?
      begin
        tz = TZInfo::Timezone.get(current_user.time_zone)
        tz.utc_to_local(date)
      rescue
        tz = TZInfo::Timezone.get("Asia/Riyadh")
        tz.utc_to_local(date)
      end
    else
      date
    end
  end


end

class String
  # Replace the second of three capture groups with the given block.
  def midsub(regexp, &block)
    self.gsub(regexp) { $1 + yield($2) + $3 }
  end
end

def wordwrap(text,rss_text=false, width=40, string="<wbr />", twitter = false)
  text = wrap_anchor(text.to_s,rss_text, twitter)
  text.midsub(%r{(\A|</pre>)(.*?)(\Z|<pre(?: .+?)?>)}im) do |outside_pre|  # Not inside <pre></pre>
    outside_pre.midsub(%r{(\A|>)(.*?)(\Z|<)}m) do |outside_tags|  # Not inside < >, either
      outside_tags.gsub(/(\S{#{width}})(?=\S)/) { "#$1#{string}" }
    end
  end
end

def link_to_remove_fields(name, f)
  f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
end

def link_to_add_fields(name, f, association)
  new_object = f.object.class.reflect_on_association(association).klass.new
  fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
    render(association.to_s.singularize + "_fields", :f => builder)
  end
  link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
end

def bytes_to_mb(bytes)
  (((bytes.to_i/1024/1024.0)*1000).round.to_f/1000).to_s + " MB"
end

def wrap_anchor(text, rss_text = false, twitter = false)
  texts = text.split(" ")
  new_text = []
  texts.each do |txt|
    unless txt.match(/src\=\"http:\/\/([\w+?\.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&amp;\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)/)
      if txt.match(/http:\/\/([\w+?\.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&amp;\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)/)
        txt_link, txt_word = check_false_link(txt, "http")
        video = rss_text ? "" : is_video?(txt)
        if video.class != String
          new_text << "#{video.embed_html(400, 305)}"
        else
          if txt.match(/\Ahttp.*(jpeg|jpg|gif|png)\Z/)
            new_text << "<a title='' target='_blank' rel='example_group' href='#{txt_link}' class='attacmentImg'><img src='#{txt_link}' style='width: 166px; height:120px;'/></a>"
          else
            new_text << "<a href='#{txt_link}' target='_blank'>#{txt_word}</a>"
          end
        end
      elsif txt.match(/www([.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&amp;\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)/)
        txt_link, txt_word = check_false_link(txt, "www.")
        video = is_video?(txt)
        if video.class != String
          new_text << "#{video.embed_html(400, 305)}"
        else
          if txt.match(/\A.*(jpeg|jpg|gif|png)\Z/)
            new_text << "<a title='' target='_blank' rel='example_group' href='#{txt_link}' class='attacmentImg'><img src='#{txt_link}' style='width: 166px; height:120px;'/></a>"
          else
            new_text << "<a href='http://#{txt_link}' target='_blank'>#{txt_word}</a>"
          end
        end
      elsif twitter && txt.match(/^@/)
        word = txt.gsub('@','').gsub(':','')
        new_text << "<a href='https://twitter.com/#!/#{word}' target='_blank'>#{txt}</a>"
      elsif twitter && txt.match(/^#/)
        word = txt.gsub('#','')
        new_text << "<a href='https://twitter.com/#!/search?q=%23#{word}' target='_blank'>#{txt}</a>"
      elsif txt.match(/\Ahttp.*(jpeg|jpg|gif|png)\Z/)
        txt_link, txt_word = check_false_link(txt, "http")
        new_text << "<a title='' target='_blank' rel='example_group' href='#{txt_link}' class='attacmentImg'><img src='#{txt_link}' style='width: 166px; height:120px;'/></a>"
      else
        new_text << txt
      end
    else
      new_text << txt
    end
  end
  new_text.join(" ")
end

def check_false_link(txt, start)
  if txt.start_with?(start)
    txt_link = txt
    txt_word = txt
  else
    txt_word = txt.gsub(start," #{start}")
    txt_link = txt_word.split(" ")[1].split("</p>")[0]
  end
  [txt_link, txt_word]
end

def sign_in_video(video_url)
  video = []
  video_object = is_video?(video_url)
  if video_object.class != String
    video << "#{video_object.embed_html(535, 305)}"
  else
    video << "<a href='#{video_url}' target='_blank'>#{video_url}</a>"
  end
  video
end

def is_video?(url)
  begin
    UnvlogIt.new(url)
  rescue Exception => e
    return e.message
  end
end

def validate_link(url)
  url = "http://" + url
  url.match(/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/)
end

def bread_crumb(brand)
  if !brand.parent
    content = @bread_crum || brand
    @company = @brand.company unless @company.blank?
    return content
  else
    @bread_crum << brand.parent
    bread_crumb(brand.parent)
  end
end
