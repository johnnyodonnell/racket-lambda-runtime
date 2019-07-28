FROM amazonlinux

RUN yum update -y
RUN yum install wget -y
RUN yum install tar -y
RUN yum install gzip -y

RUN wget https://mirror.racket-lang.org/installers/7.3/racket-7.3-x86_64-linux.sh
RUN chmod u+x ./racket-7.3-x86_64-linux.sh
RUN printf 'yes' | ./racket-7.3-x86_64-linux.sh

ADD runtime.rkt .
RUN raco exe --orig-exe ++lang racket runtime.rkt

