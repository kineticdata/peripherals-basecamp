require 'net/http'
require "net/https"
require "uri"
require 'json'

module Basecamp
  VERSION = 0.1
  class Wrapper
    
    def initialize(username, password, userid)
      @username = username
      @password = password
      @userid = userid
    end
    
    
    def make_request(type, request, data = nil)
      # Build request uri
      uri = URI.parse("https://basecamp.com/#{@userid}/api/v1/#{request}")
      http = Net::HTTP.new(uri.host,uri.port)
      
      if type == "GET"
        req = Net::HTTP::Get.new(uri.path)
      elsif type=="DELETE"
        req = Net::HTTP::Delete.new(uri.path)
      elsif type == "POST"
        req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json'})
        req.body = data
      elsif type=="PUT"
        req = Net::HTTP::Put.new(uri.path, initheader = {'Content-Type' => 'application/json'})
        req.body = data
      else
        raise "Bad type given to the make request."
      end
      
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
      req.basic_auth @username, @password
      req.add_field('User-Agent','Kinetic Task (http://www.kineticdata.com')
      response = http.request(req)
      return response.body
    end
    
    # Projects
    # ----------------------------------------------------------------------
    def get_projects
      make_request("GET","projects.json")
    end
    
    def get_archived_projects
      make_request("GET","projects/archived.json")
    end
    
    def get_project(project_id)
      make_request("GET","projects/#{project_id}.json")
    end
    
    def get_archived_project(project_id)
      make_request("GET","projects/archived/#{project_id}.json")
    end
    
    def create_project(name,description)
      form_data = {"name"=>name,"description"=>description}.to_json
      make_request("POST",'projects.json',form_data)
    end
    
    def update_project(project_id,name,description)
      form_data = {"name"=>name, "description"=>description}.to_json
      make_request("PUT","projects/#{project_id}.json",form_data)
    end
    
    def archive_project(project_id)
      form_data = {"archived" => true}.to_json
      make_request("PUT","projects/#{project_id}.json",form_data)
    end
    
    def activate_project(project_id)
      form_data = {"archived" => false}.to_json
      make_request("PUT","projects/#{project_id}.json",form_data)
    end
    
    def delete_project(project_id)
      make_request("DELETE","projects/#{project_id}.json")
    end
    
    
    # People
    # ----------------------------------------------------------------------
    
    def get_people
      make_request("GET","people.json")
    end
    
    def get_person(person_id)
      make_request("GET","people/#{person_id}.json")
    end
    
    def get_me
      make_request("GET","people/me.json")
    end
    
    def delete_person(person_id)
      make_request("DELETE","people/#{person_id}.json")
    end
    
    
    # Accesses
    # ----------------------------------------------------------------------
    def get_project_accesses(project_id)
      make_request("GET", "projects/#{project_id}/accesses.json")
    end
    
    def get_calendar_accesses(calendar_id)
      make_request("GET", "projects/#{calendar_id}/accesses.json")
    end
    
    def grant_project_access(project_id,ids,emails)
      form_data = {"ids"=>ids,"email_addresses"=>emails}.to_json
      make_request("POST","projects/#{project_id}/accesses.json",form_data)
    end
    
    def grant_calendar_access(calendar_id, ids, emails)
      form_data = {"ids"=>ids,"email_addresses"=>emails}.to_json
      make_request("POST","calendars/#{calendar_id}/accesses.json",form_data)
    end
    
    def revoke_project_access(project_id,user_id)
      make_request("DELETE","projects/#{project_id}/accesses/#{user_id}.json")
    end
    
    def revoke_calendar_access(calendar_id, user_id)
      make_request("DELETE","calendars/#{calendar_id}/accesses/#{user_id}.json")
    end
    
    
    # Events
    # ----------------------------------------------------------------------
    
    def get_global_events(since)
      make_request("GET", "events.json?since=#{since}")
    end
    
    def get_project_events(project_id, since)
      make_request("GET", "projects/#{project_id}/events.json?since=#{since}")
    end
    
    def get_person_events(person_id, since)
      make_request("GET", "people/#{person_id}/events.json?since=#{since}")
    end
    
    
    # Topics
    # ----------------------------------------------------------------------
    
    def get_topics(project_id)
      make_request("GET","projects/#{project_id}/topics.json")
    end
    
    def get_all_topics
      make_request("GET","topics.json")
    end
    
    # Messages
    # ----------------------------------------------------------------------
    
    def get_message(project_id, message_id)
      make_request("GET","projects/#{project_id}/messages/#{message_id}.json")
    end
    
    def create_message(project_id, subject, content, subscriber_ids = [])
      form_data = {"subject"=>subject, "content" => content, "subscribers" => subscriber_ids}.to_json
      make_request("POST","projects/#{project_id}/messages.json",form_data)
    end
    
    def update_message(project_id, message_id, new_subject, new_content)
      form_data = {"subject" => new_subject, "content" => new_content}.to_json
      make_request("PUT","projects/#{project_id}/messages/#{message_id}.json", form_data)
    end
    
    def delete_message(project_id, message_id)
      make_request("DELETE", "projects/#{project_id}/messages/#{message_id}.json")
    end
    
    # Comments
    # ----------------------------------------------------------------------
    
    def create_comment(project_id, section, section_id, content, subscribers = [])
      form_data = {"content" => content, "subscribers" => subscribers}.to_json
      make_request("POST","projects/#{project_id}/#{section}/#{section_id}/comments.json", form_data)
    end
    
    def delete_comment(project_id, comment_id)
      make_request("DELETE", "projects/#{project_id}/messages/#{message_id}.json")
    end
    
    # Todo Lists
    # ----------------------------------------------------------------------
    
    def get_project_active_todolists(project_id)
      make_request("GET", "projects/#{project_id}/todolists.json")
    end
    
    def get_project_completed_todolists(project_id)
      make_request("GET", "projects/#{project_id}/todolists/completed.json")
    end
    
    def get_active_todolists
      make_request("GET", "todolists.json")
    end
    
    def get_completed_todolists
      make_request("GET", "todolists/completed.json")
    end
    
    def get_assigned_todolists(person_id)
      make_request("GET", "people/#{person_id}/assigned_todos.json")
    end
    
    def get_todolist(project_id, todolist_id)
      make_request("GET", "projects/#{project_id}/todolists/#{todolist_id}.json")
    end
    
    def create_todolist(project_id, name, description)
      form_data = {"name"=>name, "description"=>description}.to_json
      make_request("POST", "projects/#{project_id}/todolists.json", form_data)
    end
    
    def update_todolist(project_id, todolist_id, name, description)
      form_data = {"name"=>name, "description"=>description}.to_json
      make_request("PUT", "projects/#{project_id}/todolists/#{todolist_id}.json", form_data)
    end
    
    def reorder_todolist(project_id, todolist_id, position)
      form_data = {"position" => position}.to_json
      make_request("PUT", "projects/#{project_id}/todolists/#{todolist_id}.json", form_data)
    end
    
    def delete_todolist(project_id, todolist_id)
      make_request("DELETE", "projects/#{project_id}/todolists/#{todolist_id}.json")
    end
    
    # Todos
    # ----------------------------------------------------------------------
    
    def get_todo(project_id, todo_id)
      make_request("GET", "projects/#{project_id}/todos/#{todo_id}.json")
    end
    
    def create_todo(project_id, todolist_id, content, due_at=nil)
      form_data = {"content" => content, "due_at"=>due_at}.to_json
      make_request("POST", "projects/#{project_id}/todolists/#{todolist_id}/todos.json", form_data)
    end
    
    def update_todo(project_id, todo_id, content, due_at=nil, completed=false)
      form_data = {"content" => content, "due_at"=>due_at, "completed"=>completed}.to_json
      make_request("PUT", "projects/#{project_id}/todos/#{todo_id}.json", form_data)
    end
    
    def todo_set_position(project_id, todo_id, position)
      form_data = {"position" => position}.to_json
      make_request("PUT", "projects/#{project_id}/todos/#{todo_id}.json", form_data)
    end
    
    def delete_todo(project_id, todo_id)
      make_request("DELETE", "projects/#{project_id}/todos/#{todo_id}.json")
    end
    # Documents
    # ----------------------------------------------------------------------
    
    def get_project_documents(project_id)
      make_request("GET", "projects/#{project_id}/documents.json")
    end
    
    def get_documents
      make_request("GET", "documents.json")
    end
    
    def get_document(project_id, document_id)
      make_request("GET", "projects/#{project_id}/documents/#{document_id}.json")
    end
    
    def create_document(project_id, title, content)
      form_data = {"title"=>title, "content"=>content}.to_json
      make_request("POST", "projects/#{project_id}/documents.json", form_data)
    end
    
    def update_document(project_id, document_id, title, content)
      form_data = {"title"=>title, "content"=>content}.to_json
      make_request("PUT", "projects/#{project_id}/documents/#{document_id}.json",form_data)
    end
    
    def delete_document(project_id, document_id)
      make_request("DELETE", "projects/#{project_id}/documents/#{document_id}.json")
    end
    
    # Attatchments
    # ----------------------------------------------------------------------
    # Uploads
    # ----------------------------------------------------------------------
    # Calendars
    # ----------------------------------------------------------------------
    
    def get_calendars
      make_request("GET", "calendars.json")
    end
    
    def get_calendar(calendar_id)
      make_request("GET", "calendars/#{calendar_id}.json")
    end
    
    def create_calendar(name)
      form_data = {"name"=>name}.to_json
      make_request("POST", "calendars.json", form_data)
    end
    
    def update_calendar(calendar_id, name)
      form_data = {"name"=>name}.to_json
      make_request("PUT", "calendars/#{calendar_id}.json", form_data)
    end
    
    def delete_calendar(calendar_id)
      make_request("DELETE", "calendars/#{calendar_id}.json")
    end
    
    # Calendar Events
    # ----------------------------------------------------------------------
    
    def get_upcoming_project_events(project_id)
      make_request("GET", "projects/#{project_id}/calendar_events.json")
    end
    
    def get_upcoming_calendar_events(calendar_id)
      make_request("GET", "calendars/#{calendar_id}/calendar_events.json")
    end
    
    def get_past_project_events(project_id)
      make_request("GET", "projects/#{project_id}/calendar_events/past.json")
    end
    
    def get_past_calendar_events(calendar_id)
      make_request("GET", "calendars/#{calendar_id}/calendar_events/past.json")
    end
    
    def get_calendar_event(calendar_id, event_id)
      make_request("GET", "calendars/#{calendar_id}/calendar_events/#{event_id}.json")
    end
    
    def get_project_event(project_id, event_id)
      make_request("GET", "projects/#{project_id}/calendar_events/#{event_id}.json")
    end
    
    def create_calendar_event(calendar_id, summary, description, all_day = false, starts_at = nil, ends_at = nil)
      form_data = {
    "summary" => summary,
    "description" => description,
    "all_day" => all_day,
    "starts_at" => starts_at,
    "ends_at" => ends_at
      }.to_json
      make_request("POST","calendars/#{calendar_id}/calendar_events.json",form_data)
    end
    
    def create_project_event(project_id, summary, description, all_day = false, starts_at = nil, ends_at = nil)
      form_data = {
    "summary" => summary,
    "description" => description,
    "all_day" => all_day,
    "starts_at" => starts_at,
    "ends_at" => ends_at
      }.to_json
      make_request("POST","projects/#{project_id}/calendar_events.json",form_data)
    end
    
    def update_calendar_event(calendar_id, summary, description, all_day = false, starts_at = nil, ends_at = nil)
      form_data = {
    "summary" => summary,
    "description" => description,
    "all_day" => all_day,
    "starts_at" => starts_at,
    "ends_at" => ends_at
      }.to_json
      make_request("PUT","calendars/#{calendar_id}/calendar_events.json",form_data)
    end
    
    def update_project_event(project_id, summary, description, all_day = false, starts_at = nil, ends_at = nil)
      form_data = {
    "summary" => summary,
    "description" => description,
    "all_day" => all_day,
    "starts_at" => starts_at,
    "ends_at" => ends_at
      }.to_json
      make_request("PUT","projects/#{project_id}/calendar_events.json",form_data)
    end
    
    def delete_calendar_event(calendar_id, event_id)
      make_request("DELETE", "calendars/#{calendar_id}/calendar_events/#{event_id}.json")
    end
    
    def delete_project_event(project_id, event_id)
      make_request("DELETE", "projects/#{project_id}/calendar_events/#{event_id}.json")
    end
    
    private :make_request
  end
end
