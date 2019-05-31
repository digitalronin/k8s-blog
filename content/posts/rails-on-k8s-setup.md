---
title: "Rails on Kubernetes - part 1: Setup"
date: 2019-04-16T20:10:47+01:00
draft: true
---

# Rails on Kubernetes - part 1: Setup

This is part one of a series of posts in which I'm going to walk through the process of deploying a Ruby on Rails application to Kubernetes.

In this post, we're going to use a one-node kubernetes cluster, running on your local development machine.
One of the great things about kubernetes is that, from the point of view of your code, all clusters are the same.
So, if we write code to deploy our application on a local development cluster, that same code should work just fine when we deploy it to our
production cluster.

The two most popular ways to run a local development kubernetes cluster are via the Docker desktop client, or to use Minikube.
We'll cover both of these.

## Kubernetes on Docker Desktop

If you're running a recent version of the Docker desktop client. You can run a local kubernetes cluster with just a few clicks.

Click on the Docker icon in your taskbar, and select 'Kubernetes' from the drop-down menu, then click on 'Enable local cluster'.

![foo](/images/start-docker-k8s.png)

You'll have to wait a few minutes while the Docker client downloads and installs Kubernetes.
Then you should have a working kubernetes cluster on your machine.

## Minikube

If you can't or don't want to use Kubernetes via the Docker client, [Minikube][minikube] is another option.
Minikube runs a kubernetes cluster in a virtual machine on your computer, so you'll need a
hypervisor like VirtualBox.

The installation instructions on the [minikube] site are very clear, so rather than reproduce those here,
I recommend visiting their site.

## kubectl

kubectl is the command-line tool you will use most often when interacting with a kubernetes cluster.

You can install it on a Mac via Homebrew like this:

    brew install kubernetes-cli

For other installation methods, please see the [installation instructions][install-kubectl].

## Confirming your setup

To confirm that everything is up and running correctly, execute this command from a terminal window:

    $ kubectl cluster-info

You should see output something like this:


    Kubernetes master is running at https://localhost:6443
    KubeDNS is running at https://localhost:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

Now that we have our cluster up and running, we'll create a rails application to deploy on it in [part two][part2]

[minikube]: https://kubernetes.io/docs/tasks/tools/install-minikube/
[install-kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[part2]: /posts/rails-on-k8s-create-app
