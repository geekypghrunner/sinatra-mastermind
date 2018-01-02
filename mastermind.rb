require 'sinatra'
require 'sinatra/reloader' if development?

configure do
  enable :sessions
  set :session_secret, "secret"
end



get '/' do
  session[:attempt_count] ||= 12
  session[:code] ||= code_generator()
  input = params['input']
  guess(input)
  messages(input)
  erb :index, :locals => {:message => @message, :location => @location, :contains => @contains, :correct_answers => @correct_answers, :contain_number => @contain_number, :error => @error}
end

post '/' do
  session[:attempt_count] = 12
  session[:code] = code_generator()
  input = params['input']
  guess(input)
  messages(input)
  erb :index, :locals => {:message => @message, :location => @location, :contains => @contains, :correct_answers => @correct_answers, :contain_number => @contain_number, :error => @error}
end

def code_generator
  secret_code = ""
  new_number = Random.new
  4.times do |number|
    secret_code += (new_number.rand(0..9)).to_s
  end
  return secret_code
end

def guess(input)
  if params['input'] == session[:code]
  elsif session[:attempt_count] == 0
  else
    if /^\d{4}$/ =~ input
    @location = "The following digits are in the correct location:"
    @contains = "The following digits are in the code but were not located in the correct position:"
      @correct_answers = ""
      @contain_number = ""
      @user_guess = input
      @user_guess.split("").each_with_index { |number, index|
        if number == session[:code].split("")[index]
          @correct_answers += "#{number}"
        end
      }
      @user_guess.split("").each_with_index { |number, index|
        if number == session[:code].split("")[index]
          next
        elsif session[:code].split("").include?(number)
          @contain_number += "#{number}"
        end
        }
      session[:attempt_count] -= 1
    end
  end
end

def messages(input)
  if input.nil?
    @message = "Codebreaker mode initiated.<p></p>The computer has generated a code for your to guess.<p></p>Please enter the four digits (0-9) you believe are in the code.<p></p>Number of attempts remaining: #{session[:attempt_count]}."
  elsif params['input'] == session[:code]
    @message = "You won!"
    @location = ""
    @contains = ""
    @correct_answers = ""
    @contain_number = ""
  elsif session[:attempt_count] == 0
    @message = "You are out of turns.  The correct answer was #{session[:code]}."
    @location = ""
    @contains = ""
    @correct_answers = ""
    @contain_number = ""
  elsif /^\d{4}$/ =~ input
    @message = "Please enter the four digits (0-9) you believe are in the code.<p></p>Number of attempts remaining: #{session[:attempt_count]}."
  else
    @message = "Invalid code entry.  Please enter the four digits (0-9) you believe are in the code.<p></p>Number of attempts remaining: #{session[:attempt_count]}."
  end
end