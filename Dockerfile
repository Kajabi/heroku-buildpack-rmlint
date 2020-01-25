# This Dockerfile is intended for running tests on non-Debian systems

# Maybe need heroku/heroku:18-build
FROM heroku/heroku:18
WORKDIR /rmlint
COPY bin/ ./bin
COPY test/ ./test
COPY Aptfile ./Aptfile

ENV STACK heroku-18

ENTRYPOINT ./bin/support/test
