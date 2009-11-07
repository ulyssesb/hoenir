task :default => [:gdl_parser]

task :gdl_parser => [:gdl_syntax, :gdl_rex]

task :gdl_syntax => ['gdl_parser.y'] do
  `racc -g gdl_parser.y`
end

task :gdl_rex => ['gdl_scanner.rex'] do
  `rex gdl_scanner.rex`
end

task :clean do
  `rm -rf gdl_scanner.rex.rb`
  `rm -rf gdl_parser.tab.rb`
  `rm -rf game_description.yap`
  `rm -rf *.log`
  `rm -rf *~ \#*`
end
