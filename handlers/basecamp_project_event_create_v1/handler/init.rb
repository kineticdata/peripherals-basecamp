require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class BasecampProjectEventCreateV1
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
    summary = @parameters['summary']
    description = @parameters['description']
    starts_at = @parameters['starts_at']
    ends_at = @parameters['ends_at']
    

    # Create wrapper object
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
    project_check = projects.select { |p| p['name'] == project_name }
    
    # There must be an active project with the given project_name.
    # There cannot be more than on active project with the given project_name.
    if project_check.length < 1
      raise "There is no active project with the name, #{project_name}."
    end
    if project_check.length > 1
      raise "There is more than one project with the name, #{project_name}."
    end

    # Get single project
    project = project_check[0]

    # Clean dates
    dates = clean_dates(starts_at, ends_at)
    start_time = dates['start_time']
    end_time = dates['end_time']

    # Forcing all day events
    all_day = true

    event = wrap.create_project_event(project['id'], summary, description, all_day, start_time, end_time)

    <<-RESULTS
    <results/>
    RESULTS
  end

  # Date Dealer
  #   This method prepares the date for the basecamp wrapper. If the time is not
  # given, this method will be sure that Basecamp marks the dates without times.
  def clean_dates(starts_at, ends_at)
    local = DateTime.now


    if not check_date_format(starts_at)
      raise "Invalid date format, must be YYYY-MM-DD"
    end
    # If the end date is empty (or does not match format), set it to the same as the start date.
    if not check_date_format(ends_at)
      ends_at = starts_at.to_s
    end

    start_time = DateTime.parse(starts_at)
    end_time = DateTime.parse(ends_at)
    
    start_string = start_time.to_s
    end_string = end_time.to_s

    start_string.slice!(/((\+|\-)\d\d:\d\d$)/)
    end_string.slice!(/((\+|\-)\d\d:\d\d$)/)
    
    start_time = DateTime.parse("#{start_string} #{local.zone}")
    end_time = DateTime.parse("#{end_string} #{local.zone}")

    return {"start_time" => start_time.to_s, "end_time"=>end_time.to_s}
  end

  def check_date_format(date)
    check = date =~ /^\s*(\d{4}-\d{2}-\d{2})\s*${1}/
    check != nil
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
