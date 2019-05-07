# astmanproxy-docker

I've been using the astmanproxy tool from https://github.com/davies147/astmanproxy for quite a while now. Only thing I was missing is having a working docker container ready. So I've spent some time now setting one up.

It's based on a centos 7 base container and a 2-step build process: 
1. Building astmanproxy from a given release from above mentioned repo (davies147)
2. Setting up a new container that will only hold the astmanproxy binary from the buod process, needed config files and a startup script

The 2-step process will at least reduce the image size to somewhat below 400MB instead of 600+MB for the build box. I've tried to fit astmanproxy into an alpine box but that just didn't work out properly. Segfault for the win ;-)

As of today the latest release from davies147 is version 1.28.2. This is stored on the ENV "ASTMANPROXY_RELEASE". The Dockerfile will download this version and build it from there. 
So someone could easily set a newer version if davies147 decides to roll out a new one. But beware of changed to the config files... 

The default expose port of this box is 1234. I've threw that into an ENV "ASTMANPROXY_PORT" so you can adopt here easily. 


# SSL certificate
astmanproxy need a ssl certificate to allow clients to establish an encrypted channel if required. 

On every start the container will perform two checks:
1. Is there a SSL certificate file for astmanproxy at "/etc/asterisk/astmanproxy.pem"? If not, one will be created (lifetime 1 year, 1024bit, config from astmanproxy-ssl.conf)
2. Check the file for its valid date. If the cert will be outdated within the next 24 hours, the script will create a new certfile

So it's a bit fool-proof and every container will have its own, fresh certificate. Yeah it's self-signed but feel free to mount a .pem certificate to the container at "/etc/asterisk/astmanproxy.pem"

If required you can easily change the bit size of newly created SSL keys by setting the corresponding ENV:
`-e "SSL_KEY_SIZE=2048"`



# Data persistence

The content of /etc/asterisk will be hold in a volume per container so it persists restarts. especially the ssl cert that is being generated on first start... You don't want to use the same ssl cert for all astmanproxy containers, do you? 




# How to build/start the container

1. `docker build -t astmanproxy:latest .`
2. `docker run -d astmanproxy:latest`



# How to mount a local directory into the container to access the config files directly

Run the container with a local directory mounted to /etc/asterisk:

1. Create a directory on the docker host to hold your files. For example "/docker/docker-astmanproxy/config"
2. There should be 3 files in this directory: astmanproxy.conf, astmanproxy.users and astmanproxy-ssl.conf - you can use the example files from the build directory. 
3. If required also put the astmanproxy.pem file into this directory. If not it will just be created on the first container startup. I've added the command to have a 2048 bit SSL key generated in the 4th step for reference ...
4. `docker run --name=astmanproxy -d -e "SSL_KEY_SIZE=2048" -v /docker/astmanproxy/config:/etc/asterisk ftaeger/astmanproxy:latest`


Beware: the Container will be build and then started. But it will exit after a few seconds. This is most probably as you've not replaced the config files and astmanproxy tries to connect to asterisk on localhost with invalid credentials. Be sure to throw in proper configs.  



