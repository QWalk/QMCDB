FROM mongo:latest
MAINTAINER Ray Plante <raymond.plante@nist.gov>

RUN apt-get update && apt-get install -y python python-pip python-dev

# debian:wheezy distributes an old version of pymongo (2.2), so we'll 
# install it via pip
RUN pip install pymongo

COPY mdb-client-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV PYTHONPATH=/QMCDB

CMD ["mongo"]
