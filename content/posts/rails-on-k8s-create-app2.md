---
title: "Rails on Kubernetes - part 2a: The Counter App."
date: 2019-04-30T20:11:07+01:00
draft: true
---

# Rails on Kubernetes - part 2a: The Counter App

Our rails application can connect to our database. So now let's get it to do
what we want, which is to store and display a value, and increment it whenever
we click a button.

Fire up a termninal, and cd into the `counter` directory.

First, let's create a scaffold for our value.

    rails generate scaffold value amount:integer
    rails db:migrate

This creates a lot more than we actually need, but I'm more concerned about the
kubernetes part than the rails part, in this tutorial, so I'm not going to
worry about that (or about best practice for our rails code).

The scaffold is designed for us to manage a set of 'value' records, but we only
really want one, so let's make that work.

Replace everything in `app/controllers/values_controller.rb` with this:

{{<highlight ruby>}}
class ValuesController < ApplicationController
  def index
    @value = Value.any? ? Value.first : Value.create(amount: 0)
  end

  def update
    value = Value.find params[:id]
    value.update(amount: value.amount + 1)

    redirect_to values_path
  end
end
{{</highlight>}}

Replace everything in `app/views/values/index.html.erb` with this:

    <h1>
      <%= @value.amount %>
    </h1>

    <%= form_for @value do |f| %>
      <%= f.submit "Increment" %>
    <% end %>

Now, visit `http://localhost:3000/values`, and you should see this:

![Counter App](/images/counter-app.png)

Every time you click the button, the number should increase.

That's all the work we're going to do on our rails app. It's extremely simple,
but it's enough to prove that our rails application is interacting with our
database, which is all we need.

In the [next part][part3], we'll start to prepare the application for
deployment on our kubernetes cluster.

[part3]: /posts/rails-on-k8s-dockerise
