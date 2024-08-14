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
    print("Jekyll config provided, merging with github-pages config...")
    data = None
    with open(JEKYLL_CONFIG_PATH, "r") as file:
        data = yaml.safe_load(file)

        if data["plugins"] is not None:
            data["plugins"].update(github_plugins + data["plugins"])
    
    with open(JEKYLL_CONFIG_PATH, "w") as file:
        yaml.safe_dump(data, file)
else:
    print("No Jekyll config provided, using base github-pages config...")
    with open(JEKYLL_CONFIG_PATH, "w") as file:
        yaml.safe_dump({
            "plugins": github_plugins
        }, file)
