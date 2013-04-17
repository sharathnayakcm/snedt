module RoundedBoxHelper
  def rounded_box_for(collection, options = {}, &block)
    rounded_box = RoundedBoxPresenter.new(@template, collection, options)

    rounded_box.rounded_box do
      rounded_box.header
      rounded_box.content do
        yield rounded_box
      end
      rounded_box.footer
    end
  end

  def update_rounded_box_actions(actions, options = {})
    actions = actions.compact

    options.assert_valid_keys_and_reverse_merge!(
      :group_name => nil
    )

    content = capture_haml do
      unless actions.empty?
        haml_tag :ul, :class => 'horizontal' do
          actions.each_with_index do |action, index|
            haml_tag :li, :class => index == 0 ? 'first-child' : nil do
              haml_concat action
            end
          end
        end
      end
    end

    update_page_tag do |page|
      page << "if($('#{options[:group_name]}_rounded_box_actions')) {"
      page.replace_html "#{options[:group_name]}_rounded_box_actions", content
      page << '}'
    end
  end

  def simple_header(header_text, options={})
    options.assert_valid_keys_and_reverse_merge!(
      :css => nil,
      :edit_id => nil,
      :edit_path => nil,
      :actions => nil
    )

    capture_haml do
      haml_tag :div, :class => "simple_header #{options[:css]}" do
        haml_tag :div, :class => 'container' do
          haml_tag :div, :class => 'float_left half_margin_left' do
            haml_concat header_text
          end
          if options[:edit_id] && options[:edit_path]
            haml_tag :div, :class => 'float_right' do
              haml_concat edit_button(options[:edit_id], options[:edit_path])
            end
          end
          if options[:actions]
            haml_tag :div, :class => 'float_right half_margin_right quarter_margin_bottom' do
              haml_concat options[:actions]
            end
          end
        end
      end
    end
  end

  def edit_button(update_id = '', path = '', caption = nil)
    caption_tag = caption || image_tag('buttons/small/edit.png')
    link_to_remote(caption_tag, {:url => path, :update => update_id, :method => :get, :tag =>"span"})
  end
end