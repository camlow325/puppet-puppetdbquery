#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the query_nodes function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("pe_puppetdbquery_nodes").should ==
        "function_pe_puppetdbquery_nodes"
  end
end
