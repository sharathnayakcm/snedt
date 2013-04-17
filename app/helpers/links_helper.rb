module LinksHelper
  def link_to_remote_with_loader(name, options = {}, html_options = nil)
    html_options ||= options.delete(:html) || {}
    build_tag = options[:action_id].blank?
    hashed_options = options.hash.abs
    options.reverse_merge!(
      :action_flag => true,
      :action_id => "action_div_#{hashed_options}_#{rand(10000000)}_#{Time.now.to_i}"
    )
    html_options.reverse_merge!(
      :id => "action_#{hashed_options}_#{rand(10000000)}_#{Time.now.to_i}"
    )

    return link_to_remote(name, options, html_options) unless options[:action_flag]

    # TODO: This is just plain weird and I'm going to clean it up later.
    options[:loading] = [options[:loading], load_spinner(options[:action_id], html_options[:id])].compact.join('; ')
    options[:complete] = [options[:complete], hide_spinner(options[:action_id], html_options[:id])].compact.join('; ')

    if build_tag
      # We need to build a tag and a link.
      # TODO: This will be built with Haml once render_with_haml_support works.
      "<#{options[:tag] || 'span'} id='#{options[:action_id]}'>#{link_to_function name, remote_function(options), html_options}</#{options[:tag] || 'span'}>"
    else
      # We just need to build a link.
      link_to_function name, remote_function(options), html_options
    end
  end

  def load_spinner(action_id, html_id = nil)
    "replaceHourGlass('#{action_id}', '#{html_id}')"
  end

  def hide_spinner(action_id, html_id)
    ["if($('#{action_id}img')) {$('#{action_id}img').hide()}", "if($('#{html_id}')) {$('#{html_id}').show()}"].compact.join('; ')
  end

end
