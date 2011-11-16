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
end
