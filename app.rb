# frozen_string_literal: true

require 'cgi'
require 'json'
require 'pg'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'
require 'rack/flash'
require 'uri'

enable :sessions
use Rack::Flash, sweep: true

DATABASE = PG::Connection.open(dbname: 'memo_app')

ERROR_MESSAGE = '※空欄では保存出来ません。テキストを挿入してください。'

# データベース, エスケープ, バリデーション
def execute(query, params = nil, delete: false)
  delete ? DATABASE.exec(query) : DATABASE.exec_params(query, params)
end

def find_all
  DATABASE.exec_params('SELECT * FROM memos ORDER BY id').values
end

def find(id)
  DATABASE.exec_params("SELECT * FROM memos WHERE id = #{id}")[0]
end

def create(params)
  query = 'INSERT INTO memos (title, description) VALUES ($1, $2)'
  execute(query, params)
end

def update(id, params)
  query = "UPDATE memos SET title = $1, description = $2 WHERE id = #{id}"
  execute(query, params)
end

def delete(id)
  query = "DELETE FROM memos WHERE id = #{id};"
  execute(query, delete: true)
end

def to_escape(params)
  params.map { |value| CGI.escapeHTML(value) }
end

def validate_blank?(params)
  params['title'].strip.empty? || params['description'].strip.empty?
end

# ルーティング

# home
get '/' do
  @records = find_all
  erb :index
end

# new/create
get '/memo' do
  erb :new
end

post '/memo' do
  if validate_blank?(params)
    flash[:error_message] = ERROR_MESSAGE
    erb :new
  else
    escaped_params = to_escape([params[:title], params[:description]])
    create(escaped_params)
    redirect '/'
    erb :index
  end
end

# show
get '/memo/:id' do |id|
  @record = find(id)
  erb :show
end

# edit/update
get '/memo/:id/edit' do |id|
  @record = find(id)
  erb :edit
end

patch '/memo/:id' do |id|
  if validate_blank?(params)
    flash[:error_message] = ERROR_MESSAGE
    encoded_params = URI.encode_www_form({ 'title' => params['title'], 'description' => params['description'] })
    redirect to("/memo/#{id}/edit?#{encoded_params}")
    erb :edit
  else
    escaped_params = to_escape([params[:title], params[:description]])
    update(id, escaped_params)
    redirect '/'
    erb :index
  end
end

# delete
delete '/memo/:id' do |id|
  delete(id)
  flash[:delete_message] = 'memoを削除しました。'
  redirect '/'
  erb :index
end
