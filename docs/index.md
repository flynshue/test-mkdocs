# test-mkdocs
PoC with squidfunk/mkdocs-material:9

## Building Docker image
The default image specified in the [official docs](https://squidfunk.github.io/mkdocs-material/creating-your-site/) will run everything as root which is a terrible idea

If you were to copy/paste command from the docs and run it, it would create `./docs/index.md` with the root user

> [!NOTE]This docker image is meant to be run locally for development. i.e Don't run this in k8s

> [!WARNING] Don't run this as root, it's a bad idea

```bash
flynshue@flynshue-Latitude-7430:/tmp/faker-docs$ docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material:9 new .
INFO    -  Writing config file: ./mkdocs.yml
INFO    -  Writing initial docs: ./docs/index.md
flynshue@flynshue-Latitude-7430:/tmp/faker-docs$ ll
total 40
drwxrwxr-x  3 flynshue flynshue  4096 Aug 28 14:07 ./
drwxrwxrwt 28 root     root     24576 Aug 28 14:07 ../
drwxr-xr-x  2 root     root      4096 Aug 28 14:07 docs/
-rw-r--r--  1 root     root        19 Aug 28 14:07 mkdocs.yml
```

Instead of running as root, I created a Dockerfile that you can user to use during the build. For example,
```bash
$ docker build --build-arg user=$USER -t $USER/mkdocs-material:9 .

[+] Building 0.2s (6/6) FINISHED                                                                                                                                                                                                         docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                                               0.0s
 => => transferring dockerfile: 110B                                                                                                                                                                                                               0.0s
 => [internal] load metadata for docker.io/squidfunk/mkdocs-material:9                                                                                                                                                                             0.0s
 => [internal] load .dockerignore                                                                                                                                                                                                                  0.0s
 => => transferring context: 2B                                                                                                                                                                                                                    0.0s
 => [1/2] FROM docker.io/squidfunk/mkdocs-material:9                                                                                                                                                                                               0.0s
 => CACHED [2/2] RUN adduser -D flynshue                                                                                                                                                                                                           0.0s
 => exporting to image                                                                                                                                                                                                                             0.0s
 => => exporting layers                                                                                                                                                                                                                            0.0s
 => => writing image sha256:b823e9f635c994811b5be4bccdd7cdd6ab4f55926c027021c751c769e6fc0bc6                                                                                                                                                       0.0s
 => => naming to docker.io/flynshue/mkdocs-material:9
```

## Bootstrapping mkdocs
Once you have built your docker image, you can now run

```bash
$ docker run --rm -it -v $PWD:/docs $USER/mkdocs-material:9 new .

INFO    -  Writing config file: ./mkdocs.yml
INFO    -  Writing initial docs: ./docs/index.md
```

## Preview your site
```bash
$ docker run --rm -it -v $PWD:/docs -p 8000:8000 $USER/mkdocs-material:9

...
INFO    -  [18:23:19] Reloading browsers
INFO    -  [18:23:39] Browser connected: http://0.0.0.0:8000/flynshue/fakeproject/
INFO    -  [18:23:42] Browser connected: http://0.0.0.0:8000/flynshue/fakeproject/blog/
INFO    -  [18:23:43] Browser connected: http://0.0.0.0:8000/flynshue/fakeproject/
INFO    -  [18:23:44] Browser connected: http://0.0.0.0:8000/flynshue/fakeproject/blog/
INFO    -  [18:23:46] Browser connected: http://0.0.0.0:8000/flynshue/fakeproject/
```

You can then open your site in web browser at port 8000

## Publishing to GHA
First you'll need to go to your github repo's settings > pages

Set the github pages to source to **Build from a branch**

Set the branch to **gh-pages** and folder to **/root**

You'll need to add GHA workflow to that will run `mkdocs` to build your site

You can use the [GHA workflow](https://squidfunk.github.io/mkdocs-material/publishing-your-site/#with-github-actions) from mkdocs-material as a starting point

Note you'll need to make sure that GHA workflow includes `pip install mkdocs-<pluginName>` for any additional plugins you need.

After you push to `main` branch that will kick off the GHA workflow to deploy your github pages