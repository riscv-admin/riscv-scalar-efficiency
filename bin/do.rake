# frozen_string_literal: true

require 'json_schemer'
require 'yaml'
require 'json'
require 'erb'

ROOT = File.realpath(File.dirname(File.dirname(__FILE__)))

namespace :inst do
  desc 'Check the validity of the instruction database'
  task :check do
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

    puts 'Instruction database OK'
  end

  namespace :render do

    desc 'Generate documentation for the instruction schema'
    task :schema_doc do
      s = JSON.parse(File.read("#{ROOT}/insts/inst_schema.json"))

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

      puts 'Writing documentation to insts/inst_schema.adoc'
      File.write "#{ROOT}/insts/inst_schema.adoc", t.result(OpenStruct.new(s).instance_eval { binding })
    end

    desc 'Generate Asciidoc table view of instruction database'
    task :adoc do
      insts = Dir.glob("#{ROOT}/insts/*.yaml").map { |f| YAML.load(File.read(f)) }.flatten

      schema = JSON.parse(File.read("#{ROOT}/insts/inst_schema.json"))
      fields = schema['items']['properties'].keys

      t = ERB.new(<<~TEMPLATE, trim_mode: '-'
        = Instruction database

        |===
        | <%= fields.join(' | ') %>

        <%- insts.each do |inst| -%>
        | <%= fields.map { |f| inst[f].to_s.gsub('|', '\') }.join(' | ') %>
        <%- end -%>
        |===
      TEMPLATE
      )

      puts 'Writing table to insts/inst_table.adoc'
      File.write "#{ROOT}/insts/inst_table.adoc", t.result(binding)
    end
  end
end
