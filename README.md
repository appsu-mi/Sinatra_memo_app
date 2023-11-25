## アプリケーションの動かし方

1. コードをクローンする。
```ruby
git clone git@github.com:appsu-mi/Sinatra_memo_app.git
```
2. ディレクトリへ移動する。
```ruby
cd Sinatra_memo_app/
```
3. PRをfetchする。
```ruby
git fetch origin pull/2/head:my-memo
```
4. ブランチをチェックアウトする。
```ruby
git checkout my-memo
```
5. Gemのインストール
```ruby
bundle install
```
6. postgresqlのインストール
```ruby
brew install postgresql
```
7. postgresの起動
```ruby
brew services start postgresql@<バージョン>
```
8.  DBの作成
```ruby
createdb memo_app
```
9. データベースへ接続
```ruby
psql -d memo_app
```
10. テーブルを作成
```ruby
create table memos (
  id serial,
  title varchar(50) not null,
  description text not null,
  primary key (id)
);
```
11. psqlを閉じる
```ruby
\q
```
12. アプリを起動する
```ruby
bundle exec ruby app.rb
```
