# frozen_string_literal: true

require 'cgi'
require 'json'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'
require 'rack/flash'

enable :sessions
use Rack::Flash, sweep: true
error_message = '※空欄では保存出来ません。テキストを挿入してください。'

# データベース, エスケープ, バリデーション

def find_all_record
  exist_record? ? File.open('datas.json', 'r') { |f| JSON.parse(f.read, symbolize_names: true) } : nil
end

def exist_record?
  File.exist?('datas.json')
end

def save_overwrite(collected_records)
  File.open('datas.json', 'w') do |f|
    f.write(collected_records)
  end
end

def create(new_record, record_id)
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

get '/new' do
  erb :new
end

post '/new' do
  if validate_blank?(params)
    flash[:error_message] = error_message
    erb :new
  else
    record_id = SecureRandom.uuid
    new_record = to_escape(params)
    create(new_record, record_id)

    redirect '/'
    erb :index
  end
end

get '/show/:id' do |id|
  @record_id = id
  @record = find_all_record[@record_id.to_sym]
  erb :show
end

get '/edit/:id' do |id|
  @record_id = id
  @record = find_all_record[@record_id.to_sym]
  erb :edit
end

patch '/edit/:id' do |id|
  if validate_blank?(params)
    flash[:error_message] = error_message
    redirect to("/edit/#{id}?title=#{params['title']}&description=#{params['description']}")
    erb :edit
  else
    new_record = to_escape({ title: params['title'], description: params['description'] })
    update(new_record, id.to_sym)

    redirect '/'
    erb :index
  end
end

delete '/delete/:id' do |id|
  delete(id.to_sym)
  flash[:delete_message] = 'memoを削除しました。'

  redirect '/'
  erb :index
end
