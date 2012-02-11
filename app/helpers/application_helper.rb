module ApplicationHelper
  
  # Return a title on a per-page basis
  def title
    base_title = "Artiphany"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def logo
    image_tag("logo1.png", :alt => "Sample App", :class => "logo")
  end
  
  def gizmo
    image_tag("gizmo.png", :alt => "Gizmo", :class => "logo")
  end
  
  def ohare
    image_tag("ohare.png", :alt => "Mr Ohare", :class => "logo")
  end
end
