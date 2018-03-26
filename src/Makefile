all: 			\
helpers.py 		\
primes.py		\
isogeny.py 		\
walk.py 		

clean:
	find -maxdepth 1 -type f ! -name Makefile ! -name get_modpolys.py ! -name logger.py ! -name utils.py ! -name "*.R" ! -name "*.sage" -exec rm {} \;

helpers.py: helpers.sage.py
	mv helpers.sage.py helpers.py

helpers.sage.py: helpers.sage
	sage --preparse helpers.sage

primes.py: primes.sage.py
	mv primes.sage.py primes.py

primes.sage.py: primes.sage
	sage --preparse primes.sage

isogeny.py: isogeny.sage.py
	mv isogeny.sage.py isogeny.py

isogeny.sage.py: isogeny.sage
	sage --preparse isogeny.sage

walk.py: walk.sage.py
	mv walk.sage.py walk.py

walk.sage.py: walk.sage
	sage --preparse walk.sage
