require 'open-uri'

class GamesController < ApplicationController
  def new
    vowels = %w[A E I O U]
    vowels_shuffled = vowels.sample(3)
    consonants = Array('A'..'Z').delete_if { |a| vowels.include?(a) }
    consonants_shuffled = consonants.sample(5)
    @grid = (vowels_shuffled + consonants_shuffled).shuffle
    @score = session[:score] || 0
  end

  def score
    @word = params[:word] || ""
    @grid = params[:grid] || ""
    if check_against_grid(@word, @grid) == false
      @result = "Sorry #{@word} cannot be built from #{@grid}. Your score has been reset to 0."
      @score = 0
      session[:score] = 0
    elsif check_validity(@word) == false
      @result = "Sorry but #{@word} does not seem to be a valid Enlgish word - your score has been reset to 0."
      @score = 0
      session[:score] = 0
    else
      @result = "Congratulations, #{@word} is a valid English word"
      if session[:score].nil?
        @score = @word.length
        session[:score] = @score
      else
        @score = session[:score] += @word.length
      end
    end
  end

  def check_against_grid(attempt, grid)
    attempt_array = attempt.downcase.chars
    grid_array = grid.split(" ")
    grid_array = grid_array.map { |letter| letter.downcase! }
    !attempt_array.find { |x| attempt_array.count(x) > grid_array.count(x) }
  end

  def check_validity(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    user_serialized = URI.open(url).read
    JSON.parse(user_serialized)['found']
  end
end
