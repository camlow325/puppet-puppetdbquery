require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'

task :default => [:test]

desc 'Run RSpec'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/{unit}/**/*.rb'
  t.rspec_opts = ['--color']
end

desc "Generate Lexer and Parser"
task :generate => [:lexer, :parser]

desc "Generate Parser"
task :parser do
    `racc lib/pe_puppetdbquery/grammar.racc -o lib/pe_puppetdbquery/parser.rb --superclass='PePuppetDBQuery::Lexer'`
end

desc "Generate Lexer"
task :lexer do
    `rex lib/pe_puppetdbquery/lexer.rex -o lib/pe_puppetdbquery/lexer.rb`
end
