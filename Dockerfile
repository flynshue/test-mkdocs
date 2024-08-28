FROM squidfunk/mkdocs-material:9
ARG user
RUN adduser -D $user
RUN pip install mkdocs-rss-plugin
USER $user