# Roman

Roman 是一个用来管理论坛帖子 (Topic) 和回复 (Post) 的 API

# API 文档以及 Demo

API 文档在这里 http://docs.romanforum.apiary.io/#

已经上线的 Demo 系统在这里 https://roman-forum.herokuapp.com/

API 文档是交互式的，会利用真实的 Demo 系统返回结果。


# 技术选型


- Elixir/Phoenix 实现 API 接口
- PostgreSQL


# 设计与实现

### 数据库

  `users`  用户 https://github.com/ming-relax/roman/blob/master/web/models/user.ex

  `topics` 讨论 https://github.com/ming-relax/roman/blob/master/web/models/topic.ex

  `posts`  回复 https://github.com/ming-relax/roman/blob/master/web/models/post.ex

   One user has many topics. One topic belongs to one user.

   One User has many posts. One post belongs to one user.

   One topic has many posts. One post belongs to one topic.

### 关键代码

  三个 Controller: https://github.com/ming-relax/roman/tree/master/web/controllers/api

  (PS: Controller 级别的测试每一个都有)

# 性能分析

依据应用场景以及实际情况的不同，会有很多可能。针对现有的设计，下面列出一些我想到的点：

- index: 各个表增加索引 (现有系统应该已经加上了)。

  posts.topic_id 索引

  [posts.user_id, posts.topic_id] 联合索引

  topic.user_id 索引

  users.name 索引

- topics.posts_count, topic.last_posted_at, topic.last_posed_user_id 优化: 在现有的设计下，每次创建回复（post）的时候更新这些 column, 并且会锁住 topics 的一行。如果这成为系统瓶颈，可以考虑采用乐观锁。如果对这个 posts_count 没有比较强的实时、精确的要求，可以考虑先返回结果，推迟这些 column 的更新；把他们放在队列里，以后再更新。或者采用特殊 SQL 获取大致的结果 (PostgreSQL )。

- topic 列表优化：在现有的设计下，获取 topic 列表会对 topics 和 users 进行 join 操作以获取创建人的用户名。可以采取 Caching 的方式缓存数据库查询结果。更进一步，可以把 topic_creator_user_name 存到 topics 里，避免 join.

- topic 详情优化：在现有设计下，获取 topic 详情会对 topics, users, 和 posts 进行 joion 操作。可以采取 Caching 的方式缓存数据库查询结果。更进一步，可以把 post_creator_user_name 存到 posts 里，避免一次 join.

- Replication: 为了进一步改进读的性能，可以考虑 database replication, 以及 Caching 层 （Redis/Memcached） Replication 用来分离读请求。

- Sharding: 为了进一步改进读写性能，可以考虑 database sharding 以及 Redis/Memcached sharding.

- Scale up Application service: 增加服务器缓解应用服务的压力。'

- DNS based load balance.
