class StreamDetail < ActiveRecord::Base
  belongs_to :stream

  def self.create_stream_detail(twit_stream, stream, stream_type)
    stream_db_type = stream_type == "Sender" ? "sender" : "recipient"
    StreamDetail.create(:stream_id => stream.id, :streamable_type => stream_type,
      :name => twit_stream["#{stream_db_type}"]["name"],
      :followers_count =>  twit_stream["#{stream_db_type}"]["followers_count"],
      :favourites_count => twit_stream["#{stream_db_type}"]["favourites_count"],
      :location =>  twit_stream["#{stream_db_type}"]["location"],
      :description =>  twit_stream["#{stream_db_type}"]["description"],
      :friends_count =>  twit_stream["#{stream_db_type}"]["friends_count"],
      :utc_offset =>  twit_stream["#{stream_db_type}"]["utc_offset"],
      :time_zone =>  twit_stream["#{stream_db_type}"]["time_zone"],
      :statuses_count =>twit_stream["#{stream_db_type}"]["statuses_count"],
      :profile_image_url => twit_stream["#{stream_db_type}"]["profile_image_url"],
      :created_date => twit_stream["#{stream_db_type}"]["created_at"])

  end


end
