require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class BasecampProjectUserRemoveV1
  def initialize(input)
    # Set the input document attribute
    @input_document = REXML::Document.new(input)
    
    # Store the info values in a Hash of info names to values.
    @info_values = {}
    REXML::XPath.each(@input_document,"/handler/infos/info") { |item|
      @info_values[item.attributes['name']] = item.text  
    }
    
    # Retrieve all of the handler parameters and store them in a hash attribute
    # named @parameters.
    @parameters = {}
    REXML::XPath.match(@input_document, 'handler/parameters/parameter').each do |node|
      @parameters[node.attribute('name').value] = node.text.to_s
    end
  end
  
  def execute()
    username = @info_values['username']
    password = @info_values['password']
    user_id = @info_values['user_id']
    
    project_name = @parameters['project_name']
    user_email = @parameters['user_email']
    
    wrap = Basecamp::Wrapper.new username,password,user_id
    
    # Check to see if logged in correctly.
    me = wrap.get_me
    if me[/Access denied/]
      raise "Login failed. Check login information."
    end
    # Check user id
    if me[/You may have typed the URL incorrectly./]
      raise "Your user id may be incorrect."
    end
    
    # Find the correct project by name
    projects = JSON.parse(wrap.get_projects)
    check = projects.select {|p| p['name'].to_s == project_name}
    
    # Raise exception if no existing project.
    if check.length > 1
      puts "There is more than one project with the name, #{project_name}."
    elsif check.length < 1
      puts "There is no project with the name, #{project_name}."
    end
    
    project = check[0]
    user_email.split(/\s*,\s*/).each do | email |
      # Find the correct user within the project by email
      users = JSON.parse(wrap.get_project_accesses(project['id']))
      user_check = users.select {|u| u['email_address'].to_s == email}
      
      # Raise exception if no existing user.
      if user_check.length < 1
        raise "There was no user in this project with provided email, #{email}."
      elsif user_check.length > 1
        raise "There is more than one user with the provided email, #{email}."
      else
        user = user_check[0]
        # Revoke access using the two ids
        wrap.revoke_project_access(project['id'],user['id'])
      end
    end
    
    <<-RESULTS
    <results/>
    RESULTS
  end
  
  # This is a template method that is used to escape results values (returned in
  # execute) that would cause the XML to be invalid.  This method is not
  # necessary if values do not contain character that have special meaning in
  # XML (&, ", <, and >), however it is a good practice to use it for all return
  # variable results in case the value could include one of those characters in
  # the future.  This method can be copied and reused between handlers.
  def escape(string)
    # Globally replace characters based on the ESCAPE_CHARACTERS constant
    string.to_s.gsub(/[&"><]/) { |special| ESCAPE_CHARACTERS[special] } if string
  end
  # This is a ruby constant that is used by the escape method
  ESCAPE_CHARACTERS = {'&'=>'&amp;', '>'=>'&gt;', '<'=>'&lt;', '"' => '&quot;'}
end
