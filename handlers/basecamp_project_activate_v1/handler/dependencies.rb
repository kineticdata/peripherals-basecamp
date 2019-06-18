
# load dependenices



# Load the JRuby Open SSL library unless it has already been loaded.  This
# prevents multiple handlers using the same library from causing problems.
if not defined?(Jopenssl)
  # Load the Bouncy Castle library unless it has already been loaded.  This
  # prevents multiple handlers using the same library from causing problems.
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/bouncy-castle-java-1.5.0147/lib')
  $:.unshift library_path
  # Require the library
  require 'bouncy-castle-java'
  
  
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/jruby-openssl-0.8.8/lib/shared')
  $:.unshift library_path
  # Require the library
  require 'openssl'
  # Require the version constant
  require 'jopenssl/version'
end

# Validate the the loaded openssl library is the library that is expected for
# this handler to execute properly.
if not defined?(Jopenssl::Version::VERSION)
  raise "The Jopenssl class does not define the expected VERSION constant."
elsif Jopenssl::Version::VERSION != '0.8.8'
  raise "Incompatible library version #{Jopenssl::Version::VERSION} for Jopenssl.  Expecting version 0.8.8"
end




# Load the ruby JSON library (used by the Octokit library) unless 
# it has already been loaded.  This prevents multiple handlers using the same 
# library from causing problems.
if not defined?(JSON)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/json-1.8.0/lib')
  $:.unshift library_path
  # Require the library
  require 'json'
end

# Validate the the loaded JSON library is the library that is expected for
# this handler to execute properly.
if not defined?(JSON::VERSION)
  raise "The JSON class does not define the expected VERSION constant."
elsif JSON::VERSION.to_s != '1.8.0'
  raise "Incompatible library version #{JSON::VERSION} for JSON.  Expecting version 1.8.0."
end



# Load the ruby Basecamp Wrapper unless it has already been loaded.  This prevents
# multiple handlers using the same library from causing problems.
if not defined?(Basecamp::Wrapper)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/basecamp_wrapper')
  $:.unshift library_path
  # Require the library
  require 'basecamp_wrapper'
end

# Validate the the loaded JSON library is the library that is expected for
# this handler to execute properly.
if not defined?(Basecamp::VERSION)
  raise "The Basecamp Wrapper does not define the expected VERSION constant."
elsif Basecamp::VERSION.to_s != '0.1'
  raise "Incompatible library version #{Basecamp::VERSION} for Basecamp Wrapper.  Expecting version 0.1."
end
