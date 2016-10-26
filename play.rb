require 'json'
require 'faraday'

BASE_URL = if ENV['PLAY_ENV'] == 'test'
             'http://localhost:4000'
           else
             'https://roman-forum.herokuapp.com'
           end


user_credentials = (1..10).to_a.map { |i| { name: "test-#{Time.now.to_i}-#{i}", password: 'test123' } }


def register_user(conn, user_credential)
  conn.post do |req|
    req.url '/api/register'
    req.headers['Content-Type'] = 'application/json'
    req.body = {user: user_credential}.to_json
  end
end


def login_user(conn, user_credential)
  rsp = conn.post do |req|
    req.url '/api/login'
    req.headers['Content-Type'] = 'application/json'
    req.body = {user: user_credential}.to_json
  end

  JSON.parse(rsp.body)['jwt']
end

conn = Faraday.new(:url => BASE_URL) do |faraday|
  faraday.request  :multipart
  faraday.response :logger
  faraday.adapter  Faraday.default_adapter
end

10.times do |i|
  register_user(conn, user_credentials[i])
end


# Login users and create topic and
# 3 users create topic, each user create 10 topic

topics = []
3.times do |i|
  user = user_credentials.sample

  jwt = login_user(conn, user_credentials[i])

  # creat 10 topics
  10.times do |t_i|
    rsp = conn.post do |req|
      req.url '/api/topics'
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{jwt}"
      req.body = {
        topic: {
          title: "#{user['name']} created topic title #{t_i}",
          content: "#{user['name']} created topic content #{t_i}"
        }
      }.to_json
    end
    topics << JSON.parse(rsp.body)
  end
end

puts topics

# 8 user create posts
# for each topic, create 8 post
4.times do
  user = user_credentials.sample
  jwt = login_user(conn, user)

  # create post
  topics.each_with_index do |topic, t_i|
    8.times do |p_i|
      conn.post do |req|
        req.url "/api/#{topic['id']}/posts"
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{jwt}"
        req.body = {
          post: {
            content: "#{user['name']} created reply content #{p_i} for #{t_i}"
          }
        }.to_json
      end
    end
  end
end
