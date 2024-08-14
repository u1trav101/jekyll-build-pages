import yaml
import sys


CONFIG_OUT_PATH = "/_config.out.yml"
github_plugins = [
    "jekyll-coffeescript",
    "jekyll-default-layout",
    "jekyll-gist",
    "jekyll-github-metadata",
    "jekyll-optional-front-matter",
    "jekyll-paginate",
    "jekyll-readme-index",
    "jekyll-titles-from-headings"
]

if len(sys.argv) > 1:
    print(f"Jekyll config found at {sys.argv[1]}, merging with github-pages config...")
    data = None
    with open(sys.argv[1], "r") as file:
        data = yaml.safe_load(file)

        if data["plugins"] is not None:
            data["plugins"] += github_plugins
    
    with open(CONFIG_OUT_PATH, "w") as file:
        yaml.safe_dump(data, file)
else:
    print("No Jekyll config provided, using base github-pages config...")
    with open(CONFIG_OUT_PATH, "w") as file:
        yaml.safe_dump({
            "plugins": github_plugins
        }, file)
