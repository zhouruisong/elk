require "bundler/gem_tasks"

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:spec]

file 'lib/protocol_buffers/runtime/text_parser.rb' => 'lib/protocol_buffers/runtime/text_parser.ry' do |t|
  sh 'racc', '-o', t.name, *t.prerequisites
end

task :text_parser => 'lib/protocol_buffers/runtime/text_parser.rb'
task :spec => :text_parser
task :build => :text_parser
