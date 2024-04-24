#!/bin/bash /usr/bin/env ruby
# frozen_string_literal: true

require 'rake'

# this is just an expansion of Rake.application.run
# so that we can set the program name to 'do'
Rake.application.standard_exception_handling do
  Rake.application.init('do', ARGV)
  Rake.application.load_rakefile
  Rake.application.top_level
end
