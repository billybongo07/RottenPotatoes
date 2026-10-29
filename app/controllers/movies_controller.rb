class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  def index
    @all_ratings = Movie.all_ratings

    # Convert ratings to a plain Hash so the view can use it safely
    if params[:ratings].present?
      @ratings = params[:ratings].permit!.to_h
    else
      @ratings = Hash[@all_ratings.product(["1"])]
    end

    # Remember choices in the session
    session[:sort] = params[:sort] if params[:sort].present?
    session[:ratings] = @ratings

    @sort = params[:sort] || session[:sort] || "title"

    ratings_to_show = @ratings.keys.presence || @all_ratings
    @movies = Movie.where(rating: ratings_to_show).order(@sort)
  end

  def show
  end

  def new
    @movie = Movie.new
  end

  def edit
  end

  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @movie.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @movie.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, notice: "Movie was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_movie
      @movie = Movie.find(params.expect(:id))
    end

    def movie_params
      params.expect(movie: [ :title, :rating, :description, :release_date ])
    end
end