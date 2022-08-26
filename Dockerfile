FROM python:3.7.5

#Todo change timezone base on projet 
ENV TZ=Europe/Paris 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y \
        curl \
        gcc \
        git \
        vim \
        libxrender1 \
        libfontconfig \
        libxtst6 \
        xz-utils

RUN apt-get install -y libpq-dev python-dev

RUN mkdir /webapp


COPY ./requirements.txt /webapp/
WORKDIR /webapp

RUN python3 -m pip install --upgrade pip

RUN pip install -r requirements.txt

COPY . /webapp

RUN mkdir /webapp/uploads
RUN mkdir /webapp/alembic/versions

EXPOSE 80

CMD ["uvicorn", "app.main:app", "--port=80", "--host=0.0.0.0"]
