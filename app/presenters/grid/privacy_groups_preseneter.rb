# To change this template, choose Tools | Templates
# and open the template in the editor.
class Grid::PrivacyGroupsPreseneter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Group Name", :order => :name},
          {:name => "Members"},
          {:name => "Services"},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => "No privacy group created yet",
        :hash_for_path => hash_for_privacy_groups_path,
        :search => true,
        :version => 2
      )
    )
  end
end