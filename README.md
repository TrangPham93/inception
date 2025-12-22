- Oracle VirtualBox is a so-called hosted hypervisor, While several hypervisors can normally be installed in parallel, do not attempt to run virtual machines from competing hypervisors at the same time. Oracle VirtualBox cannot track what another hypervisor is currently attempting to do on the same host, and especially if several products attempt to use hardware virtualization features such as VT-x, this can crash the entire host.
- VMs can easily be imported and exported using the Open Virtualization Format (OVF).
- Docker compose is a tool that allows you to define and manage multiple Docker containers simultaneously. If your app needs multiple services (like a web server, a database, and a caching service), Docker Compose helps you define and manage all these services together.
    Docker: You create individual containers for each part of your application. For example, one container for the web server, one for the database, and another for the caching service.
    Docker Compose: You define a docker-compose.yml file where you specify how these containers should work together. This file includes details like which images to use, the network settings, volumes, and environment variables.
    Running the Setup: With a single command (docker-compose up), Docker Compose starts and manages all the defined containers, ensuring they communicate and work together seamlessly.
- Docker images are read-only templates that contain instructions for creating a container. There are two important principles of images:

    Images are immutable. Once an image is created, it can't be modified. You can only make a new image or add changes on top of it.

    Container images are composed of layers. Each layer represents a set of file system changes that add, remove, or modify files.
- A Dockerfile is a text-based document that's used to create a container image.

https://devopscube.com/build-docker-image/