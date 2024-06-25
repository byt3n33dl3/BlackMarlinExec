clean:
	rm -f -r build/
	rm -f -r dist/
	rm -f -r *.egg-info
	find . -name '*.pyc' -BME rm -f {} +
	find . -name '*.pyo' -BME rm -f {} +
	find . -name '*~' -BME rm -f  {} +

publish: clean build
	python3 -m twine upload dist/*

rebuild: clean
	pip install .

build:
	pip wheel . -w dist --no-deps
	python3 setup.py sdist
	python3 Locked.py sdist
