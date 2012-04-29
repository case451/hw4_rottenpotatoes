require 'prawn'

class MoviesController < ApplicationController

  def list_movies
    movies = Movie.all

    pdf = Prawn::Document.new( margin: 36, top_margin: 72, bottom_margin: 72 )
    width  = (72*8.5 - 36*3)/2
    height = (72*11 - 72*3)/3
    left   = 0
    top    = 72*9
    margin = 36

    corners = {0 => [left, top],                       1 => [left + width + margin, top],
               2 => [left, top - (height + margin)],   3 => [left + width + margin, top - (height + margin)],
               4 => [left, top - 2*(height + margin)], 5 => [left + width + margin, top - 2*(height + margin)]}

    movies.each_with_index do |movie, i|
      if i%6 == 0 && i != 0
        pdf.start_new_page
      end
      pdf.bounding_box Array.new(corners[i%6]), :width => width, :height => height do
        pdf.stroke_bounds
        #pdf.pad(5)
        pdf.text "Resident: "+movie.title
      end
    end

    send_data pdf.render, type: "application/pdf", disposition: "inline"
#, filename: "movies_"+Time.now.to_date.to_s+".pdf"
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def same_director
    @movie = Movie.find(params[:id])
    @movies = Movie.get_directors_movies(params[:id])
    if not @movies
      flash[:warning] = "'#{@movie.title}' has no director info."
      redirect_to movies_path
      nil
    end
  end

  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:order => :title}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:order => :release_date}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}

    if params[:sort] != session[:sort]
      session[:sort] = sort
      flash.keep
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end

    if params[:ratings] != session[:ratings] and @selected_ratings != {}
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      flash.keep
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.find_all_by_rating(@selected_ratings.keys, ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
