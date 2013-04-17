# To change this template, choose Tools | Templates
# and open the template in the editor.
class Grid::Admin::StaticPagesPresenter < Grid::BasePresenter
 
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Title", :order => :title},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_admin_static_pages_path,
        :search => true,
        :version => 2
      )
    )
  end
end
