require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

not_found do
  redirect "/"
end

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |paragraph, index|
        "<p id=#{index+1}>#{paragraph}</p>"
    end.join
  end

  def display_paragraph(index, p_index, text)
    paragraph_arr = File.read("data/chp#{index+1}.txt").split("\n\n")
    paragraph_arr[p_index-1].gsub(text, "<strong>#{text}</strong>")
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number]
  chapter_name = @contents[number.to_i - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do

  if params[:query]
    @results = []
    @contents.each_with_index.select do |chapter, index|
      text = File.read("data/chp#{index + 1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |paragraph, p_index|
        @results << [chapter, index, p_index + 1] if paragraph.include?(params[:query])
      end
    end
  end
  erb :search
end
