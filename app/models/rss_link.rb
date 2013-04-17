class RssLink < ActiveRecord::Base
  belongs_to :user
  has_many :streams, :dependent => :destroy

  def self.parse_rss_feed(source)
    begin
      content = ""
      open(source) do |s|
        content = s.read
      end
      rss = RSS::Parser.parse(content, false)
      return rss
    rescue Exception => e
      return nil
    end
  end

  def self.get_feeds(current_user)
    begin
      current_user.rss_links.to_a.each do |link|
        feeds = Feedzirra::Feed.fetch_and_parse(link.url)
        unless feeds == 0
          rss_feeds = feeds.sanitize_entries!
          Stream.save_rss_stream_details(rss_feeds.entries, current_user, link) if feeds
        end
      end
    rescue
    end
  end

end
