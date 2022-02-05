ARG OPENJDK_TAG=11
FROM openjdk:${OPENJDK_TAG} AS compile-image

ARG SBT_VERSION=1.5.5

# Install sbt
RUN curl -L -o sbt-$SBT_VERSION.deb https://repo.scala-sbt.org/scalasbt/debian/sbt-$SBT_VERSION.deb
RUN dpkg -i sbt-$SBT_VERSION.deb
RUN rm sbt-$SBT_VERSION.deb
RUN apt-get update
RUN apt-get install sbt

WORKDIR /opt/app
COPY src/ project/ build.sbt ./
RUN mill clean
RUN mill main.assembly

# I don't really understand this line.
# ENV PATH="./node_modules/.bin:$PATH" 

COPY target/scala-2.12/app-assembly-dev.jar ./

FROM openjdk:11
WORKDIR /opt
COPY --from=compile-image /opt/app/app-assembly-dev.jar /opt/app-assembly-dev.jar
EXPOSE 80
EXPOSE 443
CMD ["java", "jar", "/opt/app-assembly-dev.jar /opt/app-assembly-dev.jar"]
