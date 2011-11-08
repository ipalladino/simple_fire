namespace :bootstrap do
  desc "Add the default ecard"
  task :default_ecard => :environment do
    Ecard.create( :variant_id => 141661592, :filename => 'mermaid.swf' )
  end

  #desc "Create the default comment"
  #task :default_comment => :environment do
    #Comment.create( :title => 'Title', :body => 'First post!' )
  #end

  desc "Run all bootstrapping tasks"
  task :all => [:default_ecard]
end