# NervesNode

Experimental repository used for automatically connecting Nerves devices into an Erlang cluster using MdnsLite.

You can rip anything you want from this but don't use it for production stuff as is. It is literally the fastest thing I could get working.

# Setup

Each Nerves device needs the [mdns_lite bridge configuration](https://github.com/nerves-networking/mdns_lite#dns-bridge-configuration).

This library handles [this part](https://hexdocs.pm/nerves_pack/0.6.0/readme.html#erlang-distribution) plus making queries and using the responses.

Each device needs to be on the same network.
