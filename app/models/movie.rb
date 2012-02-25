class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end

  def self.get_directors_movies(id)
    director = Movie.find_by_id(id).director
    Movie.where(%Q{
        director = (?) and id not in (?)},
        director, [id])
  end
end
