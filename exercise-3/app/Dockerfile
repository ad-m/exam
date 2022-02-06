FROM python:3-slim
LABEL org.opencontainers.image.source https://github.com/ad-m/exam
WORKDIR /src
ADD ./requirements.txt .
RUN pip install -r requirements.txt
ADD . .
CMD ["celery","-A","tasks", "worker", "--loglevel=INFO"]
