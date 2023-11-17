## アプリケーションの動かし方

1. コードをクローンする。
```ruby
$ git clone git@github.com:appsu-mi/Sinatra_memo_app.git
```
2. ディレクトリへ移動する。
```ruby
$ cd Sinatra_memo_app/
```
3. PRをfetchする。
```ruby
$ git fetch origin pull/1/head:my-memo
```
4. ブランチをチェックアウトする。
```ruby
$ git checkout my-memo
```
5. アプリを起動する。
```ruby
$ bundle exec ruby app.rb
```
