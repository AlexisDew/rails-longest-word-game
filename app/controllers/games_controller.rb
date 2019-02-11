require 'open-uri'
require 'json'
require 'open-uri'
# require 'date'
class GamesController < ApplicationController
  def new
    @grid = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @attempt = params[:attempt].upcase
    @grid = params[:grid]
    @start_time = params[:start_time].to_i
    @end_time = Time.now.to_i
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60 ? 0 : attempt.size * (1 - time_taken / 60)) * 100.to_i
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, 'ok']
      else
        [0, 'not an english word']
      end
    else
      [0, 'not included']
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

end
