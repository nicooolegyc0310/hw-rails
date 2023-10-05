class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    if params[:sort_by]
      @order_criteria = params[:sort_by]
    elsif session[:sort_by]
      @order_criteria = session[:sort_by]
    else
      @order_criteria = 'title'
    end

    if params[:ratings]
      @ratings_to_show = params[:ratings]
    elsif session[:ratings]
      @ratings_to_show = session[:ratings]
      redirect_to movies_path(ratings: session[:ratings], sort_by: @order_criteria) and return
    else
      @ratings_to_show = @all_ratings.each_with_object({}) { |i, hash| hash[i] = "1" }
    end

    @movies = Movie.with_ratings(@ratings_to_show.keys).order(@order_criteria)

    session[:ratings] = @ratings_to_show
    session[:sort_by] = @order_criteria

    if @order_criteria == 'title'
      @sort_title = 'bg-warning hilite'
    end
                               
    if @order_criteria == 'release_date'
      @sort_date = 'bg-warning hilite'
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
