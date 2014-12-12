module ProceduresController
  
  proc_route_data = ["#{PROCEDURES_PATH}/:proc_name.?:format?", PROVIDES_ARRAY]
  
  before proc_route_data[0] do
    halt 404 unless params[:proc_name][VALID_SQL_NAME_REGEXP] == params[:proc_name]
  end
  
  get *proc_route_data do
    params_list = HashToSql::get_proc_params_from_object(params[:p])
    generate_output(params_list)
  end
  
  post *proc_route_data do
    params_list = get_proc_params_from_body
    generate_output(params_list)
  end
  
  put *proc_route_data do
    params_list = get_proc_params_from_body
    generate_output(params_list)
  end
  
  delete *proc_route_data do
    params_list = HashToSql::get_proc_params_from_object(params[:p])
    ActiveRecord::Base.connection.execute("call #{params[:proc_name]}(#{params_list.join(', ')})")
    content_type request.accept.first
    nil
  end
  
  private
  def get_proc_params_from_body
    body_data = get_body_data_from_request
    
    HashToSql::get_proc_params_from_object(body_data["p"])
  end
  
  def generate_output(params_list)
    raw_data = ActiveRecord::Base.connection.execute("call #{params[:proc_name]}(#{params_list.join(', ')})")
    data, type_str = generate_acceptable_output(raw_data)
    content_type(type_str)
    data
  end
end