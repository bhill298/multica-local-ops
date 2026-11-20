FROM ubuntu:26.04
RUN apt-get update && apt-get install -y --no-install-recommends xorriso python3 && rm -rf /var/lib/apt/lists/*
COPY make-media.py /make-media.py
ENTRYPOINT ["python3","/make-media.py"]
