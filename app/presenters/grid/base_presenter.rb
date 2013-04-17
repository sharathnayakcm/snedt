class Grid::BasePresenter < Presenter::Base
  attr_accessor :collection, :columns_count, :columns_counter, :current_order, :id

  def initialize(template, options = {})
    super template, options
    @options.assert_valid_keys_and_reverse_merge!(
      :additional_path_params => {}, # TODO: Remove this?
      :columns => [],
      :default_order => nil,
      :default_per_page => nil,
      :empty => nil,
      :expandable => false,
      :group_name => nil,
      :hash_for_path => {},
      :id_suffix => nil,
      :order => nil,
      :parent_object => nil,
      :search => false,
      :tbody_id => nil,
      :version => 1 # TODO: Remove this.
    )

    @id = if @options[:group_name] # The old way of identifying a table. TODO: Remove this.
      "#{@options[:group_name]}_grid"
    else # The new way of identifying a table.
      new_id
    end

    reset_cycle @id

    @columns_count = @options[:columns].collect {|column| column[:colspan] || 1}.sum + (@options[:expandable] ? 1 : 0)
    @columns_counter = 0

    @current_order = case @options[:version]
    when 1 # The old way. TODO: Remove this.
      if @options[:order]
        {
          :column => @options[:order].split(' ').first,
          :direction => @options[:order].split(' ').last
        }
      end
    when 2 # The new way.
      if param_for(:order) # TODO: Doesn't account for whitelist/default_order.
        {
          :column => param_for(:order).split(' ').first,
          :direction => param_for(:order).split(' ').last
        }
      elsif @options[:default_order]
        {
          :column => @options[:default_order].split(' ').first,
          :direction => @options[:default_order].split(' ').last
        }
      end
    end
  end

  def new_id # TODO: Refactor inline.
    new_id = []
    new_id << params[:parent_table_id].gsub('_grid', '') if params[:parent_table_id] # TODO: This only supports one parent_table_id parameter per page. It's not scoped to a particular table!
    new_id << @options[:parent_object].id if @options[:parent_object]
    new_id << self.class.name.underscore.gsub('/', '_').gsub('table_', '').gsub('_presenter', '')
    new_id << 'table'
    new_id << @options[:id_suffix] if @options[:id_suffix]
    new_id.compact.join('_')
  end

  def param_name_for(param)
    "#{@id}_#{param}"
  end

  def param_for(param)
    params[param_name_for(param)]
  end

  def order
    if order = param_for(:order)
      whitelist = @options[:columns].collect {|column| column[:order].to_s}
      if order.split(' ').size <= 2 && whitelist.include?(order.split(' ').first) && %w(ASC DESC).include?(order.split(' ').last.upcase)
        order
      else
        @options[:default_order]
      end
    else
      @options[:default_order]
    end
  end

  def page
    param_for :page
  end

  def per_page
    param_for(:per_page) || @options[:default_per_page]
  end

  def order_asc?
    !order_desc?
  end

  def order_desc?
    order.upcase.include? 'DESC'
  end

  def order_method
    order.split(' ').first
  end

  def sort(collection)
    if collection.first.respond_to?(order_method)
      collection = collection.sort_by do |object|
        object.send order_method
      end

      order_asc? ? collection : collection.reverse
    else
      collection
    end
  end

  def render(collection = nil, &block)
    # TODO: We need something like this for performance. But this fails tests.
    # return if collection.blank?

    @collection = collection

    if @collection.is_a?(Array) && @collection.empty?
      haml_tag :div, :class => 'rounded_box_content_padding' do
        haml_tag :p, :class => 'quiet' do
          haml_concat @options[:empty]
        end
      end
    else
      table do
        thead
        tfoot
        tbody do
          yield self
        end
      end
    end
  end

  def table(&block)
    haml_tag :div, :class => 'table', :id => @id do
      haml_tag :table, :cellspacing => 0, :class => 'data' do
        yield
      end
    end
  end

  def thead
    @options[:columns].unshift({}) if @options[:expandable]

    @options[:columns].each do |column|
      column.assert_valid_keys_and_reverse_merge!(
        :colspan => nil,
        :if => true,
        :name => nil,
        :order => nil,
        :default_sort => :asc
      )
    end

    @options[:columns].reject! {|column| !column[:if]}

    haml_tag :thead do
      haml_tag :tr do
        @options[:columns].each_with_index do |column, index|
          th_classes = ['data']

          if column[:order]
            column[:name] =
              if @current_order[:column] == column[:order].to_s
              case @current_order[:direction].upcase
              when 'ASC': "#{column[:name]} #{image_tag '/images_old/sorter_asc.png'}"
              when 'DESC': "#{column[:name]} #{image_tag '/images_old/sorter_desc.png'}"
              end
            else
              column[:name]
            end
            column[:order] =
              if @current_order[:column] == column[:order].to_s
              case @current_order[:direction].upcase
              when 'ASC': "#{column[:order]} desc"
              when 'DESC': "#{column[:order]} asc"
              end
            else
              default_sort = column[:default_sort] == :asc ? 'asc' : 'desc'
              "#{column[:order]} #{default_sort}"
            end

            hash_for_path = case @options[:version]
            when 1 # The old way. TODO: Remove this.
              filter_params(@options[:hash_for_path].merge(:order => column[:order], :page => nil))
            when 2 # The new way.
              filter_params(@options[:hash_for_path].merge(param_name_for(:order) => column[:order], param_name_for(:page) => nil)).merge(@options[:additional_path_params])
            end

            th_classes << 'link'
          end

          th_classes << 'no_border_right' if index == @options[:columns].size - 1

          th_onclick = if column[:order]
            remote_function(
              :method => :get,
              :update => @id,
              :url => {:overwrite_params => hash_for_path},
              :with => @options[:search] ? "'#{'no_filters=1&' if params[:no_filters]}search=' + (document.location.search.substr(1).parseQuery()['search'] || '')" : nil
            )
          else
            nil
          end

          haml_tag :th, :class => css_class(th_classes), :colspan => column[:colspan], :onclick => th_onclick do
            if column[:name].blank?
              haml_concat '&nbsp;'
            else
              haml_concat column[:name]
            end
          end
        end
      end
    end
  end

  def tfoot
    if @collection.is_a?(WillPaginate::Collection) && !@collection.empty?
      td_classes = ['data', 'no_border_right']

      haml_tag :tfoot do
        haml_tag :tr do
          haml_tag :td, :class => css_class(td_classes), :colspan => @columns_count do
            haml_tag :div, :class => 'float_left' do
              haml_concat "Listing <input class='align_center' type='text' value=#{@collection.per_page} size='1' onchange=\"window.location = '#{url_for(@options[:hash_for_path])}?per_page='+ this.value + '&search_key=#{params[:search_key]}';\"/> #{@collection.first.class.name.underscore.humanize.downcase.pluralize} per page"
            end
            haml_tag :div, :class => 'float_right' do
              haml_concat will_paginate(@collection, {:param_name => (@options[:version] == 2 ? param_name_for(:page) : :page), :params => @options[:hash_for_path], :remote => {:update => @id, :before => "ensure_element_visible('#{@id}')"}})
            end
            haml_tag :strong do
              haml_concat "#{@collection.total_entries} total #{@collection.first.class.name.underscore.humanize.pluralize}".downcase
            end
          end
        end
      end
    end
  end

  def tbody(&block)
    haml_tag :tbody, :class => 'hover', :id => @options[:tbody_id] do
      yield
    end
  end

  def tr(options = {}, &block)
    # TODO: remove :class, :id option
    options.assert_valid_keys_and_reverse_merge!(
      :cache_suffix => nil,
      :class => nil,
      :expander_for => nil,
      :expander_to => nil,
      :expansion_of => nil,
      :id => nil
    )

    tr_classes = []
    if @options[:expandable] && options[:expansion_of]
      tr_classes << current_cycle(@id)
      tr_classes << 'expansion'
      tr_classes << dom_id(options[:expansion_of], "expansion_of_#{@id}")
    else
      tr_classes << cycle('odd', 'even', :name => @id)
    end
    tr_classes << options[:class]

    tr_styles = []
    tr_styles << 'display: none' if @options[:expandable] && options[:expansion_of]

    haml_tag :tr, :class => css_class(tr_classes), :id => options[:id], :style => css_style(tr_styles) do
      if @options[:group_name] && options[:cache_suffix]
        cache [@id, options[:cache_suffix]].join('_') do
          tr_content options do
            yield
          end
        end
      else
        tr_content options do
          yield
        end
      end
    end
    if options[:expander_to]
      tr options.except(:expander_for, :expander_to).merge(:expansion_of => options[:expander_for]) do
        td(:colspan => :all, :fused => true, :id => dom_id(options[:expander_for], "expansion_of_#{@id}")) {}
      end
    end
  end

  def tr_content(options = {}, &block)
    if @options[:expandable]
      td(:expander) {link_to_expand options[:expander_for], nil, :id_prefix => @id, :remote => options[:expander_to] ? {:update => dom_id(options[:expander_for], "expansion_of_#{@id}"), :url => options[:expander_to].merge(:parent_table_id => @id)} : nil} if options[:expander_for]
      td(:expander) {} if options[:expansion_of]
    end
    yield
  end

  def td(*args, &block)
    options = args.extract_options!
    if format = args.shift
      raise "Invalid column format: #{format}." unless [:action, :check_box, :currency, :date, :date_time, :expander, :number, :percentage, :priority, :stars, :status, :user].include?(format)
    end

    # TODO: remove :class, :id option
    options.assert_valid_keys_and_reverse_merge!(
      :class => nil,
      :colspan => nil,
      :fused => false,
      :id => nil,
      :width => nil
    )

    # TODO: Don't assume all :colspan => :all cells are expansion rows. Yield a contextual tr object.
    expansion = options[:colspan] == :all
    options[:colspan] = @columns_count - (@options[:expandable] ? 1 : 0) if expansion

    @columns_counter += options[:colspan] || 1

    td_classes = ['data']
    td_classes << 'fused' if options[:fused]
    td_classes << [format, 'hover']
    if @columns_counter == @columns_count
      td_classes << 'no_border_right'
      @columns_counter = 0
    end
    td_classes << options[:class]

    td_styles = []
    td_styles << "width: #{options[:width]}px" if options[:width]

    haml_tag :td, :class => css_class(td_classes), :colspan => options[:colspan], :id => options[:id], :style => css_style(td_styles) do
      content = capture_haml(&block).blank? ? block.call : capture_haml(&block)

      content = case format
      when :currency
        content.is_a?(Numeric) ? number_to_currency(content) : content
      when :date
        content.is_a?(Date) || (content.is_a?(Time) ) ? content.to_time.to_s(:slashed_date) : content
      when :date_time
        content.is_a?(Date) || (content.is_a?(Time) ) ? content.to_time.strftime("%m/%d/%Y %H:%M")  : content
      when :number
        content.is_a?(Numeric) ? number_with_delimiter(content) : content
      when :percentage
        content.is_a?(Numeric) ? number_to_percentage(content, :precision => 2) : content
      else
        content
      end

      haml_concat content.blank? ? '&nbsp;' : content
    end
  end

  def css_class(*css_classes)
    css_class = css_classes.flatten.compact.join(' ')
    css_class.blank? ? nil : css_class
  end

  def css_style(*css_styles)
    css_style = css_styles.flatten.compact.join('; ')
    css_style.blank? ? nil : css_style
  end
end
