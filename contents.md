## Kubernetes Cluster Operations at DigitalOcean
<!-- .slide: data-transition="fade-out" data-background-color="#0080FF" -->
Dan Norris

@protochron


## Kubernetes
<!-- .slide: data-transition="fade-out" -->
> Kubernetes is an open-source platform for automating deployment, scaling, and
> operations of application containers across clusters of hosts, providing
> container-centric infrastructure.

* Run lots of containers easily and scalably

Note:
Kubernetes is an open-source platform for automating deployment,
scaling, and operations of application containers across clusters of hosts.


<!-- .slide: data-background-image="/assets/architecture.png" data-background-size="90% 90%" data-transition="fade-out" -->


## Kubernetes at DigitalOcean
<!-- .slide: data-transition="fade-out" data-background-color="#0080FF" -->


## DigitalOcean Control Center (DOCC)
* Internal runtime platform
* Kubernetes provides the backbone
* Allows developers to quickly and easily ship their code
* Runs most customer-facing applications at DigitalOcean


## DOCC Features
* Adds DO application best practices using a custom JSON manifest
  * alerting
  * service discovery
  * logging
  * metrics
* Users submit jobs using an API that wraps Kubernetes


## More Info On DOCC
* [Delivering Services at DigitalOcean](http://schd.ws/hosted_files/cnkc16/5c/delivering%20services%20at%20digitalocean.pdf)
* [Building a Platform for the Future](https://youtu.be/Jhfd5FjYimU?list=PLj6h78yzYM2PAavlbv0iZkod4IVh_iGqV)


<!-- .slide: data-background-image="/assets/map/map.png" data-background-size="100% auto" -->


## Bootstrapping a Region
* 5 etcd servers
* 3 control plane servers (apiserver, controller-manager, kube-scheduler)
* 6+ nodes


## Base Amount of Droplets
* 14 \* 14 = 196 droplets (!)  <!-- .element: class="fragment" -->
* Most regions run quite a few more than that <!-- .element: class="fragment" -->
* Add nodes as needed when new services spin up or are migrated <!-- .element: class="fragment" -->


## How do you manage so many droplets?!
<!-- .slide: data-transition="fade-out" data-background-color="#0080FF" -->


## The old way
* Statically allocate droplets (doctl or API) <!-- .element: class="fragment" -->
* Provision using Chef <!-- .element: class="fragment" -->
* Works great for small services, not so great when launching 100s of droplets <!-- .element: class="fragment" -->


![Terraform](/assets/readme.png)
<!-- .slide: data-background="#000" data-transition="fade-out" -->


## Terraform
<!-- .slide: data-transition="fade-out" -->
  > Terraform provides a common configuration to launch infrastructure — from
  > physical and virtual servers to email and DNS providers. Once launched,
  > Terraform safely and efficiently changes infrastructure as the
  > configuration is evolved.

* Declarative infrastructure
* Benefit: combine provisioning and maintenance
* Killer feature: keep track of state and validate


## Terraform Resources
* A resource is a component of your infrastructure

<pre><code data-trim data-noescape>
resource digitalocean_droplet "apiserver" {
  count              = 1
  image              = "ubuntu-16-04-x64"
  region             = "sgp1"
  size               = "2gb"
  name               = "kube-apiserver"
  ssh_keys           = ["${split(",", var.ssh_keys)}"]
  private_networking = true

  provisioner "chef" {...}
}
</code></pre>
* There are [resources for every DigitalOcean feature](https://www.terraform.io/docs/providers/do/)


## Terraform Modules
>Modules in Terraform are self-contained packages of Terraform configurations
>that are managed as a group. Modules are used to create reusable components in
>Terraform as well as for basic code organization.

* Droplet
* etcd
* Kubernetes


## Droplet Module
Provides common configuration for launching droplets and provisioning using Chef
* Combines the launch and provision steps <!-- .element: class="fragment" -->

![Droplet](/assets/droplet.png) <!-- .element: class="fragment" -->


## Tokens?
<!-- .slide: data-transition="fade-out" data-background-color="#0080FF" -->


<!-- .slide: data-background-image="/assets/blog.png" data-background-size="100% auto" data-transition="fade-out" -->

Note:
Vault acts as a CA for Kubernetes. Means that we can fully secure the cluster automatically


## http://do.co/vault
<!-- .slide: data-transition="fade-out" -->


## etcd Module
<!-- .slide: data-transition="fade-out" -->
Creates an Etcd cluster
* Imports the droplet module

![Droplet](/assets/etcd.png) <!-- .element: class="fragment" -->


## Kubernetes Module
Creates a kubernetes cluster
* Also imports the droplet module
* Chef provides the metadata to find the correct etcd cluster

![Droplet](/assets/kubernetes.png) <!-- .element: class="fragment" -->


## Cluster Operations
<!-- .slide: data-transition="fade-out" -->


## Cluster Operations
* Create a cluster
* Add new nodes
* Update/replace nodes
* Remove old nodes


## Cluster Operations
### Create a cluster
* Export secrets to a <code>secrets.tfvars</code> file
* Create a top-level cluster module + variables file
* <code>terraform apply -var-file=~/secrets.tfvars -var-file=cluster.tfvars </code>
* Start cluster services


## Cluster Operations
### Add Node
* Edit <code>cluster.tfvars</code>
<pre><code data-trim data-noescape>
  node_count = "7" # was previously 6
</code></pre>
* <code data-trim data-noescape> terraform apply -var-file=~/secrets.tfvars -var-file=cluster.tfvars </code>


## Cluster Operations
### Replace Node
* Mark a node as needing to be replaced in Terraform (<code>terraform taint</code>)
* <code>terraform apply</code>


## Cluster Opertations
### Delete node
* Edit <code>cluster.tfvars</code>
<pre><code data-trim data-noescape>
  node_count = "6" # was previously 7
</code></pre> <!-- .element: class="fragment" -->
* terraform apply -var-file=~/secrets.tfvars -var-file=cluster.tfvars <!-- .element: class="fragment" -->


## Cluster Opertations
### Delete Node
* [Destroy provisioners](https://www.terraform.io/docs/provisioners/#destroy-time-provisioners) run when a resource is destroyed
* New in Terraform 0.9
* Takes care of <!-- .element: class="fragment" -->
  * Downtiming alerts <!-- .element: class="fragment" -->
  * Draining the node <!-- .element: class="fragment" -->
  * Removing from apiserver using kubectl <!-- .element: class="fragment" -->


## Benefits
<!-- .slide: data-transition="fade-out" data-background-color="#0080FF" -->


## Benefits
### Cluster State
* Everything is in version control!
* Changes are reviewed
* Terraform lets you preview changes


## Benefits
### Tooling
* One unified tool for all operations
* Take the **fear** out of making changes


## Recap
* Codifying infrastructure makes managing many Kubernetes clusters easier
* Terraform makes cluster operations simple and predictable
* Vault lets you easily secure the cluster


## See it in Action
https://github.com/protochron/k8s-coreos-digitalocean


## Get the slides
docker pull protochron/hsinchu-do-meetup


## Thanks for listening!

* Twitter: @protochron
* Github: @protochron


## Resources
### Kubernetes
* [The Children's Illustrated Guide to Kubernetes](https://deis.com/blog/2016/kubernetes-illustrated-guide/)
* [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
* [Kubernetes Documentation](http://kubernetes.io/docs/)


## Resources
### Terraform
* [Terraform Docs](https://www.terraform.io/docs/)
* [Terraform DigitalOcean Provider](https://www.terraform.io/docs/providers/do/index.html)
* [Two Weeks with Terraform](https://charity.wtf/2016/02/23/two-weeks-with-terraform/)
* [Terraform Infrastructure Design Patterns](https://opencredo.com/terraform-infrastructure-design-patterns)
* [Terraform Modules for Fun and Profit](http://blog.lusis.org/blog/2015/10/12/terraform-modules-for-fun-and-profit/)


## Resources
### K8S At DigitalOcean
* [Delivering Services at DigitalOcean](http://schd.ws/hosted_files/cnkc16/5c/delivering%20services%20at%20digitalocean.pdf)
* [Building a Platform for the Future](https://youtu.be/Jhfd5FjYimU?list=PLj6h78yzYM2PAavlbv0iZkod4IVh_iGqV)


## Resources
### Books
* [The Terraform Book](https://terraformbook.com/)
* [Terraform Up and Running](http://shop.oreilly.com/product/0636920061939.do)
* [Kubernetes: Up and Running](http://shop.oreilly.com/product/0636920043874.do)
