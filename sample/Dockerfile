FROM trenpixster/elixir:v1.0.2
ENV REFRESHED_AT 2015-03-10
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*
ENV JAVA_VERSION 7u71
ENV JAVA_DEBIAN_VERSION 7u71-2.5.3-2
RUN apt-get update && apt-get install -y openjdk-7-jdk="$JAVA_DEBIAN_VERSION" && rm -rf /var/lib/apt/lists/*
