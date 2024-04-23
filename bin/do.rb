#!/usr/bin/env ruby
# frozen_string_literal: true


require 'clamp'
require 'json_schemer'
require 'yaml'
require 'json'
require 'erb'

ROOT=File.realpath(File.dirname(File.dirname(__FILE__)))

class InstCmd < Clamp::Command
  subcommand "check", "Check the validity of the instruction database" do

    def execute
      schema = File.read("#{ROOT}/insts/inst_schema.json")
      unless JSONSchemer.schema(schema)
        raise "Invalid JSON schema for instructions: #{JSONSchemer.schema(schema).validate_schema.to_a}"
      end
  
      validator = JSONSchemer.schema(schema)
      Dir.glob("#{ROOT}/insts/*.yaml") do |f|
        data = YAML.load(File.read(f))
        unless validator.valid?(data)
          raise "In file #{f}:\n  Invalid format\n  #{validator.validate(data).to_a[0]['error']}"
        end
      end
    end
  end

  subcommand 'schema_doc', 'Generate documentation for the schema' do
    def execute
      s = JSON.load(File.read("#{ROOT}/insts/inst_schema.json"))
      
      t = ERB.new(<<~TEMPLATE, trim_mode: '-'
        = <%= title %>
        
        <%= description %>

        == Properties

        [cols="1,2,2"]
        |===
        | Name | Description | Attributes

        <% items['properties'].each do |name, attr| %>
        a| `<%= name %>`

        | <%= attr['description'] %>

        a|
        [horizontal]
        Type:: <%= attr['type'] %>
        <%- if attr.key?('examples') -%>
        Examples:: <%= attr['examples'].join(', ') %>
        <%- end -%>
        Required?:: <%= items['required_properties'].any?(key) %>

        <% end %>
      TEMPLATE
      )

      puts "Writing documentation to insts/inst_schema.adoc"
      File.write "#{ROOT}/insts/inst_schema.adoc", t.result(OpenStruct.new(s).instance_eval { binding })
    end
  end
end

class Main < Clamp::Command
  subcommand "inst", "Work with the instruction database", InstCmd

  def execute
  end
end

Main.run
