# Conqueuer

Conqueuer (pronounced like conquer) is a non-persistent Elixir work queue.


### Documentation

The [docs](http://hexdocs.pm/conqueuer/0.1.0/Conqueuer.html) can be found on the
[hexdocs](http://hexdocs.pm) website.


### Installation

Conqueuer can be installed like:

  1. Add test to your list of dependencies in `mix.exs`:

        def deps do
          [{:conqueuer, "~> 0.1.0"}]
        end

  2. Ensure test is started before your application:

        def application do
          [applications: [:conqueuer]]
        end
