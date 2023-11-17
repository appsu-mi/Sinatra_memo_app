# frozen_string_literal: true

require 'cgi'
require 'json'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'
require 'rack/flash'
require 'uri'

enable :sessions
use Rack::Flash, sweep: true

ERROR_MESSAGE = '※空欄では保存出来ません。テキストを挿入してください。'

# データベース, エスケープ, バリデーション

def find_all_record
  File.exist?('datas.json') ? File.open('datas.json', 'r') { |f| JSON.parse(f.read, symbolize_names: true) } : nil
end

def save_overwrite(collected_records)
  File.open('datas.json', 'w') { |f| f.write(collected_records) }
end

def create(params)
  record_id = SecureRandom.uuid
  new_record = to_escape(params)
  collected_records = find_all_record&.merge({ record_id => new_record }) || { record_id => new_record }
  save_overwrite(JSON.pretty_generate(collected_records))
end

def update(new_record, params_id)
  collected_records = find_all_record.each { |record_id, record| record.replace(new_record) if record_id == params_id }
  save_overwrite(JSON.pretty_generate(collected_records))
end

def delete(params_id)
  collected_records = find_all_record.delete_if { |record_id| record_id == params_id }
  save_overwrite(JSON.pretty_generate(collected_records))
end

def to_escape(params)
  params.transform_values { |value| CGI.escapeHTML(value) }
end

def validate_blank?(params)
  params['title'].strip.empty? || params['description'].strip.empty?
end

# ルーティング

get '/' do
  @all_record = find_all_record
  erb :index
end

get '/memo' do
  erb :new
end

post '/memo' do
  if validate_blank?(params)
    flash[:error_message] = ERROR_MESSAGE
    erb :new
  else
    create(params)
    redirect '/'
    erb :index
  end
end

get '/memo/:id' do |id|
  @record_id = id
  @record = find_all_record[@record_id.to_sym]
  erb :show
end

get '/memo/:id/edit' do |id|
  @record_id = id
  @record = find_all_record[@record_id.to_sym]
  erb :edit
end

patch '/memo/:id' do |id|
  if validate_blank?(params)
    flash[:error_message] = ERROR_MESSAGE
    encoded_params = URI.encode_www_form({ 'title' => params['title'], 'description' => params['description'] })
    redirect to("/memo/#{id}/edit?#{encoded_params}")
    erb :edit
  else
    new_record = to_escape({ title: params['title'], description: params['description'] })
    update(new_record, id.to_sym)

    redirect '/'
    erb :index
  end
end

delete '/memo/:id' do |id|
  delete(id.to_sym)
  flash[:delete_message] = 'memoを削除しました。'

  redirect '/'
  erb :index
end
