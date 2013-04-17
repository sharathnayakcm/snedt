class RoundedBoxPresenter < Presenter::Base
  attr_accessor :collection, :id

  def initialize(template, collection, options = {})
    super template, options
    @options.assert_valid_keys_and_recursive_reverse_merge!(
      :accordion => false,
      :accordion_id => nil,
      :actions => nil,
      :collapsible => false,
      :color => 'white',
      :draggable => false,
      :edit_path => nil,
      :footer => {
        :color => 'white' # TODO: This should be changed to chrome when the rounded_box/table footer refactoring occurs.
      },
      :fused => false,
      :group_name => nil,
      :hash_for_path => {},
      :header => {
        :color => 'chrome',
        :level => 1,
        :subtext => nil,
        :text => nil
      },
      :param_prefix => nil,
      :tabs => nil,
      :tooltip => nil
    )

    @collection = collection

    @id = @options[:group_name] ? "#{@options[:group_name]}_rounded_box" : "rounded_box_#{@options.hash.abs}"

    @options[:actions] = @options[:actions].compact if @options[:actions]
    @options[:header][:color] = @options[:color] if header_is_empty?
    @options[:footer][:color] = @options[:color] unless @options[:footer][:color] == 'chrome' # TODO: This should be deleted when the rounded_box/table footer refactoring occurs.
    # @options[:footer][:color] = @options[:color] if footer_is_empty? TODO: This should be re-enabled when the rounded_box/table footer refactoring occurs.
  end

  def css_class(*css_classes)
    css_class = css_classes.flatten.compact.join(' ')
    css_class.blank? ? nil : css_class
  end

  def css_style(*css_styles)
    css_style = css_styles.flatten.compact.join('; ')
    css_style.blank? ? nil : css_style
  end

  def rounded_box(&block)
    div_classes = ['rounded_box']
    div_classes << 'accordion' if @options[:accordion]
    div_classes << 'fused' if @options[:fused]
    div_classes << 'tabbed' if @options[:tabs]

    haml_tag :div, :class => css_class(div_classes), :id => @id do
      yield
      haml_concat javascript_tag(
        <<-javascript
          if(getCookie('#{@id}') == 'closed') {
            $$('*.#{"expansion_of_#{@id}"}').invoke('toggle');
            $$('*.#{"expander_for_#{@id}"}').invoke('toggle');
            $('#{@id}').addClassName('collapsed');
          }
        javascript
      ) if @options[:collapsible]
    end
  end

  def header
    div_classes = ['rounded_box_header', @options[:header][:color]]
    div_classes << 'accordion_toggle' if @options[:accordion]

    haml_tag :div, :class => css_class(div_classes) do
      haml_tag :table, :cellspacing => 0, :class => 'rounded_box_header_cap' do
        haml_tag :tr do
          haml_tag :td, :class => td_css_classes('header_cap', @options[:header][:color], 'left')
          haml_tag :td, :class => td_css_classes('header_cap', @options[:header][:color], 'center') do
            # TODO: This addresses an IE problem. The CSS should be externalized.
            haml_tag :div, :style => 'font-size: 1px; height: 1px; line-height: 1px;' do
              haml_concat '&nbsp;'
            end
          end
          haml_tag :td, :class => td_css_classes('header_cap', @options[:header][:color], 'right')
        end
      end
      haml_tag :table, :cellspacing => 0, :class => 'rounded_box_header' do
        unless header_is_empty?
          haml_tag :tr do
            haml_tag :td, :class => td_css_classes('header', @options[:header][:color], 'left')
            haml_tag :td, :class => td_css_classes('header', @options[:header][:color], 'center') do
              haml_tag :div, :class => 'container rounded_box_header_padding' do
                if @options[:header]
                  haml_tag :div, :class => 'float_left', :style => "margin-bottom: 0px;" do
                    hn_classes = []
                    #hn_classes << 'inline' if @options[:header][:subtext]

                    haml_tag "h#{@options[:header][:level]}", :class => css_class(hn_classes) do
                      haml_concat @options[:header][:text]
                    end
                    if @options[:header][:subtext]
                      #haml_tag :p, :class => 'inline large' do
                      haml_tag :p, :class => 'large' do
                        haml_concat @options[:header][:subtext]
                      end
                    end
                  end
                end
                if @options[:tabs]
                  haml_tag :div, :class => 'float_left margin_left tabs_offset' do
                    haml_concat tabs(@options[:tabs], :group_name => @id, :hash_for_path => @options[:hash_for_path])
                  end
                end
                if @options[:collapsible]
                  haml_tag :div, :class => 'float_right quarter_margin_left' do
                    haml_concat link_to_collapse(@id)
                  end
                end
                if @options[:draggable]
                  haml_tag :div, :class => 'float_right quarter_margin_left' do
                    haml_concat image_tag('icons/dragger.png', :class => 'draggable')
                  end
                end
                if @options[:tooltip]
                  haml_tag :div, :class => 'float_right quarter_margin_left' do
                    haml_concat image_tag('icons/tooltip.png', :class => 'link', :id => "#{@id}_tooltip_trigger")
                    tooltip(:tooltip_id => "#{@id}_tooltip", :trigger_id => "#{@id}_tooltip_trigger") {haml_concat @options[:tooltip]}
                  end
                end
                if @collection.is_a?(WillPaginate::Collection)
                  haml_tag :div, :class => 'float_right quarter_margin_left' do
                    haml_concat will_paginate(@collection, {:params => @options[:hash_for_path], :remote => {:update => @id}})
                  end
                end
                if @options[:edit_path]
                  haml_tag :div, :class => 'float_right quarter_margin_left' do
                    haml_concat edit_button("#{@id}_content", @options[:edit_path])
                  end
                end
                haml_tag :div, :class => 'float_right quarter_margin_left', :style => "margin-top:7px; margin-bottom:-7px;", :id => "#{@id}_actions" do
                  if @options[:actions]
                    haml_tag :ul, :class => 'horizontal' do
                      @options[:actions].each_with_index do |action, index|
                        haml_tag :li, :class => index == 0 ? 'first-child' : nil do
                          haml_concat action
                        end
                      end
                    end
                  end
                end
              end
            end
            haml_tag :td, :class => td_css_classes('header', @options[:header][:color], 'right')
          end
        end
      end
    end
  end

  def content(&block)
    div_classes = ['rounded_box_content', @options[:color]]
    div_classes << 'accordion_content' if @options[:accordion]
    div_classes << "expansion_of_#{@id}" if @options[:collapsible]

    div_styles = []
    div_styles << 'display: none' if @options[:accordion]

    haml_tag :div, :class => css_class(div_classes), :style => css_style(div_styles), :id => @options[:accordion_id]  do
      haml_tag :table, :cellspacing => 0, :class => 'rounded_box_content' do
        haml_tag :tr do
          haml_tag :td, :class => td_css_classes('content', @options[:color], 'left')
          haml_tag :td, :class => td_css_classes('content', @options[:color], 'center') do
            haml_tag :div, :class => 'container', :id => "#{@id}_content" do
              yield
            end
          end
          haml_tag :td, :class => td_css_classes('content', @options[:color], 'right')
        end
      end
    end
  end

  def footer
    div_classes = ['rounded_box_footer', @options[:footer][:color]]

    haml_tag :div, :class => css_class(div_classes) do
      haml_tag :table, :cellspacing => 0, :class => 'rounded_box_footer' do
        unless footer_is_empty? || true
          haml_tag :tr do
            haml_tag :td, :class => td_css_classes('footer', @options[:footer][:color], 'left')
            haml_tag :td, :class => td_css_classes('footer', @options[:footer][:color], 'center') do
              haml_tag :div, :class => 'container rounded_box_footer_padding' do
                # TODO: Footer content will go here.
              end
            end
            haml_tag :td, :class => td_css_classes('footer', @options[:footer][:color], 'right')
          end
        end
      end
      haml_tag :table, :cellspacing => 0, :class => 'rounded_box_footer_cap' do
        haml_tag :tr do
          haml_tag :td, :class => td_css_classes('footer_cap', @options[:footer][:color], 'left')
          haml_tag :td, :class => td_css_classes('footer_cap', @options[:footer][:color], 'center') do
            # TODO: This addresses an IE problem. It can be removed when rounded_box footers actually contain content.
            haml_tag :div, :style => 'font-size: 1px; height: 1px; line-height: 1px;' do
              haml_concat '&nbsp;'
            end
          end
          haml_tag :td, :class => td_css_classes('footer_cap', @options[:footer][:color], 'right')
        end
      end
    end
  end

  def header_is_empty?
    !(@options[:header][:text] || @options[:tabs] || @options[:collapsible] || @options[:draggable] || @options[:edit_path] || @options[:actions])
  end

  def footer_is_empty?
    !@collection.is_a?(WillPaginate::Collection) || @collection.is_a?(WillPaginate::Collection) && @collection.empty?
  end

  def td_css_classes(segment, color, position)
    td_css_classes = ["rounded_box_#{segment}_#{position}", "rounded_box_#{segment}_#{color}_#{position}"]
    css_class(td_css_classes)
  end
end