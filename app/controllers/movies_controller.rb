require 'prawn'

class MoviesController < ApplicationController

  def list_movies
    if params[:format].blank?
      redirect_to :format => 'pdf' and return
    end

    movies = Movie.all

    pdf = Prawn::Document.new( margin: 36, top_margin: 72, bottom_margin: 72 )

    pdf.define_grid( rows: 3, columns: 2, gutter: 36 )
    movies.each_with_index do |movie, i|
      if i%6 == 0 && i != 0
        pdf.start_new_page
      end
      pdf.grid(i%6/2, i%2).bounding_box do
        pdf.stroke_bounds
        top    = pdf.bounds.top
        left   = pdf.bounds.left
        right  = pdf.bounds.right
        bottom = pdf.bounds.bottom
        pdf.bounding_box([left+3, top-3], width: right-left-6, height: top-bottom-6) do
          pdf.text "Movie: "+movie.title
          pdf.text "Released: "+movie.release_date.to_date.to_s
          pdf.text "Rating: "+movie.rating+"\n\n\n"
          pdf.text "Welcome to the future of six boxes on a page. you"+
          " are now manually aware that I am going to eat you up!"
        end
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
    ratings_hash = Hash[@all_ratings.collect{|r| [r,1]} ]
    @selected_ratings = params[:ratings] || session[:ratings] || ratings_hash

    if params[:sort] != session[:sort]
      session[:sort] = sort
      flash.keep
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end

    if params[:ratings] != session[:ratings] and @selected_ratings != ratings_hash
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
