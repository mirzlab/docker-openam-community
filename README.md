# docker-openam-community

Docker image for OpenAM (community version 11.0.3). Designed for quickly build a simple OpenAM environment.

# How to use

## Quick run

```sh
$ docker build . -t openam
$ docker run -it --rm --add-host "openam.example.com:127.0.0.1" -p 443:443 openam
```

**Warning:** Do not forget to add a host mapping inside your hosts file:
**Linux:**
```sh
$ echo "127.0.0.1 openam.example.com" >> /etc/hosts
```

**Windows:**
Add this line inside *C:\Windows\System32\drivers\etc\hosts* file:
```sh
127.0.0.1 openam.example.com
```

## Default build parameters

* OPENAM_HTTPS: **true**
* TOMCAT_HTTPS_PORT: **443**
* TOMCAT_HTTP_PORT: **80**
* OPENAM_HOST: **openam.example.com**
* OPENAM_DEPLOYMENT_URI: **openam** (Specifies OpenAM war file name that will be deployed inside tomcat)
* OPENAM_ADMIN_PASSWORD: **Admin001**

## Custom configuration

Some examples:

```sh
$ docker build . -t openam \
--build-arg OPENAM_HOST=demo.openam.com \
--build-arg OPENAM_DEPLOYMENT_URI=sso \
--build-arg OPEANM_ADMIN_PASSWORD=P@ssw0rd \
--build-arg OPENAM_HTTPS=false \
--build-arg TOMCAT_HTTP_PORT=8888
$ docker run -it --rm --add-host "demo.openam.com:127.0.0.1" -p 8888:8888 openam
```

```sh
$ docker build . -t openam \
--build-arg OPENAM_HOST=demo.openam.com \
--build-arg OPENAM_DEPLOYMENT_URI=sso \
--build-arg OPEANM_ADMIN_PASSWORD=P@ssw0rd01 \
--build-arg OPENAM_HTTPS=true \
--build-arg TOMCAT_HTTPS_PORT=8443
$ docker run -it --rm --add-host "demo.openam.com:127.0.0.1" -p 8443:8443 openam
```

In case OPENAM_HTTPS is set to **true**, OpenAM will be configured using HTTPS. Tomcat HTTPS connector is configured using a generated self signed certificate.

