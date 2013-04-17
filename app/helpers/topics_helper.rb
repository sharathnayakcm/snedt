module TopicsHelper

  def get_level(points)
    case points
    when 0..10 then t(:level_1)
    when 10..20 then t(:level_2)
    when 20..50 then t(:level_3)
    when 50..100 then t(:level_4)
#    when 100..200 then t(:level_5)
    else t(:level_5)
    end
  end
end
