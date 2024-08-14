import yaml
import os

JEKYLL_CONFIG_PATH = "/github/workspace/_config.yml"
github_plugins = [
    "jekyll-coffeescript",
    "jekyll-default-layout",
    "jekyll-gist",
    "jekyll-github-metadata",
    "jekyll-optional-front-matter"
    "jekyll-paginate",
    "jekyll-readme-index",
    "jekyll-titles-from-headings"
]

if os.path.exists(JEKYLL_CONFIG_PATH):
    with open(JEKYLL_CONFIG_PATH, "r") as file:
        cur_yaml = yaml.safe_load(file)

        if cur_yaml["plugins"] is not None:
            cur_yaml["plugins"].update(github_plugins + cur_yaml["plugins"])