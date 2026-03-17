build:
    swift build

format:
    swift format -r --in-place .

lint:
    swift format lint -r -s .