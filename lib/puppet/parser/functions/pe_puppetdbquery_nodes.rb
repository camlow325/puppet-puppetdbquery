Puppet::Parser::Functions.newfunction(:pe_puppetdbquery_nodes, type: :rvalue,
    arity: -2, doc: <<-EOT

  accepts two arguments, a query used to discover nodes, and a optional
  fact that should be returned.

  The query specified should conform to the following format:
    (Type[title] and fact_name<operator>fact_value) or ...
    Package["mysql-server"] and cluster_id=my_first_cluster

  The second argument should be single fact (this argument is optional)

EOT
                                     ) do |args|
  query, fact = args

  require 'puppet/util/puppetdb'

  # This is needed if the puppetdb library isn't pluginsynced to the master
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
  begin
    require 'pe_puppetdbquery/connection'
  ensure
    $LOAD_PATH.shift
  end

  PePuppetDBQuery::Connection.check_version

  uri = URI(Puppet::Util::Puppetdb.config.server_urls.first)
  puppetdb = PePuppetDBQuery::Connection.new(uri.host, uri.port)
  parser = PePuppetDBQuery::Parser.new
  if fact
    query = parser.facts_query query, [fact]
    puppetdb.query(:facts, query).collect { |f| f['value'] }
  else
    query = parser.parse query, :nodes if query.is_a? String
    puppetdb.query(:nodes, query).collect { |n| n['certname'] }
  end
end
