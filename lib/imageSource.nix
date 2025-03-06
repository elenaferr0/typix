{lib}: src: # TODO: check if this could be done recursively
lib.sources.sourceByRegex src [
  "^.*\.png$"
  "^.*\.jpg$"
  "^.*\.svg$"
  "^.*\.webp$"
]
