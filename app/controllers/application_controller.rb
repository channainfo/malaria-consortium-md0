class ApplicationController < ActionController::Base
  protect_from_forgery

  PerPage = 15

  #from rails2
  helper :all

  before_filter :authenticate_user!
  before_filter :set_cambodia_time_zone
  before_filter :load_path

  def get_page(param_key = :page)
    (params[param_key].presence || '1').to_i
  end

  def sort_params options
    sort = options[:sort].present? ? options[:sort]: " updated_at "
    dir = options[:dir].present? ? options[:dir]: "up"

    sort_dir = {"desc" => "up", "asc" => "down" }.select{|key, value| value == dir }
    if(dir == "up")
      revert = "down"
    else
      revert = "up"
    end
    sort_dir = sort_dir.first[0]
    {:field => sort, :dir =>sort_dir, :revert_dir => revert}
  end
    
  def load_path
    Dir["app/models/referral/constraint_type/*.rb"].each do |path|
      require_dependency path
    end
  end

  private

  def set_cambodia_time_zone
    Time.zone = "Bangkok" # Same time zone as Cambodia
  end
end
