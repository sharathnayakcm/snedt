class PostType < ActiveRecord::Base
  has_many :posts
  has_many :post_service_groups
  has_many :streams , :foreign_key => "post_type"
  POST_TYPE_ID={
    :blog => 1,
    :photo => 2,
    :link => 3,
    :status_update => 4,
    :video => 5
  }
end
