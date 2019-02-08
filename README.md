# astmanproxy-docker

I've been using the astmanproxy tool from https://github.com/davies147/astmanproxy for quite a while now. Only thing I was missing is having a working docker container ready. So I've spent some time now setting one up.

It's based on a centos 7 base container and a 2-step build process: 
1. Building astmanproxy from a given release from above mentioned repo (davies147)
2. Setting up a new container that will only hold the astmanproxy binary from the buod process, needed config files and a startup script

The 2-step process will at least reduce the image size to somewhat below 400MB instead of 600+MB for the build box. I've tried to fit astmanproxy into an alpine box but that just didn't work out properly. Segfault for the win ;-)

As of today the latest release from davies147 is version 1.28.2. This is stored on the ENV "ASTMANPROXY_RELEASE". The Dockerfile will download this version and build it from there. 
So someone could easily set a newer version if davies147 decides to roll out a new one. But beware of changed to the config files... 


The default expose port of this box is 1234. I've threw that into an ENV "ASTMANPROXY_PORT" so you can adopt here easily. 

On every start the container will perform two checks:
1. Is there a SSL certificate file for astmanproxy? If not, one will be created (lifetime 1 year, 1024bit, config from astmanproxy-ssl.conf)
2. Check the file for its valid date. If the cert will be outdated within the next 24 hours, the script will create a new certfile

So it's a bit fool-proof and every container will have its own, fresh certificate. Yeah it's self-signed but feel free to mount a .pem certificate to the container at "/etc/asterisk/astmanproxy.pem"




