# To change this template, choose Tools | Templates
# and open the template in the editor.
class Grid::PostServiceGroupsPreseneter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Post Group Name", :order => :name},
          {:name => "Post type"},
          {:name => "Services"},
          {:name => "Action"}
        ],
        :default_order => 'name desc',
        :empty => "No post service group created yet",
        :hash_for_path => hash_for_post_service_groups_path,
        :search => true,
        :version => 2
      )
    )
  end
end