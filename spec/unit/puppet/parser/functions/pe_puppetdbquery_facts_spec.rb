#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the query_facts function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("pe_puppetdbquery_facts").should ==
        "function_pe_puppetdbquery_facts"
  end
end
