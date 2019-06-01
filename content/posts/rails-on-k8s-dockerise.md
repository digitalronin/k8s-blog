---
title: "Rails on Kubernetes - part 3: Dockerise"
date: 2019-05-06T20:11:19+01:00
draft: true
---

# Rails on Kubernetes - part 3: Dockerise

Kubernetes runs containers, so before we can deploy our application to kubernetes, we need to containerise it.

In this section, we're going to take our rails application and package it up as a Docker image.

Before we do that, there is a small tweak we need to make. Rails applications require the `tzinfo-data` gem on some platforms, but not others. The docker image we will create needs the gem, but bundler fails to recognise the environment correctly, when installing gems in the docker image. To fix this, we tell bundler to install the gem everywhere. Edit your `Gemfile`, and right at the end, you should see this line:

    gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

Delete the comma and everything after it, so that the line becomes:

    gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

Then, run bundle install, to update the `Gemfile.lock`

Still in your `counter` directory, create a file called `Dockerfile`, containing this:

{{<highlight docker>}}
FROM ruby:2.6.2-alpine

# Install pre-requisites for building nokogiri & pg gems
RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev postgresql-dev libxml2-dev libxslt-dev

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

RUN chown -R appuser:appgroup /app/tmp
RUN chown -R appuser:appgroup /app/log
RUN chown -R appuser:appgroup /app/db

USER 1000

CMD ["rails", "server"]
{{</highlight>}}

Let's break down what this is doing.

{{<highlight docker>}}
FROM ruby:2.6.2-alpine
{{</highlight>}}

We're basing our image on the standard ruby image from docker hub, but we're specifying the `2.6.2-alpine` tag. Alpine images are a lot smaller than the 'full fat' versions, and it's good practice to keep our docker images as small as possible.

{{<highlight docker>}}
RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev postgresql-dev libxml2-dev libxslt-dev
{{</highlight>}}

`apk` is the alpine package manager. Rails depends on some gems which in turn depend on compiled C code and certain system libraries. This section installs the libraries and build tools that will be required during the `bundle install` step.

{{<highlight docker>}}
WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .
{{</highlight>}}

Set a working directory, copy in our `Gemfile` and `Gemfile.lock` and install all our gems, then copy the rest of our source code into the container. For a real application, our source code will change much faster than our Gemfile and Gemfile.lock. Installing the gems first, and then copying our source code means we can rebuild our docker image much faster after each code change, because we don't have to keep re-installing all the gems (because Docker caches all stages of a build, and only repeats steps from whenever the first change is detected).

{{<highlight docker>}}
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

RUN chown -R appuser:appgroup /app/tmp
RUN chown -R appuser:appgroup /app/log
RUN chown -R appuser:appgroup /app/db

USER 1000
{{</highlight>}}

It's good practice for containers to run as a non-root user. Cluster administrators often set security policies which *prevent* root containers from running at all. So this section creates a non-root user, with uid 1000. appuser needs to be able to write to the tmp, log and db directories, so we grant it ownership of those, then switch from root to appuser.

{{<highlight docker>}}
CMD ["rails", "server"]
{{</highlight>}}

Finally, we run the rails server command to start up our webserver.

To build our docker image, execute this command:

    docker build -t counter-app:1.0 .

You should see a bunch of output lines, ending with these two (your container id will be different)

    Successfully built 935b08611cd5
    Successfully tagged counter-app:1.0

Now we have our docker image. In the [next section][part4] we'll see how to run it locally using docker-compose.

[part4]: /posts/rails-on-k8s-docker-compose

