require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class BasecampCalendarUpdateV1
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
    
    calendar_name = @parameters['calendar_name']
    new_calendar_name = @parameters['new_calendar_name']
    
    # Setup wrapper
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
    
    # Getting calendar by name.
    cals = JSON.parse(wrap.get_calendars)
    
    checks = cals.select { |c| c['name'] == calendar_name}
    new_checks = cals.select { |c| c['name'] == new_calendar_name}
    
    # There must be exactly 1 calendar.
    # There cannot be an existing calendar with the new_calendar_name
    if checks.length < 1 
      raise "There is no calendar with the name, #{calendar_name}."
    elsif checks.length > 1
      raise "There is more than one calendar with the name #{calendar_name}."
    elsif new_checks.length > 0
      raise "There is already a calendar with the name, #{new_calendar_name}."
    else
      calendar = checks[0]
      # Delete Calendar
      wrap.update_calendar(calendar['id'], new_calendar_name)
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
