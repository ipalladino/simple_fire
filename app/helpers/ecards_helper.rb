module EcardsHelper
  
  def print_ecards(ecards)
    print "List of ecards"
    ecards.each {|ecard| print "<tr><td>#{ecard.filename}</td></tr>"}
  end
  
end
