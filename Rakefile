task :default => [:gdl_parser]

task :gdl_parser => [:gdl_syntax, :gdl_rex]

task :gdl_syntax => ['game_description_language.y'] do
  `racc -g game_description_language.y`
end

task :gdl_rex => ['game_description_language.rex'] do
  `rex game_description_language.rex`
end

task :clean do
  `rm -rf game_description_language.rex.rb`
  `rm -rf game_description_language.tab.rb`
  `rm -rf game_description_language.output`

  `rm -rf *~ \#*`
end
