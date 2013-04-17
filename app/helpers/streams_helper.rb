module StreamsHelper
  def stars(value, object, size = 'small', color = 'yellow')
    filename = "star_#{size}_#{color}"
    full_stars = value.to_i
    empty_stars = FEEDBACK_ANSWER_MAX - full_stars
    capture_haml do
      haml_tag :div, {:class => 'stars'} do
        # TODO: We need a better nowrap solution.
        haml_concat(
          link_to_remote(image_tag("#{filename}.png", :alt => ""), :url => update_rating_stream_path(object, :count => -1), :method => :get ) * full_stars +
            link_to_remote(image_tag("star_#{size}_white.png", :alt => ""), :url => update_rating_stream_path(object, :count => 1), :method => :get )  * empty_stars
        )
      end
    end
  end 
end
