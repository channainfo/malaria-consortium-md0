# coding: utf-8
class PlacesController < ApplicationController

  def index
    @places = Place
    @places = @places.search_for_autocomplete params[:query] if params[:query].present?

    sort_params = sort_params(params)
    @revert = sort_params[:revert_dir]
    @places = @places.paginate :page => get_page, :per_page => PerPage, :order => "#{sort_params[:field]} #{sort_params[:dir]} "
    render :file => "/places/_places.html.erb", :layout => false if request.xhr?
    
  end

  def edit
    @place = Place.find(params[:id])
  end

  def update
    @place = Place.find(params[:id])
    if @place.update_attributes(params[:place])
      flash["notice"] = "#{@place.description} has been updated successfully"
      redirect_to places_path(:page => get_page)
    else
      render 'edit'
    end
  end

  def confirm_import
    places = PlaceImporter.new(current_user.places_csv_file_name).import
    flash["notice"] = "#{places.size} has been added successfully"
    redirect_to places_url(:page => get_page)
  end

  def import
    @title = "Upload"
  end

  def upload_csv
    current_user.write_places_csv params[:admin][:csvfile]
    @places = PlaceImporter.new(current_user.places_csv_file_name).simulate
    render(@places.blank? ? 'no_places_to_import.html' : 'upload_csv.html.erb')
  end

  def csv_template
    column_headers = PlaceImporter.column_headers.join(", ")
    send_data column_headers, :type => 'text/csv', :filename => 'places_template.csv'
  end

  def map_view
    @country = Country.first
  end

  def autocomplete
    places = Place.search_for_autocomplete params[:query]
    places = places.where(:type => params[:type]) if params[:type].present?
    places = places.order(:code).all
    suggestions = places.map! { |x| "#{x.code} #{x.name} (#{x.class.to_s.underscore.humanize})" }
    render :json => {:query => params[:query], :suggestions => suggestions}
  end

end
