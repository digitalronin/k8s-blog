---
title: "Rails on Kubernetes - part 4: Docker Compose"
date: 2019-05-13T20:11:19+01:00
---

> This is one of a series of blog posts in which I'm walking through the process of deploying a rails application to a kubernetes cluster. Part one is [here][start], and the previous article is [here][previous].

To test our containerised Rails app locally, before we try to deploy it to our kubernetes cluster, we can use [docker-compose].

First of all, stop the postgresql container, otherwise things might get confusing:

    docker stop postgresql

We're going to create a docker-compose configuration file to run our application. For our app. to work, we need a database and our rails application. We also need to run our rails database migrations to create the 'values' table that our app. needs.

So, our docker-compose file is going to run a postgresql database container. We'll use the 'bitnami/postgresql' image, which runs without root permissions. Kubernetes cluster administrators often apply security policies which prevent users from running containers with root permissions, so it's good practice to avoid doing this.

We'll run our rails application using the docker image we created in the [previous] post. We can use the same docker image to run our migrations, too.

We'll use the 'depends_on' keyword to tell docker-compose not to start our migrations job until the database is started, and not to start our rails container before the migrations container.

Even though our migrations container will be started after the database container, it's very likely that the database will not have finished initialising, the first time the migrations container starts. So it will probably fail, the first time. We'll use the 'restart' keyword to tell docker-compose to retry the migrations job and the rails container if they fail.

By the way, I absolutely do not recommend running a production database this way - i.e. in a docker container with local storage. But, I want to keep this series simple, and focused on the deployment process, and this is the simplest way of getting *something* useful up and running.

In your `counter` directory, create a `docker-compose.yml` file containing this:

{{<highlight yaml>}}
version: '2'
services:
  db:
    image: bitnami/postgresql:11.3.0
    environment:
      POSTGRESQL_USERNAME: my_user
      POSTGRESQL_PASSWORD: password123
      POSTGRESQL_DATABASE: counter_dev
  migrations:
    image: counter-app:1.0
    restart: on-failure
    command: ["bundle", "exec", "rails", "db:migrate"]
    depends_on:
      - db
    environment:
      DATABASE_URL: postgres://my_user:password123@db/counter_dev
  rails:
    image: counter-app:1.0
    ports:
      - "3000:3000"
    depends_on:
      - migrations
    restart: on-failure
    environment:
      DATABASE_URL: postgres://my_user:password123@db/counter_dev
{{</highlight>}}

Note the '@db' part of the DATABASE_URL that our rails container uses to talk to postgresql. That's addressing the postgresql container via the hostname 'db'. This is part of the networking magic that docker-compose does for us. When we define a 'db' service in our docker-compose file, the relevant container is addressable as a hostname matching the name we gave our service.

Start the application by running:

    docker-compose up

You will probably see a bunch of errors from the migrations job, the first one or two times it tries to connect to the database, but after a few seconds you should be able to visit 'http://localhost:3000/values' and increment the counter in the same way as before.

In this post, we ran our application as part of a multi-container setup using docker-compose. In the next section, we'll see how that translates to kubernetes.

[docker-compose]: https://docs.docker.com/compose/overview/
[start]: /posts/rails-on-k8s-setup
[previous]: /posts/rails-on-k8s-dockerise
[next]: #

