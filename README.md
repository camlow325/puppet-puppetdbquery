Pe PuppetDB query tools
=======================

This module implements command line tools and Puppet functions that can be used to query puppetdb.
There's also a hiera backend that can be used to return query results from puppetdb.

Requirements
============

PuppetDB terminus is required for the Puppet functions, but not for the face.

Required PuppetDB version
-------------------------

This module uses the V4 API, and as such it requires at least PuppetDB 3.0.0.
If you are using PuppetDB 2.x please use the 1.x version of this module instead.

Query syntax
============

Use `fact=value` to search for nodes where `fact` equals `value`. To search for
structured facts use dots between each part of the fact path, for example
`foo.bar=baz`.

Resources can be matched using the syntax `type[title]{param=value}`.
The part in brackets is optional. You can also specify `~` before the `title`
to do a regexp match on the title. Type names and class names are case insensitive.
A resource can be preceded by @@ to match exported resources, the default is to only
match "local" resources.

Strings can contain letters, numbers or the characters :-_ without needing to be quoted.
If they contain any other characters they need to be quoted with single or double quotes.
Use backslash (\) to escape quotes within a quoted string or double backslash for backslashes.

An unquoted number or the strings true/false will be interpreted as numbers and boolean
values, use quotation marks around them to search for them as strings instead.

A @ sign before a string causes it to be interpreted as a date parsed with
[chronic](https://github.com/mojombo/chronic). For example `@"2 hours ago"`.
Note that date parsing is not currently supported, to avoid having `chronic`
be installed.

A # sign can be used to do a subquery, against the nodes endpoint for example to
query the `report_timestamp`, `catalog_timestamp` or `facts_timestamp` fields.
For example `#node.report_timestamp < @"2 hours ago"`.

A subquery using the # sign can have a block of expressions instead of a single
expression. For example `#node { report_timestamp > @"4 hours ago" and
report_timestamp < @"2 hours ago" }`

A bare string without comparison operator will be treated as a regexp match against the certname.

#### Comparison operators

| Op | Meaning                |
|----|------------------------|
| =  | Equality               |
| != | Not equal              |
| ~  | Regexp match           |
| !~ | Not equal Regexp match |
| <  | Less than              |
| =< | Less than or equal     |
| >  | Greater than           |
| => | Greater than or equal  |

#### Logical operators

| Op  |            |
|-----|------------|
| not | (unary op) |
| and |            |
| or  |            |

Shown in precedence order from highest to lowest. Use parenthesis to change order in an expression.

### Query Examples

Nodes with package mysql-server and amd64 architecture

    (package["mysql-server"] and architecture=amd64)

Nodes with the class Postgresql::Server and a version set to 9.3

    class[postgresql::server]{version=9.3}

Nodes with 4 or 8 processors running Linux

    (processorcount=4 or processorcount=8) and kernel=Linux

Nodes that haven't reported in the last 2 hours

    #node.report_timestamp<@"2 hours ago"

Puppet functions
----------------

There's corresponding functions to query PuppetDB directly from Puppet manifests.
All the functions accept either the simplified query language or raw PuppetDB API queries.

### pe_puppetdbquery_nodes

Accepts two arguments, a query used to discover nodes, and a optional
fact that should be returned.

Returns an array of certnames or fact values if a fact is specified.

#### Examples

    $hosts = pe_puppetdbquery_nodes('manufacturer~"Dell.*" and processorcount=24 and Class[Apache]')

    $hostips = pe_puppetdbquery_nodes('manufacturer~"Dell.*" and processorcount=24 and Class[Apache]', ipaddress)

### pe_puppetdbquery_resources

Accepts two arguments or three argument, a query used to discover nodes, and a resource query
, and an optional a boolean to whether or not to group the result per host.


Return either a hash (by default) that maps the name of the nodes to a list of
resource entries.  This is a list because there's no single
reliable key for resource operations that's of any use to the end user.

#### Examples

Returns the parameters and such for the ntp class for all CentOS nodes:

    $resources = pe_puppetdbquery_resources('Class["apache"]{ port = 443 }', 'User["apache"]')

Returns the parameters for the apache class for all nodes in a flat array:

    pe_puppetdbquery_resources(false, 'Class["apache"]', false)

### pe_puppetdbquery_facts

Similar to pe_puppetdbquery_nodes but takes two arguments, the first is a query used to discover nodes, the second is a list of facts to return for those nodes.

Returns a nested hash where the keys are the certnames of the nodes, each containing a hash with facts and fact values.

#### Example

    pe_puppetdbquery_facts('Class[Apache]{port=443}', ['osfamily', 'ipaddress'])

Example return value in JSON format:

    {
      "foo.example.com": {
        "ipaddress": "192.168.0.2",
        "osfamily": "Redhat"
      },
      "bar.example.com": {
        "ipaddress": "192.168.0.3",
        "osfamily": "Debian"
      }
    }
