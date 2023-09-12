# Kanpai Infrastructure
Kanpai has a NixOS-based infrastructure with Kubernetes running on top (see [kanpai/state] for the primary cluster's source of truth).
This repository serves as the single source of truth for the hosts.


In general the machines defined here are supposed to serve one purpose: to join the Kubernetes clusters.
This does however not apply all hosts, such as Bastions,  and temporary setups.

## Structure
The internal structure of this repo aims to provide the most flexible while still having sensible defaults.

#### Config.nix

#### Hosts
All hosts, or host templates (such as for generic VMs), are defined in the `hosts/` directory.
They get their own directory with configuration that generally handles disks, networking, and host-specific quirks.
(see [`hosts/muffin`] for a concrete example)

There are a few key requirements for hosts.
- Amnesiac: on reboot, host forgets all state not described in this repo (with exceptions, e.g. ssh host keys).
    This is handled by having the root filesystem be temporary - which usually translates to being mounted as
    a tmpfs - and having a secondary filesystem for the few things that do need to persist and can't be
    known while building the system. Everything else is handled by the Nix store.
    (see [impermanence](https://nixos.wiki/wiki/Impermanence) for more)
- Full disk encryption: all drives are encrypted. This is typically done with a USB drive left in a port.
    This is not ideal, but it's the current state of affairs.


#### Roles
Roles are defined 


## Hosts

## Clusters
