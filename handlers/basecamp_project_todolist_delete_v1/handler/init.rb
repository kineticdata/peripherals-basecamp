require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class BasecampProjectTodolistDeleteV1
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
    todolist_name = @parameters['todolist_name']
    
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
    
    # Get existing projects
    projects = JSON.parse(wrap.get_projects)
    
    # Search projects for project with defined name.
    check = projects.select { |p| p['name'] == project_name }
    
    # There must be exactly one project with the given project_name.
    if check.length < 1
      raise "There is no active project with the name, #{project_name}."
    end
    if check.length > 1
      raise "There is more than one project with the name, #{project_name}."
    end
    project = check[0]
    
    alists = JSON.parse(wrap.get_project_active_todolists(project['id']))
    clists = JSON.parse(wrap.get_project_completed_todolists(project['id']))
    
    check_alists = alists.select { |l| l['name'] == todolist_name }
    check_clists = clists.select { |l| l['name'] == todolist_name }
    
    # There must be exactly one active todolist
    # -or-
    # There must be exactly one completed todolist.
    if check_alists.length > 0 and check_clists.length > 0
      raise "There is a todolist with the name, #{todolist_name}, in both active and completed lists for the project, #{project_name}."
    elsif check_alists.length < 1 and check_clists.length < 1
      raise "There is no todolist with the name, #{todolist_name}."
    elsif check_alists.length == 1 and check_clists.length == 0
      list = check_alists[0]
      wrap.delete_todolist(project['id'],list['id'])
    elsif check_alists.length == 0 and check_clists.length == 1:
      list = check_clists[0]
      wrap.delete_todolist(project['id'],list['id'])
    else
      raise "Something unexpected went wrong when deleteing the todolist."
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
